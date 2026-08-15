from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.config import get_settings
from app.database import get_db

router = APIRouter(tags=["health"])
settings = get_settings()


@router.get("/health")
def health(db: Session = Depends(get_db)) -> dict:
    db_ok = False
    try:
        db.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        db_ok = False

    return {
        "status": "ok" if db_ok else "degraded",
        "app": settings.app_name,
        "version": settings.version,
        "environment": settings.environment,
        "database": "connected" if db_ok else "unavailable",
    }
