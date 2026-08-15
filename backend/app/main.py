import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app import metrics
from app.config import get_settings
from app.database import Base, engine
from app.routers import auth, deployments, environments, health, jobs, projects
from app.routers import metrics as metrics_router
from app.routers.users import router as users_router

settings = get_settings()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Create tables on startup (simple; Alembic migrations come in a later phase).
    Base.metadata.create_all(bind=engine)
    yield


app = FastAPI(
    title=settings.app_name,
    version=settings.version,
    description="DevOps Automation Platform API",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.middleware("http")
async def instrument_http(request: Request, call_next):
    start = time.perf_counter()
    response = await call_next(request)
    duration = time.perf_counter() - start

    path = request.url.path
    if not path.startswith("/api/metrics") and path != "/metrics":
        metrics.http_requests_total.labels(request.method, path, response.status_code).inc()
        metrics.http_request_duration_seconds.labels(request.method, path).observe(duration)
    return response


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    return JSONResponse(status_code=500, content={"detail": "Internal server error"})


api_prefix = settings.api_prefix

# health + metrics live at bare paths too, for load-balancer probes
app.include_router(health.router, prefix="/api")
app.include_router(metrics_router.router, prefix="/api")

app.include_router(users_router, prefix=api_prefix)
app.include_router(auth.router, prefix=api_prefix)
app.include_router(projects.router, prefix=api_prefix)
app.include_router(environments.router, prefix=api_prefix)
app.include_router(deployments.router, prefix=api_prefix)
app.include_router(jobs.router, prefix=api_prefix)

# expose health without /api prefix for orchestrators / Docker healthchecks
app.include_router(health.router, prefix="", include_in_schema=False)


@app.get("/", include_in_schema=False)
def root():
    return {"app": settings.app_name, "docs": "/docs", "health": "/api/health"}
