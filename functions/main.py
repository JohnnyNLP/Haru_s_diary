from firebase_functions import https_fn, options
from firebase_admin import initialize_app, auth, credentials, firestore
from flask import Flask, request
from flask_cors import CORS
from datetime import datetime

# 환경 변수
from dotenv import load_dotenv
import os

# LLM 관련
import openai
from langchain.chains import LLMChain
from langchain.llms import OpenAI
from langchain.chat_models import ChatOpenAI
from langchain.prompts import PromptTemplate

# Load .env file
load_dotenv()
OPENAI_API_KEY=os.getenv('GPT_API_KEY')
cred = credentials.Certificate(
    "functions/path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
)
initialize_app(cred)
app = Flask(__name__)
CORS(app)

# 유저 ID 및 날짜 받아오는 부분
userID = 'FQgUM4cbV8hSAzqc9XiPrDh5SGm2'
date = '20230907'

# 로컬 테스트용 - 일기 작성
if __name__ == "__main__":
    # db 접속
    db = firestore.client()

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
    diary_ref.set({"content": diary['text'], "time":datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'userID': userID})

# 로컬 테스트용 - 감정 분석
if __name__ == "__main__":
    # db 접속
    db = firestore.client()

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
    sent_ref.set({"content": sent['text'], "time":datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'userID': userID})

    



@https_fn.on_call()
def defaultOpenAI(req: https_fn.CallableRequest):
    # ID 토큰 가져오기
    # id_token = request.headers.get("Authorization").split("Bearer ")[1]
    # ID 토큰 검증
    # try:
    #     decoded_token = auth.verify_id_token(id_token)
    #     uid = decoded_token["uid"]
    # except ValueError:
    #     return {"body": "Unauthenticated", "statusCode": 401}

    # 클라이어트 요청에서 받아온 데이터
    api_key = req.data["api_key"]
    prompt = req.data["prompt"]

    # langchain 사용 코드
    llm = OpenAI(openai_api_key=api_key, temperature=0.9)
    body = llm(prompt)

    # .......

    return {"body": body, "statusCode": 200}


@https_fn.on_request(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"])
)
def requestOpenAI(req: https_fn.Request) -> https_fn.Response:
    data = request.json

    api_key = data.get("api_key")
    prompt = data.get("prompt")

    llm = OpenAI(openai_api_key=api_key, temperature=0.9)

    return https_fn.Response(f"{llm(prompt)}")
