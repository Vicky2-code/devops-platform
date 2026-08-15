from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import get_db
from app.deps import get_current_user
from app.routers.projects import _get_owned_project

router = APIRouter(prefix="/projects/{project_id}/environments", tags=["environments"])


@router.get("", response_model=list[schemas.EnvironmentOut])
def list_environments(
    project_id: int,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    _get_owned_project(db, project_id, user)
    return db.execute(
        select(models.Environment)
        .where(models.Environment.project_id == project_id)
        .order_by(models.Environment.id)
    ).scalars().all()


@router.post("", response_model=schemas.EnvironmentOut, status_code=status.HTTP_201_CREATED)
def create_environment(
    project_id: int,
    payload: schemas.EnvironmentCreate,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    _get_owned_project(db, project_id, user)
    env = models.Environment(project_id=project_id, **payload.model_dump())
    db.add(env)
    db.commit()
    db.refresh(env)
    return env


@router.delete("/{environment_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_environment(
    project_id: int,
    environment_id: int,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    _get_owned_project(db, project_id, user)
    env = db.get(models.Environment, environment_id)
    if env is None or env.project_id != project_id:
        raise HTTPException(status_code=404, detail="Environment not found")
    db.delete(env)
    db.commit()
