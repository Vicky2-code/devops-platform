from fastapi import APIRouter, Response
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

from app.metrics import registry

router = APIRouter(tags=["metrics"])


@router.get("/metrics")
def metrics() -> Response:
    return Response(content=generate_latest(registry), media_type=CONTENT_TYPE_LATEST)
