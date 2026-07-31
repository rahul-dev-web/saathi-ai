"""Memory management service - same as Phase 2 Ollama version"""

import json
import os
from typing import List, Optional
from datetime import datetime
import uuid

class MemoryService:
    """Service for managing user memories"""
    
    MEMORIES_FILE = "memories.json"
    
    @staticmethod
    def load_memories():
        """Load memories from file"""
        if os.path.exists(MemoryService.MEMORIES_FILE):
            with open(MemoryService.MEMORIES_FILE, "r") as f:
                return json.load(f)
        return {}
    
    @staticmethod
    def save_memories(memories):
        """Save memories to file"""
        with open(MemoryService.MEMORIES_FILE, "w") as f:
            json.dump(memories, f, indent=2)
    
    @staticmethod
    def create_memory(
        user_id: str,
        content: str,
        category: str,
        tags: List[str] | None = None,
        priority: str = "medium",
    ) -> dict:
        """Create new memory"""
        
        memories = MemoryService.load_memories()
        memory_id = f"mem_{uuid.uuid4().hex[:12]}"
        
        memory = {
            "id": memory_id,
            "user_id": user_id,
            "content": content,
            "category": category,
            "tags": tags or [],
            "priority": priority,
            "created_at": datetime.utcnow().isoformat(),
        }
        
        if user_id not in memories:
            memories[user_id] = []
        
        memories[user_id].append(memory)
        MemoryService.save_memories(memories)
        
        return memory
    
    @staticmethod
    def get_memories(user_id: str, category: str | None = None,) -> List[dict]:
        """Get user memories"""
        
        memories = MemoryService.load_memories()
        user_memories = memories.get(user_id, [])
        
        if category:
            user_memories = [m for m in user_memories if m["category"] == category]
        
        return user_memories
    
    @staticmethod
    def search_memories(user_id: str, query: str) -> List[dict]:
        """Search memories by keyword"""
        
        memories = MemoryService.load_memories()
        user_memories = memories.get(user_id, [])
        
        query_lower = query.lower()
        results = []
        
        for memory in user_memories:
            if (query_lower in memory["content"].lower() or
                any(query_lower in tag.lower() for tag in memory["tags"])):
                results.append(memory)
        
        return results
    
    @staticmethod
    def delete_memory(user_id: str, memory_id: str) -> bool:
        """Delete memory"""
        
        memories = MemoryService.load_memories()
        
        if user_id in memories:
            memories[user_id] = [m for m in memories[user_id] if m["id"] != memory_id]
            MemoryService.save_memories(memories)
            return True
        
        return False
    
    @staticmethod
    def get_memory_context(user_id: str, limit: int = 5) -> str:
        """Get recent memories as context for AI"""
        
        memories = MemoryService.load_memories()
        user_memories = memories.get(user_id, [])
        
        if not user_memories:
            return ""
        
        # Sort by priority and recency
        sorted_memories = sorted(
            user_memories,
            key=lambda x: (x["priority"] == "high", x["created_at"]),
            reverse=True
        )[:limit]
        
        context = "Recent memories about the user:\n"
        for mem in sorted_memories:
            context += f"- {mem['content']} (Category: {mem['category']})\n"
        
        return context