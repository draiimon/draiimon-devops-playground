from fastapi import FastAPI
import os
import socket

app = FastAPI(title="DevOps Exam API", version="1.0.0")
INSTANCE_ID = os.getenv("POD_NAME") or socket.gethostname()


@app.get("/healthz")
def health():
    return {"status": "healthy", "service": "api-app", "instance": INSTANCE_ID}


@app.get("/")
def root():
    return {"message": "FastAPI running in Docker container"}


@app.get("/instance")
def instance():
    return {"instance": INSTANCE_ID}
