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

cred = credentials.Certificate(
    "path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
)
initialize_app(cred)
app = Flask(__name__)
CORS(app)
sent_endpoint = 'pytorch-inference-2023-10-03-11-00-58-994'

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

    # OPENAI_API_KEY = req.data["OPENAI_API_KEY"]
    db = firestore.Client()
    os.environ['encrypted_api_key'] = db.collection('config').document('gpt_api_key').get().to_dict()["value"]
    OPENAI_API_KEY = cipher.decrypt(os.environ.get('encrypted_api_key'))
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

    timestamp = SERVER_TIMESTAMP    # 마지막 메세지 시간 chat 문서에 기록

    final_AI = response.choices[0].message["content"]
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
