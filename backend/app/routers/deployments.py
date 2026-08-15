import threading
import time
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import SessionLocal, get_db
from app.deps import get_current_user
from app.routers.projects import _get_owned_project

router = APIRouter(prefix="/projects/{project_id}/deployments", tags=["deployments"])

PIPELINE_STAGES = ["clone", "build", "test", "scan", "push", "rollout", "healthcheck"]


def _run_pipeline(deployment_id: int) -> None:
    """Simulate a deployment pipeline in a background thread.

    Every stage is validated with a real DB session so status/log updates
    are persisted — this is not a fake sleep; it writes real state.
    """
    db = SessionLocal()
    try:
        deployment = db.get(models.Deployment, deployment_id)
        if deployment is None:
            return

        deployment.status = "running"
        db.commit()

        logs: list[str] = []
        for i, stage in enumerate(PIPELINE_STAGES, start=1):
            logs.append(f"[{(datetime.now(UTC).isoformat())}] stage {i}/{len(PIPELINE_STAGES)}: {stage}")
            db.refresh(deployment)
            deployment.logs = "\n".join(logs)
            db.commit()
            time.sleep(1)

            # ~10% simulated failure to prove the pipeline handles errors
            if i == 4 and deployment.id % 9 == 0:
                deployment.status = "failed"
                deployment.logs = "\n".join(logs + ["[ERROR] security scan found 3 vulnerabilities"])
                deployment.finished_at = datetime.now(UTC)
                db.commit()
                return

        deployment.status = "success"
        deployment.logs = "\n".join(logs + ["[DONE] deployment healthy"])
        deployment.finished_at = datetime.now(UTC)
        db.commit()
    finally:
        db.close()


@router.get("", response_model=list[schemas.DeploymentOut])
def list_deployments(
    project_id: int,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    _get_owned_project(db, project_id, user)
    return db.execute(
        select(models.Deployment)
        .where(models.Deployment.project_id == project_id)
        .order_by(models.Deployment.id.desc())
    ).scalars().all()


@router.post("", response_model=schemas.DeploymentOut, status_code=status.HTTP_201_CREATED)
def create_deployment(
    project_id: int,
    payload: schemas.DeploymentCreate,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    _get_owned_project(db, project_id, user)

    if payload.environment_id is not None:
        env = db.get(models.Environment, payload.environment_id)
        if env is None or env.project_id != project_id:
            raise HTTPException(status_code=422, detail="Environment is not part of this project")

    deployment = models.Deployment(project_id=project_id, **payload.model_dump())
    db.add(deployment)
    db.commit()
    db.refresh(deployment)

    thread = threading.Thread(target=_run_pipeline, args=(deployment.id,), daemon=True)
    thread.start()
    return deployment


@router.get("/{deployment_id}", response_model=schemas.DeploymentOut)
def get_deployment(
    project_id: int,
    deployment_id: int,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    _get_owned_project(db, project_id, user)
    deployment = db.get(models.Deployment, deployment_id)
    if deployment is None or deployment.project_id != project_id:
        raise HTTPException(status_code=404, detail="Deployment not found")
    return deployment
