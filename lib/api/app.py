from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Test(BaseModel):
    text: list

@app.post("/test")  # URL
async def testCase(request: Test):
    processed_text = []
    newline="\n"
    for i in request.text:
        processed_text.append(i)
        processed_text.append(newline)
    return {"input": processed_text}



# class Test(BaseModel):
#     text: str

# @app.post("/test")  # URL
# async def testCase(request: Test):
#     input_text = request.text
#     return {"input": input_text}