from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment (or .env)."""

    app_name: str = "devflow"
    environment: str = "development"
    debug: bool = False
    version: str = "1.0.0"

    api_prefix: str = "/api"

    # Postgres in prod, sqlite for local/test fallback.
    database_url: str = "sqlite:///./devflow.db"

    secret_key: str = "devflow-insecure-dev-key-change-me"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    cors_origins: list[str] = ["http://localhost:3000", "http://localhost:5173"]

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")


@lru_cache
def get_settings() -> Settings:
    return Settings()
