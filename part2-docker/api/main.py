from fastapi import FastAPI

app = FastAPI(title="DevOps Exam API", version="1.0.0")


@app.get("/healthz")
def health():
    return {"status": "healthy", "service": "api-app"}


@app.get("/")
def root():
    return {"message": "FastAPI running in Docker container"}
