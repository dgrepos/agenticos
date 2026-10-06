"""Application entrypoint. Routes live in app/api/; keep this file thin."""

from fastapi import FastAPI

from app.api.health import router as health_router

app = FastAPI(title="AgenticOS API")
app.include_router(health_router)
