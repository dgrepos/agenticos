"""Env-driven settings. Layering: .env.local overrides .env; schema lives in .env.example.

DB strategy: SQLite by default (zero install — dev/demo just works), Postgres for
production parity via DATABASE_URL (docker compose up -d db, or a hosted Postgres).
Same SQLAlchemy code path either way.
"""

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Later files win in pydantic-settings, so .env.local overrides .env.
    model_config = SettingsConfigDict(env_file=(".env", ".env.local"), extra="ignore")

    database_url: str = "sqlite:///./app.db"
    debug: bool = False


settings = Settings()
