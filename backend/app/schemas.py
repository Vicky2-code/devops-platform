from datetime import datetime

from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator


# ---------- auth ----------
class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    username: str
    email: EmailStr
    is_active: bool
    created_at: datetime


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


# ---------- projects ----------
class ProjectCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    description: str = ""
    repo_url: str = ""


class ProjectUpdate(BaseModel):
    name: str | None = Field(default=None, max_length=100)
    description: str | None = None
    repo_url: str | None = None
    status: str | None = None


class ProjectOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    description: str
    repo_url: str
    status: str
    owner_id: int
    created_at: datetime


# ---------- environments ----------
class EnvironmentCreate(BaseModel):
    name: str = Field(min_length=1, max_length=50)
    region: str = "us-east-1"


class EnvironmentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    project_id: int
    name: str
    region: str
    status: str
    created_at: datetime


# ---------- deployments ----------
class DeploymentCreate(BaseModel):
    environment_id: int | None = None
    commit_sha: str = "HEAD"
    image: str = ""
    triggered_by: str = "api"


class DeploymentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    project_id: int
    environment_id: int | None
    commit_sha: str
    image: str
    status: str
    logs: str
    triggered_by: str
    created_at: datetime
    finished_at: datetime | None


# ---------- jobs ----------
class JobCreate(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    kind: str = Field(default="deploy", pattern="^(deploy|test|scan)$")
    parameters: dict = {}
    project_id: int | None = None


class JobOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    name: str
    kind: str
    status: str
    parameters: dict
    logs: str
    project_id: int | None
    created_at: datetime

    @field_validator("parameters", mode="before")
    @classmethod
    def _parse_parameters(cls, v):
        if isinstance(v, str):
            import json

            try:
                return json.loads(v)
            except json.JSONDecodeError:
                return {}
        return v


class JobRunOut(JobOut):
    pass
