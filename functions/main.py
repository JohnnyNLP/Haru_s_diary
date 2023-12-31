# 서버 관련
from firebase_functions import https_fn, options
import firebase_admin
from firebase_admin import initialize_app, auth, credentials, firestore as _firestore
from flask import Flask, request
from flask_cors import CORS
from google.cloud import firestore
from google.cloud.firestore import SERVER_TIMESTAMP
from google.oauth2.credentials import Credentials


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

#fine-tune gpt3.5
import requests
import json



# 암호화 키 및 모듈
from base64 import b64encode, b64decode
from Crypto.Cipher import AES
class AESCipher:
    def __init__(self, key):
        self.key = key

    def encrypt(self, data):
        cipher = AES.new(self.key, AES.MODE_EAX)
        nonce = cipher.nonce
        ciphertext, tag = cipher.encrypt_and_digest(data.encode())
        return b64encode(nonce + ciphertext).decode('utf-8')

    def decrypt(self, enc_data):
        enc_data_bytes = b64decode(enc_data)
        nonce = enc_data_bytes[:16]
        ciphertext = enc_data_bytes[16:]
        cipher = AES.new(self.key, AES.MODE_EAX, nonce=nonce)
        return cipher.decrypt(ciphertext).decode('utf-8')
    
cipher = AESCipher(b64decode('piffLjlaeioC7UmcOhEBTdqnaYih3QPXtgV80Q+iFHE='))


if __name__ == '__main__':
    # cred = credentials.Certificate(
    #     "functions/path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
    # )
    # firebase_admin.initialize_app(cred)
    # db = _firestore.client()
    pass
else:
    cred = credentials.Certificate(
        "path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
    )
    initialize_app(cred)
    app = Flask(__name__)
    CORS(app)
    sent_endpoint = 'pytorch-inference-2023-10-03-11-00-58-994'



@https_fn.on_call(timeout_sec=180, memory=options.MemoryOption.MB_512)
def writeDiary(req: https_fn.CallableRequest):

    # ID 토큰 가져오기 및 검증 추가
    id_token = request.headers.get("Authorization").split("Bearer ")[1]
    try:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token["uid"]
        print(uid)
    except ValueError:
        return {"body": "Unauthenticated", "statusCode": 401}
    
    # OPENAI_API_KEY = req.data["OPENAI_API_KEY"]
    db = firestore.Client()
    os.environ['encrypted_api_key'] = db.collection('config').document('gpt_api_key').get().to_dict()["value"]
    OPENAI_API_KEY = cipher.decrypt(os.environ.get('encrypted_api_key'))
    userID = req.data["userID"]
    docId = req.data["docId"]
    date = req.data["date"]

    # 중첩된 컬렉션과 문서에 접근
    log_ref = db.collection('user').document(userID).collection('chat').document(
        docId).collection('conversation').order_by('time', direction=firestore.Query.ASCENDING)
    log = ''
    docs = log_ref.get()
    last_message_time = docs[-1].to_dict()['time']
    
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
    print(sent)

    # KoBERT로 감정 분석
    # sagemaker_session = Session()
    # endpoint_name = sent_endpoint
    # runtime_client = boto3.client('sagemaker-runtime')

    # sample_data = {
    #     "conversations": [
    #         {"userName": "user1", "text": "안녕, 오늘은 아침 일찍부터 회의가 잡혔어."},
    #         {"userName": "오하루", "text": "앗, 일찍부터 회의라니 힘들었겠다. 회의는 잘 진행됐어?"},
    #         {"userName": "user1", "text": "지금 멘토님한테 결과물을 확인받고 있어."},
    #         {"userName": "오하루", "text": "멘토님한테 결과물을 확인받는 건 항상 긴장되지 않아? 어떤 피드백을 받았는지 궁금해!"},
    #         {"userName": "user1", "text": "뭔가 긴장되네 잘 됐으면 좋겠다."},
    #         {"userName": "오하루", "text": "긴장되는 건 당연한 일이야. 그럴 때는 좀 더 마음을 편하게 해줄 수 있는 것이 있을까? 예를 들면, 좋아하는 음악을 들으며 조금 쉬어가는 것이 어때?"},
    #         {"userName": "user1", "text": "오늘 아침에 내가 뭐했다고 했지?"},
    #         {"userName": "오하루", "text": "아침에 일찍 회의가 잡혀있어서 많이 바쁘고 힘들었지? 그래서 피곤한 마음이야. 좀 더 편안한 마음을 갖을 수 있는 시간을 가져보는 건 어때?"},
    #     ]
    # }

    # response = runtime_client.invoke_endpoint(
    #     EndpointName=endpoint_name,
    #     ContentType="application/json",
    #     Body=json.dumps(sample_data),
    # )
    # result = response['Body'].read().decode('utf-8')
    # sent = re.findall(r'\d+', result)

    # 감정 태그 추출
    tags = ['total', '기쁨', '기대', '열정', '애정', '슬픔', '분노', '우울', '불쾌']
    sent_dict = dict((tags[i], sent[i]) for i in range(1, 9))
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
    sentiment = {'most': diary_tags,
                 'total': int(sent[0]), '기쁨': int(sent[1]), '기대': int(sent[2]),
                 '열정': int(sent[3]), '애정': int(sent[4]), '슬픔': int(sent[5]),
                 '분노': int(sent[6]), '우울': int(sent[7]), '불쾌': int(sent[8])}

    diary_ref = db.collection('user').document(
        userID).collection('diary').document(docId)
    diary_ref.set({
        'title': diary_title,
        'content': diary_body,
        'advice': diary_advice,
        'time': SERVER_TIMESTAMP,
        'last_message_time': last_message_time,
        'sentiment': sentiment,
        'userID': userID,
        'date': date,
    })

    # DB에 감정 분석 기록
    # sent_ref = db.collection('user').document(
    #     userID).collection('sentiment').document(date)
    # sent_ref.set({"total": int(sent[0]), '기쁨': int(sent[1]), '기대': int(sent[2]),
    #               '열정': int(sent[3]), '애정': int(sent[4]), '슬픔': int(sent[5]),
    #               '분노': int(sent[6]), '우울': int(sent[7]), '불쾌': int(sent[8])})

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
    userID = req.data["userID"]
    docId = req.data["docId"]
    chat_template = req.data["chat_template"]

    # OPENAI_API_KEY = req.data["OPENAI_API_KEY"]
    db = firestore.Client()
    
    chats = db.collection("user").document(userID).collection("chat").get()
    conversations = db.collection('user').document(userID).collection('chat').document(docId).collection("conversation").get()

    HelloGPTAPI = db.collection("config").document("HelloGPTAPI").get().to_dict()['value']
    # 파인튜닝 GPT 모델
    url = "https://api.openai.com/v1/chat/completions"
        # 헤더 설정
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {HelloGPTAPI}"
    }
    fine_tuned_ref = db.collection('prompt').document('HelloChat').get()
    fine_tuned_model = fine_tuned_ref.to_dict().get("model")
    fine_tuned_prompt = fine_tuned_ref.to_dict().get("prompt")

    # latest_diary = db.collection('user').document(userID).collection('diary').order_by('last_message_time', direction=firestore.Query.DESCENDING).limit(1).get()
    # latest_diary[0].to_dict()['sentiment']['most'] if latest_diary else []
    # sent_info = latest_diary[0].to_dict()['sentiment']['most'] if latest_diary else []
    # print(f'len(chats): {len(chats)}')
    # print(f'len(conversations): {len(conversations)}')
    # print(f'sent_info: {sent_info}')
    # return {'body': 'aaaa',  "statusCode": 200}

    final_AI = ''
    history = [{'role': 'system', 'content': chat_template}]

    if len(chats) == 1 and len(conversations) == 0:
        print("신규")
        openai.api_key = HelloGPTAPI
        
        # 요청 바디 데이터 설정
        payload = {
            "model": fine_tuned_model,
            "messages": [
                {
                    "role": "system",
                    "content": fine_tuned_prompt
                },
                {
                    "role": "user",
                    "content": "안녕. (이전감정: 없음)"
                }
            ]
        }

        # API 요청 보내기
        response = requests.post(url, headers=headers, data=json.dumps(payload))
        if response.status_code == 200:
            final_AI = response.json()['choices'][0]['message']['content']
        else: 
            final_AI = "안녕, 나는 너의 친구 '오하루'야. 힘든 일이나 고민이 있으면 언제든지 나에게 말해줘. 너의 하루를 더 행복하게 만들 수 있도록 도와줄게. 오늘은 어떤 하루를 보냈니?"
    elif len(conversations) == 0: # 대화 시작
        print("새대화")
        latest_diary = db.collection('user').document(userID).collection('diary').order_by('last_message_time', direction=firestore.Query.DESCENDING).limit(1).get()
        latest_diary[0].to_dict()['sentiment']['most'] if latest_diary else []
        sent_info = latest_diary[0].to_dict()['sentiment']['most'] if latest_diary else []
        print(f'sent_info:{sent_info}')
        sent_str = ', '.join(sent_info) if sent_info else '없음'
        user_input = f'안녕. (이전감정: {sent_str})'
        openai.api_key = HelloGPTAPI
        payload = {
            "model": fine_tuned_model,
            "messages": [
                {
                    "role": "system",
                    "content": fine_tuned_prompt
                },
                {
                    "role": "user",
                    "content": user_input
                }
            ]
        }
        # API 요청 보내기
        response = requests.post(url, headers=headers, data=json.dumps(payload))
        if response.status_code == 200:
            final_AI = response.json()['choices'][0]['message']['content']
        else: 
            final_AI = "안녕, 오늘은 어떤 하루를 보냈어?"
    else: # 대화 중
        print("대화중")
        os.environ['encrypted_api_key'] = db.collection('config').document('gpt_api_key').get().to_dict()["value"]
        OPENAI_API_KEY = cipher.decrypt(os.environ.get('encrypted_api_key'))
        user_message = req.data["prompt"]  # 사용자 입력값
        openai.api_key = OPENAI_API_KEY

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


    timestamp = SERVER_TIMESTAMP
    print('final_AI: {final_AI}')
    history.append({"role": "assistant", "content": final_AI})
    
    memory_ref = db.collection('user').document(
        userID).collection('chat').document(docId)
    memory_ref.set({'memory': history, 'lastTime': timestamp}, merge=True)

    # AI 답변도 DB로 저장
    data = {
        "text": final_AI,
        "time": timestamp,
        'userID': "gpt-3.5-turbo",
        "userName": "오하루",
        "userImage": "https://firebasestorage.googleapis.com/v0/b/haru-s-diary.appspot.com/o/picked_image%2Fgpt-3.5-turbo.png?alt=media&token=684e0b0e-3bc0-41c9-b6e1-412a7b02d1ed",    # 테스트 위해 하드코딩
    }
    conversation_ref = db.collection('user').document(userID).collection(
        'chat').document(docId).collection('conversation').add(data)

    return {'body': final_AI,  "statusCode": 200}
