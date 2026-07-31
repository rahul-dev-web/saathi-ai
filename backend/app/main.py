from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.v1 import auth, user, chat, voice
from app.core.config import settings

# Create FastAPI app
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    debug=settings.DEBUG
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router)
app.include_router(user.router)
app.include_router(chat.router)
app.include_router(voice.router)

@app.get("/")
async def root():
    return {
        "message": "SAATHI AI API (with Voice!)",
        "version": settings.APP_VERSION,
        "ai_model": "llama-3.1-8b-instant",
        "voice": {
            "stt": "whisper-large-v3 (Groq)",
            "tts": "pyttsx3 (offline, FREE)"
        },
        "cost": "$0 (100% FREE!)",
        "docs": "/docs"
    }

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.get("/status/voice")
async def check_voice():
    """Check voice services status"""
    try:
        from app.services.groq_voice_service import get_groq_voice_service
        from app.services.offline_tts_service import get_offline_tts_service
        
        groq_service = get_groq_voice_service()
        tts_service = get_offline_tts_service()
        
        return {
            "status": "Voice services ready ✅",
            "stt": "Groq Whisper Large V3 (FREE)",
            "tts": "pyttsx3 Offline (FREE)",
            "cost": "$0 forever!",
            "billing_required": False
        }
    except Exception as e:
        return {
            "status": "Voice services error ❌",
            "error": str(e)
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host=settings.API_HOST,
        port=settings.API_PORT
    )