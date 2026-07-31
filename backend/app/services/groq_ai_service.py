"""AI Service using Groq API (FREE, FAST, EXCELLENT)"""


from groq import Groq
from typing import Optional, Generator,Any,cast
from app.core.config import settings

class GroqAIService:
    """Service for AI using Groq API with llama-3.1-8b-instant"""
    
    def __init__(self):
        """Initialize Groq client"""
        api_key = settings.GROQ_API_KEY
        if not api_key:
            raise ValueError("GROQ_API_KEY not set in environment")
        
        self.client = Groq(api_key=api_key)
        self.model = "llama-3.1-8b-instant"  # Fast & excellent quality
    
    def chat(
        self,
        user_message: str,
        conversation_history: Optional[list] = None,
        system_prompt: Optional[str] = None,
    ) -> tuple[str, int]:
        """
        Send message to Groq and get response
        
        Args:
            user_message: User's message
            conversation_history: Previous messages in format [{"role": "user", "content": "..."}, ...]
            system_prompt: Custom system prompt
        
        Returns:
            Tuple of (response_text, tokens_used)
        """
        
        if conversation_history is None:
            conversation_history = []
        
        if system_prompt is None:
            system_prompt = """You are SAATHI, a personal AI assistant for Rahul.
You are:
- Helpful and friendly
- Good at understanding context
- Able to help with coding, studying, and daily tasks
- Respectful and honest

Rahul is a developer preparing for NIMCET exams.
Help him with whatever he needs.

Respond concisely and naturally."""
        
        # Build messages for Groq
        messages = [
            {"role": "system", "content": system_prompt}
        ]
        
        # Add conversation history
        messages.extend(conversation_history)
        
        # Add current message
        messages.append({"role": "user", "content": user_message})
        
        try:
            # Call Groq API (completely FREE!)
            response = self.client.chat.completions.create(
                model=self.model,
                messages=cast(Any,messages),
                temperature=0.7,
                max_tokens=1024,
                top_p=1.0,
            )
            
            # Extract response
            response_text = response.choices[0].message.content or ""
            
            # Get token usage
            usage = response.usage

            if usage is not None:
              tokens_used = usage.prompt_tokens + usage.completion_tokens
            else:
                tokens_used = 0
            
            return response_text, tokens_used
            
        except Exception as e:
            raise Exception(f"Groq API Error: {str(e)}")
    
    def stream_chat(
        self,
        user_message: str,
        conversation_history: Optional[list] = None,
        system_prompt: Optional[str] = None,
    ) -> Generator[str, None, None]:
        """
        Stream chat response from Groq
        
        Yields chunks of response text (real-time)
        """
        
        if conversation_history is None:
            conversation_history = []
        
        if system_prompt is None:
            system_prompt = """You are SAATHI, a helpful AI assistant for Rahul.
Help him with whatever he needs."""
        
        # Build messages
        messages: list[dict[str, Any]] = [
    {
        "role": "system",
        "content": system_prompt,
    }
]
        
        messages.extend(conversation_history)
        messages.append({"role": "user", "content": user_message})
        
        try:
            # Stream response from Groq (real-time!)
            response = self.client.chat.completions.create(
                model=self.model,
                messages=cast(Any,messages),
                temperature=0.7,
                max_tokens=1024,
                stream=True,
            )
            
            for chunk in response:
                if chunk.choices[0].delta.content:
                    yield chunk.choices[0].delta.content
                    
        except Exception as e:
            yield f"\nError: {str(e)}"

# Singleton instance
_groq_service = None

def get_groq_service():
    """Get Groq AI service instance"""
    global _groq_service
    if _groq_service is None:
        _groq_service = GroqAIService()
    return _groq_service