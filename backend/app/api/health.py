"""Health endpoints — the template's example of a spec'd, tested route."""

from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    status: str
    version: str


@router.get("/health", response_model=HealthResponse)
async def health() -> HealthResponse:
    """Liveness probe; extend with DB ping when readiness is needed."""
    return HealthResponse(status="ok", version="0.1.0")
