from firebase_functions import https_fn, options
from firebase_admin import initialize_app, auth, credentials, firestore
from flask import Flask, request
from flask_cors import CORS
from google.cloud import firestore

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


# Load .env file
load_dotenv()
OPENAI_API_KEY=os.getenv('GPT_API_KEY')

# current_script_directory = os.path.dirname(os.path.abspath(__name__))

# # 서비스 계정 키 파일의 상대 경로
# relative_path_to_keyfile = "haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"

# # 서비스 계정 키 파일을 포함한 전체 경로
# keyfile_path = os.path.join(current_script_directory, relative_path_to_keyfile)

# # credentials.Certificate()로 Firebase Admin SDK 초기화
# cred = credentials.Certificate(keyfile_path)

cred = credentials.Certificate(
    "funtions/path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
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
    diary_ref.set({"content": diary['text'], "time":Timestamp.now(), 'userID': userID})

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
    sent_ref.set({"content": sent['text'], "time":Timestamp.now(), 'userID': userID})

    

# Chat
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
    
    db = firestore.Client()
    uid = req.auth.uid
    chat_ref = db.collection("user").document(uid).collection('chat')
    chat_message = chat_ref.document("20230908").collection("conversation").orderBy("time", "asc")
    conversations = chat_message.stream()
    history = ""
    for conversation in conversations:
        if conversation.to_dict()['userName'] == '오하루':
            text = conversation.to_dict().get("text", "")
            history += f"AI: {text}\n"
        else : 
            text = conversation.to_dict().get("text", "")
            history += f"user: {text}\n"
    
    api_key = req.data["api_key"]
    prompt = req.data["prompt"] # ???? 내용이 확인이 안됨

    ## chat-langchain
    chat = ChatOpenAI(
    openai_api_key=api_key,
    temperature=1,
    model='gpt-3.5-turbo'
    )
    chat_template = db.collection('prompt').document('chat')
    chat_prompt = PromptTemplate(input_variables=['history', 'input'], template=chat_template)
    conversation = ConversationChain(
    prompt=chat_prompt,
    llm=chat,
    memory=ConversationSummaryBufferMemory(llm=chat),
    output_key="AIoutput"
    )
    
    ## 반말로 output 고정
    informal_korean = ChatOpenAI(
    openai_api_key=OPENAI_API_KEY,
    temperature=1,
    model='gpt-3.5-turbo'
    )

    informal_template = db.collection('prompt').document('informal')
    PROMPT_informal = PromptTemplate(input_variables=['AIoutput'], template=informal_template)
    informal_output = LLMChain(
    prompt=PROMPT_informal,
    llm = informal_korean,
    )

    ### chain+model 실행 -> return 값
    user_meg = req.data.get("text", "")
    response = conversation.run({
    'history': history,
    'input': user_meg
    })
    final_output = informal_output.run(response)
    return {"body": final_output, "statusCode": 200}
    




    # # langchain 사용 코드
    # llm = ChatOpenAI(openai_api_key=api_key, temperature=1)
    # body = llm(prompt)

    # # .......

    # return {"body": body, "statusCode": 200}


@https_fn.on_request(
    cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"])
)
def requestOpenAI(req: https_fn.Request) -> https_fn.Response:
    data = request.json

    api_key = data.get("api_key")
    prompt = data.get("prompt")

    llm = OpenAI(openai_api_key=api_key, temperature=0.9)

    return https_fn.Response(f"{llm(prompt)}")
