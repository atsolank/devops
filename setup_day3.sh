#!/bin/bash

# Root directory
mkdir -p devops-notes-app
cd devops-notes-app || exit

#####################################
# Backend
#####################################
mkdir -p backend/app/routes

# Python files
cat > backend/app/__init__.py <<'EOF'
# Init file
EOF

cat > backend/app/main.py <<'EOF'
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
EOF

cat > backend/app/database.py <<'EOF'
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import os

DATABASE_URL = f"postgresql://{os.getenv('POSTGRES_USER', 'postgres')}:" \
               f"{os.getenv('POSTGRES_PASSWORD', 'postgres')}@" \
               f"{os.getenv('POSTGRES_HOST', 'db')}:" \
               f"5432/{os.getenv('POSTGRES_DB', 'notesdb')}"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
EOF

cat > backend/app/models.py <<'EOF'
from sqlalchemy import Column, Integer, String, ForeignKey, Text, DateTime
from sqlalchemy.sql import func
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    password = Column(String)

class Note(Base):
    __tablename__ = "notes"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String)
    content = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
EOF

cat > backend/app/schemas.py <<'EOF'
from pydantic import BaseModel

class UserCreate(BaseModel):
    username: str
    password: str

class NoteCreate(BaseModel):
    title: str
    content: str
EOF

cat > backend/app/auth.py <<'EOF'
# Simple placeholder auth file
def fake_hash_password(password: str):
    return "hashed_" + password
EOF

# Routes
cat > backend/app/routes/__init__.py <<'EOF'
# Init file
EOF

cat > backend/app/routes/user_routes.py <<'EOF'
from fastapi import APIRouter

router = APIRouter()

@router.post("/register")
def register_user():
    return {"message": "User registered"}

@router.post("/login")
def login_user():
    return {"message": "User logged in"}
EOF

cat > backend/app/routes/notes_routes.py <<'EOF'
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import database, models

router = APIRouter()

@router.get("/")
def get_notes(db: Session = Depends(database.SessionLocal)):
    return db.query(models.Note).all()
EOF

# Requirements
cat > backend/requirements.txt <<'EOF'
fastapi
uvicorn[standard]
sqlalchemy
psycopg2-binary
python-dotenv
EOF

# Environment file
cat > backend/.env <<'EOF'
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=notesdb
POSTGRES_HOST=db
EOF

#####################################
# Frontend
#####################################
mkdir -p frontend/public frontend/src/components

# React basics
cat > frontend/package.json <<'EOF'
{
  "name": "notes-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  }
}
EOF

cat > frontend/public/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <title>Notes App</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF

cat > frontend/src/index.js <<'EOF'
import React from "react";
import ReactDOM from "react-dom";
import App from "./App";

ReactDOM.render(<App />, document.getElementById("root"));
EOF

cat > frontend/src/App.js <<'EOF'
import React from "react";
import Notes from "./components/Notes";
import Login from "./components/Login";
import Register from "./components/Register";

function App() {
  return (
    <div>
      <h1>Notes App</h1>
      <Register />
      <Login />
      <Notes />
    </div>
  );
}

export default App;
EOF

cat > frontend/src/api.js <<'EOF'
const API_URL = process.env.REACT_APP_API_URL || "http://localhost:8000/api";

export async function fetchNotes() {
  const res = await fetch(\`\${API_URL}/notes\`);
  return res.json();
}
EOF

# Components
cat > frontend/src/components/Login.js <<'EOF'
import React from "react";

function Login() {
  return (
    <div>
      <h2>Login</h2>
      <form>
        <input placeholder="Username" />
        <input placeholder="Password" type="password" />
        <button type="submit">Login</button>
      </form>
    </div>
  );
}

export default Login;
EOF

cat > frontend/src/components/Register.js <<'EOF'
import React from "react";

function Register() {
  return (
    <div>
      <h2>Register</h2>
      <form>
        <input placeholder="Username" />
        <input placeholder="Password" type="password" />
        <button type="submit">Register</button>
      </form>
    </div>
  );
}

export default Register;
EOF

cat > frontend/src/components/Notes.js <<'EOF'
import React, { useEffect, useState } from "react";
import { fetchNotes } from "../api";

function Notes() {
  const [notes, setNotes] = useState([]);

  useEffect(() => {
    fetchNotes().then(setNotes);
  }, []);

  return (
    <div>
      <h2>Notes</h2>
      <ul>
        {notes.map((note) => (
          <li key={note.id}>{note.title}: {note.content}</li>
        ))}
      </ul>
    </div>
  );
}

export default Notes;
EOF

#####################################
# Database
#####################################
mkdir -p db
cat > db/init.sql <<'EOF'
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS notes (
  id SERIAL PRIMARY KEY,
  user_id INT REFERENCES users(id),
  title VARCHAR(255),
  content TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);
EOF

#####################################
# Docker Compose
#####################################
cat > docker-compose.yml <<'EOF'
version: "3.8"
services:
  backend:
    build: ./backend
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    ports:
      - "8000:8000"
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=notesdb
      - POSTGRES_HOST=db
    depends_on:
      - db

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8000/api
    depends_on:
      - backend

  db:
    image: postgres:14
    restart: always
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: notesdb
    volumes:
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
    ports:
      - "5432:5432"
EOF

#####################################
# README
#####################################
cat > README.md <<'EOF'
# DevOps Notes App (Day 3)

This is a 3-tier application (React + FastAPI + Postgres).

## Run locally

```bash
docker-compose up --build
EOF
