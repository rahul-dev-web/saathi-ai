from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class VoiceMessageCreate(BaseModel):
    """Schema for creating voice message"""
    conversation_id: str
    audio_base64: str  # Base64 encoded audio
    message_type: str = "voice"

class VoiceMessageResponse(BaseModel):
    """Schema for voice message response"""
    id: str
    conversation_id: str
    user_id: str
    transcribed_text: str
    sender: str
    message_type: str
    created_at: datetime

class TextToSpeechRequest(BaseModel):
    """Schema for TTS request"""
    text: str
    language: str = "en"

class TextToSpeechResponse(BaseModel):
    """Schema for TTS response"""
    audio_base64: str
    format: str = "wav"  # Changed to wav
    language: str