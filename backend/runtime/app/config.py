from dataclasses import dataclass
import os
from pathlib import Path

from dotenv import load_dotenv


load_dotenv(Path(__file__).resolve().parents[1] / ".env")


@dataclass(frozen=True)
class Settings:
    database_url: str = os.getenv("DATABASE_URL", "sqlite:///./clinical_thinking.db")
    app_secret: str = os.getenv("APP_SECRET", "development-only-change-before-deploying")
    access_token_hours: int = int(os.getenv("ACCESS_TOKEN_HOURS", "12"))
    dialogue_engine_url: str = os.getenv("DIALOGUE_ENGINE_URL", "http://127.0.0.1:28765")
    dialogue_engine_origin: str = os.getenv("DIALOGUE_ENGINE_ORIGIN", "http://127.0.0.1:28765")
    dialogue_public_url: str = os.getenv("DIALOGUE_PUBLIC_URL", "http://127.0.0.1:28765")


settings = Settings()
