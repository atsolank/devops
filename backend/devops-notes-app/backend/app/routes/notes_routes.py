from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from .. import database, models

router = APIRouter()

@router.get("/")
def get_notes(db: Session = Depends(database.SessionLocal)):
    return db.query(models.Note).all()
