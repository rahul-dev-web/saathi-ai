from pydantic_settings import BaseSettings
from typing import Optional

class Settings(BaseSettings):
    """Application settings from environment variables"""
    
    # App
    APP_NAME: str = "SAATHI AI"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    
    # Database
    DATABASE_URL: str = "sqlite:///./saathi.db"
    
    # JWT
    JWT_SECRET: str = "your-secret-key-change-in-production"
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_HOURS: int = 24
    
    # API
    API_HOST: str = "0.0.0.0"
    API_PORT: int = 8000
    GROQ_API_KEY: str = "gskxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # Replace with your actual Groq API key
    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
