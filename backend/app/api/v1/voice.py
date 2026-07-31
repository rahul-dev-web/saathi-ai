"""Voice routes - STT & TTS using Groq + pyttsx3"""

from fastapi import APIRouter, HTTPException, Header, UploadFile, File
from typing import Optional
import uuid
import json
import os
import base64
from datetime import datetime
import tempfile

from app.schemas.voice_schemas import (
    VoiceMessageCreate,
    TextToSpeechRequest,
)
from app.core.security import verify_token
from app.services.groq_voice_service import get_groq_voice_service
from app.services.offline_tts_service import get_offline_tts_service
from app.services.groq_ai_service import get_groq_service
from app.services.memory_service import MemoryService

router = APIRouter(prefix="/api/v1/voice", tags=["voice"])

MESSAGES_FILE = "messages.json"

def load_messages():
    if os.path.exists(MESSAGES_FILE):
        with open(MESSAGES_FILE, "r") as f:
            return json.load(f)
    return {}

def save_messages(msgs):
    with open(MESSAGES_FILE, "w") as f:
        json.dump(msgs, f)

def get_current_user(authorization: Optional[str] = Header(None)):
    """Get current user from token"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    try:
        scheme, token = authorization.split()
        if scheme.lower() != "bearer":
            raise HTTPException(status_code=401, detail="Invalid authentication")
    except:
        raise HTTPException(status_code=401, detail="Invalid token format")
    
    user_id = verify_token(token)
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    return user_id

# ========== SPEECH-TO-TEXT ==========

@router.post("/transcribe")
async def transcribe_audio(
    file: UploadFile = File(...),
    authorization: Optional[str] = Header(None)
):
    """Transcribe audio file to text using Groq Whisper"""
    user_id = get_current_user(authorization)
    voice_service = get_groq_voice_service()
    
    try:
        # Save uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name
        
        # Transcribe using Groq Whisper
        transcribed_text = voice_service.speech_to_text(tmp_path)
        
        # Clean up
        os.remove(tmp_path)
        
        return {
            "text": transcribed_text,
            "success": True,
            "model": "whisper-large-v3",
            "cost": "$0 (FREE)"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/message")
async def send_voice_message(
    data: VoiceMessageCreate,
    authorization: Optional[str] = Header(None)
):
    """Send voice message and get AI response with voice reply"""
    user_id = get_current_user(authorization)
    voice_service = get_groq_voice_service()
    ai_service = get_groq_service()
    tts_service = get_offline_tts_service()  # Using offline TTS (no billing!)
    messages_store = load_messages()
    
    try:
        # Decode audio from base64
        audio_bytes = base64.b64decode(data.audio_base64)
        
        # Save temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
            tmp.write(audio_bytes)
            tmp_path = tmp.name
        
        # Convert speech to text using Groq Whisper
        user_message_text = voice_service.speech_to_text(tmp_path)
        os.remove(tmp_path)
        
        # Get conversation history
        conv_messages = messages_store.get(data.conversation_id, [])
        history = [
            {"role": m["sender"], "content": m["content"]}
            for m in conv_messages
        ]
        
        # Get memory context
        memory_context = MemoryService.get_memory_context(user_id)
        
        # Create system prompt
        system_prompt = f"""You are SAATHI, a personal AI assistant for Rahul.
You are helpful and friendly. Keep responses CONCISE (2-3 sentences) for voice output.

{memory_context}

Help Rahul with whatever he needs."""
        
        # Get AI response
        response_text, tokens_used = ai_service.chat(
            user_message=user_message_text,
            conversation_history=history,
            system_prompt=system_prompt,
        )
        
        # Convert AI response to speech using offline TTS (FREE, no API!)
        ai_audio_bytes = tts_service.text_to_speech(response_text)
        ai_audio_base64 = base64.b64encode(ai_audio_bytes).decode('utf-8')
        
        # Store messages
        user_msg_id = f"msg_{uuid.uuid4().hex[:12]}"
        user_message = {
            "id": user_msg_id,
            "conversation_id": data.conversation_id,
            "user_id": user_id,
            "content": user_message_text,
            "sender": "user",
            "message_type": "voice",
            "created_at": datetime.utcnow().isoformat(),
        }
        
        ai_msg_id = f"msg_{uuid.uuid4().hex[:12]}"
        ai_message = {
            "id": ai_msg_id,
            "conversation_id": data.conversation_id,
            "user_id": user_id,
            "content": response_text,
            "sender": "assistant",
            "message_type": "voice",
            "audio_base64": ai_audio_base64,
            "created_at": datetime.utcnow().isoformat(),
        }
        
        if data.conversation_id not in messages_store:
            messages_store[data.conversation_id] = []
        
        messages_store[data.conversation_id].append(user_message)
        messages_store[data.conversation_id].append(ai_message)
        save_messages(messages_store)
        
        return {
            "user_message": user_message,
            "ai_message": ai_message,
            "tokens_used": tokens_used,
            "cost": "$0 (Groq STT + Free TTS)"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ========== TEXT-TO-SPEECH ==========

@router.post("/tts")
async def text_to_speech(
    data: TextToSpeechRequest,
    authorization: Optional[str] = Header(None)
):
    """Convert text to speech using offline TTS (100% FREE)"""
    user_id = get_current_user(authorization)
    tts_service = get_offline_tts_service()
    
    try:
        # Generate audio using offline TTS
        audio_bytes = tts_service.text_to_speech(data.text)
        audio_base64 = base64.b64encode(audio_bytes).decode('utf-8')
        
        return {
            "audio_base64": audio_base64,
            "format": "wav",
            "language": data.language,
            "success": True,
            "cost": "$0 (offline)"
        }
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))