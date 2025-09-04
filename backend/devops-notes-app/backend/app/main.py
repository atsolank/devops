from fastapi import FastAPI
from .routes import user_routes, notes_routes
from .database import engine, Base

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.include_router(user_routes.router, prefix="/api/users", tags=["Users"])
app.include_router(notes_routes.router, prefix="/api/notes", tags=["Notes"])

@app.get("/")
def root():
    return {"message": "Notes API running!"}
