import os
import tempfile

import pytest
from fastapi.testclient import TestClient

# Point the app at a throwaway SQLite DB before importing the app.
_tmpdir = tempfile.mkdtemp()
os.environ["DATABASE_URL"] = f"sqlite:///{_tmpdir}/test.db"
os.environ["SECRET_KEY"] = "test-secret-key"

from app.database import Base, engine
from app.main import app


@pytest.fixture(scope="session", autouse=True)
def _create_tables():
    Base.metadata.create_all(bind=engine)
    yield
    Base.metadata.drop_all(bind=engine)


@pytest.fixture(autouse=True)
def _clean_db():
    """Truncate all tables before each test so test files don't leak data."""
    from sqlalchemy import text

    with engine.begin() as conn:
        conn.execute(text("PRAGMA foreign_keys=OFF"))
        for table in reversed(Base.metadata.sorted_tables):
            conn.execute(table.delete())
        conn.execute(text("PRAGMA foreign_keys=ON"))
    yield


@pytest.fixture()
def client():
    with TestClient(app) as c:
        yield c


@pytest.fixture()
def auth_headers(client):
    """Register + login a throwaway user and return bearer headers."""
    client.post(
        "/api/auth/register",
        json={"username": "tester", "email": "tester@example.com", "password": "supersecret"},
    )
    resp = client.post(
        "/api/auth/login",
        data={"username": "tester", "password": "supersecret"},
    )
    token = resp.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}


@pytest.fixture()
def project(client, auth_headers):
    resp = client.post("/api/projects", json={"name": "demo", "description": "test"}, headers=auth_headers)
    return resp.json()
