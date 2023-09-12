from firebase_functions import https_fn, options
from firebase_admin import initialize_app, auth, credentials, firestore
from flask import Flask, request
from flask_cors import CORS
from google.cloud import firestore
from google.cloud.firestore import SERVER_TIMESTAMP

# 환경 변수
from dotenv import load_dotenv
import os

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

@https_fn.on_call()
def writeDiary(req: https_fn.CallableRequest):
    OPENAI_API_KEY=req.data["OPENAI_API_KEY"]
    userID = req.data["userID"] 
    date = req.data["date"] 
    db = firestore.Client()

    # 중첩된 컬렉션과 문서에 접근
    log_ref = db.collection('user').document(userID).collection('chat').document(date).collection('conversation').order_by('time', direction=firestore.Query.ASCENDING)

    # 일기 작성용 프롬프트 작성
    diary_prompt_ref = db.collection('prompt').document('diary')
    diary_prompt = diary_prompt_ref.get().to_dict()['prompt']
    #print(diary_prompt)

    # 일기 작성 위한 로그 수집
    log = ''
    docs = log_ref.stream()
    for doc in docs:
        if doc.to_dict()['userName'] == 'you':
            log += 'user : '+doc.to_dict()['text']+'\n'
        else :
            log += 'assistant : '+doc.to_dict()['text']+'\n'
    #print(log)

    # Langchain으로 일기 작성
    llm = ChatOpenAI(temperature=1, openai_api_key=OPENAI_API_KEY, model_name='gpt-4', max_tokens=1024)
    llm_chain = LLMChain(
        llm = llm,
        prompt = PromptTemplate.from_template(diary_prompt)
    )
    diary = llm_chain(log)
    #print(diary['text'])

    # 일기 작성 함수 호출 => diary_prompt+log
    diary_ref = db.collection('user').document(userID).collection('diary').document(date)
    diary_ref.set({"content": diary['text'], "time":SERVER_TIMESTAMP, 'userID': userID})

@https_fn.on_call()
def sentAnal(req: https_fn.CallableRequest):
    OPENAI_API_KEY=req.data["OPENAI_API_KEY"]
    userID = req.data["userID"] 
    date = req.data["date"] 
    db = firestore.Client()

    # 중첩된 컬렉션과 문서에 접근
    log_ref = db.collection('user').document(userID).collection('chat').document(date).collection('conversation').order_by('time', direction=firestore.Query.ASCENDING)

    # 감정 분석용 프롬프트 작성
    sent_prompt_ref = db.collection('prompt').document('sentiment')
    sent_prompt = sent_prompt_ref.get().to_dict()['prompt']
    # print(sent_prompt)

    # 감정 분석 위한 로그 수집
    log = ''
    docs = log_ref.stream()
    for doc in docs:
        if doc.to_dict()['userName'] == 'you':
            log += 'user : '+doc.to_dict()['text']+'\n'
        else :
            log += 'assistant : '+doc.to_dict()['text']+'\n'
    # print(log)

    # Langchain으로 감정 분석
    llm = ChatOpenAI(temperature=0, openai_api_key=OPENAI_API_KEY, model_name='gpt-4', max_tokens=1024)
    llm_chain = LLMChain(
        llm = llm,
        prompt = PromptTemplate.from_template(sent_prompt)
    )
    sent = llm_chain(log)
    # print(sent['text'])

    # 일기 작성 함수 호출 => diary_prompt+log
    sent_ref = db.collection('user').document(userID).collection('sentiment').document(date)
    sent_ref.set({"content": sent['text'], "time":SERVER_TIMESTAMP, 'userID': userID})

### Client 에서 받아야할 data
# userID = 'Puv6AjEOLTV5TsxTtVkCLCq961D3'
# date = '20230909'
# chat_template = "You are user's close friend named '오하루' who is good at psychological counseling. You are chatting with your friend for Cognitive behavioural therapy in informal Korean. Respond within maximum 10 tokens. Respond in a friendly, gentle and sweet tone. If the user have a day, respond with empathy. If you know enough details of user's day, give advice. If your friend feel better, ask any positive questions. Use one appropriate emoticons in 30 percents of your total answers. When user expresses their interest, ask a detailed question about the topic. When answering, do not use the same expressions twice. Greet your friend first with 'How was your today?'. Current conversation: {history} user: {input} AI:"
# informal_template = "You have good comprehension in Korean if the sentence is informal.If {AIoutput} is formal Korean, change it into informal Korean:"
# #user_message = req.data['prompt']
# history = db.collection('user').document(userID).collection('chat').document(date)['memory']
# cf) db = firestore.client()
@https_fn.on_call()
def ChatAI(req: https_fn.CallableRequest):

    # ID 토큰 가져오기 및 검증 추가
    id_token = request.headers.get("Authorization").split("Bearer ")[1]
    try:
        decoded_token = auth.verify_id_token(id_token)
        uid = decoded_token["uid"]
        print(uid)
    except ValueError:
        return {"body": "Unauthenticated", "statusCode": 401}
    
    OPENAI_API_KEY=req.data["OPENAI_API_KEY"]
    db = firestore.Client()
    userID = req.data["userID"] 
    date = req.data["date"] 
    user_message = req.data["prompt"] # 사용자 입력값

    # prompt_content(all)
    chat_template = req.data["chat_template"] 
    informal_template = req.data['informal_template'] 

    # memory
    memory = db.collection('user').document(userID).collection('chat').document(date).get()
    # memory 데이터 필드 null 체크 추가
    history = memory.to_dict()['memory'] if memory.exists else ''

    # LLM
    chat = ChatOpenAI(
    openai_api_key=OPENAI_API_KEY,
    temperature=1,
    model='gpt-3.5-turbo'
    )
    informal_korean = ChatOpenAI(
    openai_api_key=OPENAI_API_KEY,
    temperature=1,
    model='gpt-3.5-turbo'
    )
    memory_LLM = ConversationSummaryBufferMemory(llm=chat, max_token_limit=40)

    # Prompt
    PROMPT_chat = PromptTemplate(input_variables=['history', 'input'], template=chat_template)
    PROMPT_informal = PromptTemplate(input_variables=['AIoutput'], template=informal_template)

    # Chain
    conversation = ConversationChain(
    prompt=PROMPT_chat,
    llm = chat,
    memory = memory_LLM,
    output_key="AIoutput",
    verbose=True
    )
    informal_output = LLMChain(
        prompt=PROMPT_informal,
        llm = informal_korean,
        output_key="final_output",
        verbose=True
    )   

    # AI 답변 생성
    final_AI = informal_output.run(conversation.run({'input': history + "Human:" + user_message})) 
    
    # DB로 저장되어야 하는 데이터
    memory_ref = db.collection('user').document(userID).collection('chat').document(date)
    new_history = memory_LLM.load_memory_variables({})['history']
    memory_ref.set({"memory": new_history})
    # AI 답변도 DB로 저장
    data = {
        "text":final_AI,
        "time":SERVER_TIMESTAMP,
        'userID': "gpt-3.5-turbo",
        "userName": "오하루"
        }
    conversation_ref = db.collection('user').document(userID).collection('chat').document(date).collection('conversation').add(data)

    return {'body' : final_AI,  "statusCode": 200}
