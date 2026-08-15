from fastapi import APIRouter, Depends

from app import schemas
from app.deps import get_current_user

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=schemas.UserOut)
def me(user: schemas.UserOut = Depends(get_current_user)) -> schemas.UserOut:
    return user
