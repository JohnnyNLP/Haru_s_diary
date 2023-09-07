from firebase_functions import https_fn, options
from firebase_admin import initialize_app, auth, credentials, firestore
from flask import Flask, request
from flask_cors import CORS
from langchain.llms import OpenAI

cred = credentials.Certificate(
    "functions/path/to/haru-s-diary-firebase-adminsdk-jom67-47ca164d79.json"
)
initialize_app(cred)
app = Flask(__name__)
CORS(app)


# 로컬 테스트용
if __name__ == "__main__":
    # db 접속
    db = firestore.client()

    # 문서 경로 지정
    doc_ref = db.collection("user").document("localTest")

    # 데이터 쓰기
    doc_ref.set({"field_name": "value", "another_field": 123})

    # 데이터 읽기
    doc = doc_ref.get()
    if doc.exists:
        print(doc._data)
    else:
        print("Document not found")


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
