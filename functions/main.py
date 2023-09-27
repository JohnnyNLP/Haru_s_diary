# 서버 관련
from firebase_functions import https_fn, options
from firebase_admin import initialize_app, auth, credentials, firestore
from flask import Flask, request
from flask_cors import CORS
from google.cloud import firestore
from google.cloud.firestore import SERVER_TIMESTAMP

# 환경 변수
from dotenv import load_dotenv
import os

# 내장 함수
import re
import random

# LLM 관련
import openai
from langchain.chains import LLMChain
from langchain.llms import OpenAI
from langchain.chat_models import ChatOpenAI
from langchain.prompts import PromptTemplate
# from langchain.schema import SystemMessage,HumanMessage,AIMessage
from langchain.chains import LLMChain, ConversationChain
from langchain.chains.conversation.memory import ConversationSummaryBufferMemory
from langchain.callbacks import get_openai_callback

cred = credentials.Certificate(
    "path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
)
initialize_app(cred)
app = Flask(__name__)
CORS(app)


@https_fn.on_call(timeout_sec=180, memory=options.MemoryOption.MB_512)
def writeDiary(req: https_fn.CallableRequest):
    OPENAI_API_KEY = req.data["OPENAI_API_KEY"]
    userID = req.data["userID"]
    docId = req.data["docId"]
    date = req.data["date"]
    db = firestore.Client()

    # 중첩된 컬렉션과 문서에 접근
    log_ref = db.collection('user').document(userID).collection('chat').document(
        docId).collection('conversation').order_by('time', direction=firestore.Query.ASCENDING)
    log = ''
    docs = log_ref.stream()
    for doc in docs:
        if doc.to_dict()['userName'] == 'you':
            log += 'user : '+doc.to_dict()['text']+'\n'
        else:
            log += 'assistant : '+doc.to_dict()['text']+'\n'
    # print(log)

    # [일기 작성 관련 부분]
    # 일기 작성용 프롬프트 작성
    diary_prompt_ref = db.collection('prompt').document('diary')
    diary_prompt = diary_prompt_ref.get().to_dict()['prompt']
    # print(diary_prompt)

    # Langchain으로 일기 작성
    llm = ChatOpenAI(temperature=1, openai_api_key=OPENAI_API_KEY,
                     model_name='gpt-4', max_tokens=1024)
    llm_chain = LLMChain(
        llm=llm,
        prompt=PromptTemplate.from_template(diary_prompt)
    )
    diary = llm_chain(log)
    diary_text = diary['text']
    # print(diary['text'])

    # 챗봇 응답 나누기
    lines = diary_text.strip().split('\n')
    sections = {}
    for line in lines:
        key, value = line.split(']', 1)
        key = key[1:]  # Remove the opening '['
        sections[key] = value.strip()

    diary_title = sections['제목']
    diary_body = sections['내용']
    diary_advice = sections['조언']

    # [감정 분석 관련 부분]
    # 감정 분석용 프롬프트 작성
    sent_prompt_ref = db.collection('prompt').document('sentiment')
    sent_prompt = sent_prompt_ref.get().to_dict()['prompt']
    # print(sent_prompt)

    # Langchain으로 감정 분석
    llm = ChatOpenAI(temperature=0, openai_api_key=OPENAI_API_KEY,
                     model_name='gpt-4', max_tokens=1024)
    llm_chain = LLMChain(
        llm=llm,
        prompt=PromptTemplate.from_template(sent_prompt)
    )
    sent_raw = llm_chain(log)
    sent = re.findall(r'\d+', sent_raw['text'])
    # print(sent)

    # 감정 태그 추출    
    tags = ['total', '기쁨', '기대', '열정', '애정', '슬픔', '분노', '우울', '불쾌']
    sent_dict = dict((tags[i], sent[i]) for i in range(1, 10))
    sortedSent = sorted(sent_dict.items(), key=lambda x: x[1], reverse=True)

    # 최빈 태그 2개만 추출하는 코드
    max_val = sortedSent[0][1]
    temp = []
    diary_tags = []

    # 1차적으로 태그 추출
    if int(max_val) > 0:  # 혹시나 0개인 값 나오는 경우 제외
        for tag, val in sortedSent:
            if val == max_val:
                temp.append(tag)
    # print(temp)

    # 만약 그 결과가 2개 초과라면 2개 임의 추출
    if len(temp) > 2:
        diary_tags = random.sample(temp, 2)
    # 만약 그 결과가 2개라면 그대로 반환
    elif len(temp) == 2:
        diary_tags = temp
    # 나머지의 경우, 최빈 태그가 1개만 나왔다는 의미이다.
    else:
        max_val = sortedSent[1][1]
        if int(max_val) > 0:
            for tag, val in sortedSent[1:]:
                if val == max_val:
                    temp.append(tag)
        if len(temp) > 2:
            diary_tags = [sortedSent[0][0], random.sample(temp[1:], 1)[0]]
        else:
            diary_tags = temp

    # [출력부]
    # DB에 일기 작성
    sentiment = {
        'most': diary_tags,
        'total': int(sent[0]),
        '기쁨': int(sent[1]),
        '기대': int(sent[2]),
        '열정': int(sent[3]),
        '애정': int(sent[4]),
        '슬픔': int(sent[5]),
        '분노': int(sent[6]),
        '우울': int(sent[7]),
        '혐오': int(sent[8]),
        '중립': int(sent[9])
    }

    diary_ref = db.collection('user').document(
        userID).collection('diary').document(docId)
    diary_ref.set({
        'title': diary_title,
        'content': diary_body,
        'advice': diary_advice,
        'time': SERVER_TIMESTAMP,
        'sentiment': sentiment,
        'userID': userID,
        'date': date,
    })

    # DB에 감정 분석 기록
    sent_ref = db.collection('user').document(userID).collection('sentiment').document(date)
    sent_ref.set({"total": int(sent[0]), '기쁨':int(sent[1]), '기대':int(sent[2]),
                  '열정':int(sent[3]), '애정': int(sent[4]), '슬픔':int(sent[5]),
                  '분노':int(sent[6]), '우울': int(sent[7]), '불쾌':int(sent[8])})

    # Client에 넘겨줄 내용 정리
    result = {
        'title': diary_title,  # String
        'content': diary_body,  # String
        'advice': diary_advice,  # String
        'sentiment': sentiment  # Map
    }
    return {'body': result,  "statusCode": 200}

# Client 에서 받아야할 data
# userID = 'Puv6AjEOLTV5TsxTtVkCLCq961D3'
# docId = (firestore 자동생성 document id)
# chat_template = "You are user's close friend named '오하루' who is good at psychological counseling. You are chatting with your friend for Cognitive behavioural therapy in informal Korean. Respond within maximum 10 tokens. Respond in a friendly, gentle and sweet tone. If the user have a day, respond with empathy. If you know enough details of user's day, give advice. If your friend feel better, ask any positive questions. Use one appropriate emoticons in 30 percents of your total answers. When user expresses their interest, ask a detailed question about the topic. When answering, do not use the same expressions twice. Greet your friend first with 'How was your today?'. Current conversation: {history} user: {input} AI:"
# informal_template = "You have good comprehension in Korean if the sentence is informal.If {AIoutput} is formal Korean, change it into informal Korean:"
# #user_message = req.data['prompt']
# history = db.collection('user').document(userID).collection('chat').document(docId)['memory']
# cf) db = firestore.client()


@https_fn.on_call(timeout_sec=180, memory=options.MemoryOption.MB_512)
def ChatAI(req: https_fn.CallableRequest):

    # ID 토큰 가져오기 및 검증 추가
    id_token = request.headers.get("Authorization").split("Bearer ")[1]
    try:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token["uid"]
        print(uid)
    except ValueError:
        return {"body": "Unauthenticated", "statusCode": 401}

    OPENAI_API_KEY = req.data["OPENAI_API_KEY"]
    db = firestore.Client()
    userID = req.data["userID"]
    docId = req.data["docId"]
    user_message = req.data["prompt"]  # 사용자 입력값

    openai.api_key = OPENAI_API_KEY

    # prompt_content(all)
    chat_template = req.data["chat_template"]
    informal_template = req.data['informal_template']

    # 이전 대화 내용
    memory = db.collection('user').document(
        userID).collection('chat').document(docId).get()
    memory_ref = db.collection('user').document(
        userID).collection('chat').document(docId)

    history = memory.to_dict().get(
        'memory', [{'role': 'system', 'content': chat_template}])

    history.append({"role": "user", "content": user_message})
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=history,
        temperature=1
    )
    final_AI = response.choices[0].message["content"]
    history.append({"role": "assistant", "content": final_AI})
    memory_ref = db.collection('user').document(
        userID).collection('chat').document(docId)
    memory_ref.set({'memory': history}, merge=True)
    # AI 답변도 DB로 저장
    data = {
        "text": final_AI,
        "time": SERVER_TIMESTAMP,
        'userID': "gpt-3.5-turbo",
        "userName": "오하루",
        "userImage": "https://firebasestorage.googleapis.com/v0/b/haru-s-diary.appspot.com/o/picked_image%2Fgpt-3.5-turbo.png?alt=media&token=684e0b0e-3bc0-41c9-b6e1-412a7b02d1ed",    # 테스트 위해 하드코딩
    }
    conversation_ref = db.collection('user').document(userID).collection(
        'chat').document(docId).collection('conversation').add(data)

    return {'body': final_AI,  "statusCode": 200}
