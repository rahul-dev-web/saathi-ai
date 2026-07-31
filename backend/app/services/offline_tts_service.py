"""Offline Text-to-Speech using pyttsx3 (No internet, NO API costs!)"""

import pyttsx3
import io
import tempfile
import os
from typing import Optional

class OfflineTTSService:
    """Service for offline text-to-speech (completely local, FREE)"""
    
    def __init__(self):
        """Initialize TTS engine"""
        self.engine = pyttsx3.init()
        self.engine.setProperty('rate', 150)  # Speaking rate
        self.engine.setProperty('volume', 1.0)  # Volume (0.0 to 1.0)
    
    def text_to_speech(self, text: str) -> bytes:
        """
        Convert text to speech using pyttsx3
        
        Completely offline, no API needed!
        
        Args:
            text: Text to convert
        
        Returns:
            Audio bytes (WAV format)
        """
        try:
            # Create temporary file
            with tempfile.NamedTemporaryFile(suffix='.wav', delete=False) as tmp:
                tmp_path = tmp.name
            
            # Generate speech and save to file
            self.engine.save_to_file(text, tmp_path)
            self.engine.runAndWait()
            
            # Read the file
            with open(tmp_path, 'rb') as f:
                audio_bytes = f.read()
            
            # Clean up
            os.remove(tmp_path)
            
            return audio_bytes
        
        except Exception as e:
            raise Exception(f"TTS Error: {str(e)}")
    
    def set_voice_properties(
        self,
        rate: int = 150,  # 50-200
        volume: float = 1.0  # 0.0-1.0
    ):
        """
        Customize voice properties
        
        Args:
            rate: Speaking rate (default 150)
            volume: Volume level (default 1.0)
        """
        self.engine.setProperty('rate', rate)
        self.engine.setProperty('volume', volume)

# Singleton instance
_offline_tts_service = None

def get_offline_tts_service():
    """Get offline TTS service instance"""
    global _offline_tts_service
    if _offline_tts_service is None:
        _offline_tts_service = OfflineTTSService()
    return _offline_tts_service