from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Message": "Hello Guys welcome in the world of Docker & Serverless Container!"}

@app.get("/items")
def create_items():
    return {"Message" : "Item Created"}