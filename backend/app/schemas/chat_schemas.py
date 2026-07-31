from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class MessageCreate(BaseModel):
    conversation_id: str
    content: str
    message_type: str = "text"

class MessageResponse(BaseModel):
    id: str
    conversation_id: str
    user_id: str
    content: str
    sender: str
    message_type: str
    created_at: datetime

class ConversationCreate(BaseModel):
    title: str = "New Chat"

class ConversationResponse(BaseModel):
    id: str
    user_id: str
    title: str
    created_at: datetime
    updated_at: datetime

class MemoryCreate(BaseModel):
    content: str
    category: str
    tags: List[str] = []
    priority: str = "medium"

class MemoryResponse(BaseModel):
    id: str
    user_id: str
    content: str
    category: str
    tags: List[str]
    priority: str
    created_at: datetime