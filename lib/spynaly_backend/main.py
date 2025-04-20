from fastapi import FastAPI
from devices import get_user_devices

app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "SpyNaly backend is running"}

@app.get("/devices/{user_id}")
def get_devices(user_id: str):
    return get_user_devices(user_id)
