"""Chat routes using FREE Groq API"""

from fastapi import APIRouter, HTTPException, Header
from typing import Optional
import uuid
import json
import os
from datetime import datetime

from app.schemas.chat_schemas import (
    MessageCreate,
    ConversationCreate,
    MemoryCreate,
    MemoryResponse,
)
from app.core.security import verify_token
from app.services.groq_ai_service import get_groq_service
from app.services.memory_service import MemoryService

router = APIRouter(prefix="/api/v1/chat", tags=["chat"])

CONVERSATIONS_FILE = "conversations.json"
MESSAGES_FILE = "messages.json"

def load_conversations():
    if os.path.exists(CONVERSATIONS_FILE):
        with open(CONVERSATIONS_FILE, "r") as f:
            return json.load(f)
    return {}

def save_conversations(convs):
    with open(CONVERSATIONS_FILE, "w") as f:
        json.dump(convs, f)

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

# ========== CONVERSATIONS ==========

@router.post("/conversation")
async def create_conversation(
    data: ConversationCreate,
    authorization: Optional[str] = Header(None)
):
    """Create new conversation"""
    user_id = get_current_user(authorization)
    
    convs = load_conversations()
    conv_id = f"conv_{uuid.uuid4().hex[:12]}"
    
    conversation = {
        "id": conv_id,
        "user_id": user_id,
        "title": data.title,
        "created_at": datetime.utcnow().isoformat(),
        "updated_at": datetime.utcnow().isoformat(),
    }
    
    if user_id not in convs:
        convs[user_id] = []
    
    convs[user_id].append(conversation)
    save_conversations(convs)
    
    return conversation

@router.get("/conversations")
async def get_conversations(authorization: Optional[str] = Header(None)):
    """Get user conversations"""
    user_id = get_current_user(authorization)
    
    convs = load_conversations()
    user_convs = convs.get(user_id, [])
    
    return {
        "conversations": user_convs,
        "total": len(user_convs)
    }

# ========== MESSAGES ==========

@router.post("/message")
async def send_message(
    data: MessageCreate,
    authorization: Optional[str] = Header(None)
):
    """Send message and get AI response using Groq (FREE, FAST!)"""
    user_id = get_current_user(authorization)
    
    ai_service = get_groq_service()  # FREE Groq API!
    messages_store = load_messages()
    
    # Get conversation history
    conv_messages = messages_store.get(data.conversation_id, [])
    
    # Convert to format for Groq
    history = [
        {
            "role": m["sender"],
            "content": m["content"]
        }
        for m in conv_messages
    ]
    
    # Get memory context
    memory_context = MemoryService.get_memory_context(user_id)
    
    # Create system prompt
    system_prompt = f"""You are SAATHI, a personal AI assistant for Rahul.
You are helpful, friendly, and good at remembering context.
Respond in a conversational way. Keep responses concise.

{memory_context}

Help Rahul with whatever he needs."""
    
    # Get AI response from Groq
    try:
        response_text, tokens_used = ai_service.chat(
            user_message=data.content,
            conversation_history=history,
            system_prompt=system_prompt,
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    # Store user message
    user_msg_id = f"msg_{uuid.uuid4().hex[:12]}"
    user_message = {
        "id": user_msg_id,
        "conversation_id": data.conversation_id,
        "user_id": user_id,
        "content": data.content,
        "sender": "user",
        "message_type": data.message_type,
        "created_at": datetime.utcnow().isoformat(),
    }
    
    # Store AI response
    ai_msg_id = f"msg_{uuid.uuid4().hex[:12]}"
    ai_message = {
        "id": ai_msg_id,
        "conversation_id": data.conversation_id,
        "user_id": user_id,
        "content": response_text,
        "sender": "assistant",
        "message_type": "text",
        "created_at": datetime.utcnow().isoformat(),
    }
    
    # Save messages
    if data.conversation_id not in messages_store:
        messages_store[data.conversation_id] = []
    
    messages_store[data.conversation_id].append(user_message)
    messages_store[data.conversation_id].append(ai_message)
    save_messages(messages_store)
    
    return {
        "user_message": user_message,
        "ai_message": ai_message,
        "tokens_used": tokens_used,
    }

@router.get("/messages/{conversation_id}")
async def get_messages(
    conversation_id: str,
    authorization: Optional[str] = Header(None)
):
    """Get conversation messages"""
    user_id = get_current_user(authorization)
    
    messages_store = load_messages()
    messages = messages_store.get(conversation_id, [])
    
    return {
        "messages": messages,
        "total": len(messages)
    }

# ========== MEMORIES ==========

@router.post("/memory")
async def create_memory(
    data: MemoryCreate,
    authorization: Optional[str] = Header(None)
):
    """Create memory"""
    user_id = get_current_user(authorization)
    
    memory = MemoryService.create_memory(
        user_id=user_id,
        content=data.content,
        category=data.category,
        tags=data.tags,
        priority=data.priority,
    )
    
    return MemoryResponse(**memory)

@router.get("/memories")
async def get_memories(
    category: Optional[str] = None,
    authorization: Optional[str] = Header(None)
):
    """Get user memories"""
    user_id = get_current_user(authorization)
    
    memories = MemoryService.get_memories(user_id, category)
    
    return {
        "memories": memories,
        "total": len(memories)
    }

@router.get("/memory/search")
async def search_memories(
    query: str,
    authorization: Optional[str] = Header(None)
):
    """Search memories"""
    user_id = get_current_user(authorization)
    
    results = MemoryService.search_memories(user_id, query)
    
    return {
        "results": results,
        "total": len(results)
    }

@router.delete("/memory/{memory_id}")
async def delete_memory(
    memory_id: str,
    authorization: Optional[str] = Header(None)
):
    """Delete memory"""
    user_id = get_current_user(authorization)
    
    success = MemoryService.delete_memory(user_id, memory_id)
    
    if not success:
        raise HTTPException(status_code=404, detail="Memory not found")
    
    return {"message": "Memory deleted"}