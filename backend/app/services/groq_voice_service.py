"""Voice Service using Groq - Speech-to-Text & Text-to-Speech (100% FREE)"""

from app.core.config import settings
import io
import base64
from groq import Groq
from datetime import datetime

class GroqVoiceService:
    """Service for voice features using Groq API (STT + TTS)"""
    
    def __init__(self):
        """Initialize Groq client for voice"""
        api_key = settings.GROQ_API_KEY
        if not api_key:
            raise ValueError("GROQ_API_KEY not set")
        self.client = Groq(api_key=api_key)
    
    def speech_to_text(self, audio_file_path: str) -> str:
        """
        Convert speech to text using Groq Whisper Large V3
        
        Args:
            audio_file_path: Path to audio file (mp3, wav, m4a, webm, etc)
        
        Returns:
            Transcribed text
        """
        try:
            with open(audio_file_path, "rb") as audio_file:
                # Use Groq's Whisper model
                transcript = self.client.audio.transcriptions.create(
                    model="whisper-large-v3",
                    file=audio_file,
                    language="en",  # Change to "hi" for Hindi
                    temperature=0.0,  # More accurate transcription
                )
            
            return transcript.text
        
        except Exception as e:
            raise Exception(f"STT Error: {str(e)}")
    
    def text_to_speech(self, text: str, language: str = "en") -> bytes:
        """
        Convert text to speech using Groq Orpheus V1
        
        Args:
            text: Text to convert
            language: Language code (en for English)
        
        Returns:
            Audio bytes (MP3 format)
        """
        try:
            # Use Groq's Text-to-Speech endpoint
            # Note: Groq TTS is available via API
            
            # For now, we'll use a workaround with pyttsx3 (local, offline)
            # Or use Groq's native TTS when available
            
            import pyttsx3
            
            # Initialize text-to-speech engine
            engine = pyttsx3.init()
            engine.setProperty('rate', 150)  # Speed
            engine.setProperty('volume', 1.0)  # Volume
            
            # Create audio file in memory
            audio_buffer = io.BytesIO()
            
            # Save to buffer
            # pyttsx3 saves to file, so we'll save temporarily
            import tempfile
            with tempfile.NamedTemporaryFile(suffix='.mp3', delete=False) as tmp:
                engine.save_to_file(text, tmp.name)
                engine.runAndWait()
                
                # Read the file
                with open(tmp.name, 'rb') as f:
                    audio_bytes = f.read()
                
                # Clean up
                import os
                os.remove(tmp.name)
            
            return audio_bytes
        
        except Exception as e:
            # Fallback: return error message as text
            raise Exception(f"TTS Error: {str(e)}")
    
    def text_to_speech_groq_native(self, text: str) -> bytes:
        """
        Alternative: Use Groq's native TTS when available
        (Currently uses pyttsx3 as fallback)
        """
        # This will be available when Groq enables their TTS API
        # For now, using local pyttsx3
        return self.text_to_speech(text)

# Singleton instance
_groq_voice_service = None

def get_groq_voice_service():
    """Get Groq voice service instance"""
    global _groq_voice_service
    if _groq_voice_service is None:
        _groq_voice_service = GroqVoiceService()
    return _groq_voice_service