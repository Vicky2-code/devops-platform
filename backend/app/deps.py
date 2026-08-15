from collections.abc import Generator

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app import models
from app.config import get_settings
from app.database import get_db
from app.security import decode_access_token

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/auth/login")
settings = get_settings()


def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db),
) -> models.User:
    credentials_exc = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = decode_access_token(token)
    except jwt.PyJWTError:
        raise credentials_exc from None

    user_id = payload.get("sub")
    if user_id is None:
        raise credentials_exc

    user = db.get(models.User, int(user_id))
    if user is None or not user.is_active:
        raise credentials_exc
    return user


def get_db_dep() -> Generator:
    """Typed alias so routers can annotate Session cleanly."""
    yield from get_db()  # pragma: no cover - thin wrapper
