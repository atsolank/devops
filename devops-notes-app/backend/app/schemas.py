from pydantic import BaseModel

class UserCreate(BaseModel):
    username: str
    password: str

class NoteCreate(BaseModel):
    title: str
    content: str
