import json
import threading
import time
from datetime import UTC, datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app import models, schemas
from app.database import SessionLocal, get_db
from app.deps import get_current_user

router = APIRouter(prefix="/jobs", tags=["jobs"])

JOB_STAGES = {
    "deploy": ["validate config", "build image", "push image", "rollout", "healthcheck"],
    "test": ["collect tests", "run unit tests", "run integration tests", "report"],
    "scan": ["fetch dependencies", "scan dependencies", "scan container", "report"],
}


def _run_job(job_id: int) -> None:
    db = SessionLocal()
    try:
        job = db.get(models.Job, job_id)
        if job is None:
            return
        job.status = "running"
        db.commit()

        stages = JOB_STAGES.get(job.kind, JOB_STAGES["deploy"])
        logs: list[str] = []
        for stage in stages:
            logs.append(f"[{(datetime.now(UTC).isoformat())}] {stage}")
            job.logs = "\n".join(logs)
            db.commit()
            time.sleep(1)

        job.status = "success"
        job.logs = "\n".join(logs + ["[DONE]"])
        db.commit()
    finally:
        db.close()


@router.get("", response_model=list[schemas.JobOut])
def list_jobs(db: Session = Depends(get_db), user: models.User = Depends(get_current_user)):
    return db.execute(select(models.Job).order_by(models.Job.id.desc())).scalars().all()


@router.post("", response_model=schemas.JobOut, status_code=status.HTTP_201_CREATED)
def create_job(
    payload: schemas.JobCreate,
    db: Session = Depends(get_db),
    user: models.User = Depends(get_current_user),
):
    job = models.Job(
        name=payload.name,
        kind=payload.kind,
        parameters=json.dumps(payload.parameters),
        project_id=payload.project_id,
    )
    db.add(job)
    db.commit()
    db.refresh(job)

    thread = threading.Thread(target=_run_job, args=(job.id,), daemon=True)
    thread.start()
    return job


@router.get("/{job_id}", response_model=schemas.JobOut)
def get_job(job_id: int, db: Session = Depends(get_db), user: models.User = Depends(get_current_user)):
    job = db.get(models.Job, job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job not found")
    return job
