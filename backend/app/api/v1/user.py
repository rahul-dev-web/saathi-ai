from fastapi import APIRouter, HTTPException, Header  # type: ignore[import]
from typing import Optional
from app.schemas.user_schemas import UserResponse
from app.core.security import verify_token
import json
import os

router = APIRouter(prefix="/api/v1/user", tags=["user"])

USERS_FILE = "users.json"

def load_users():
    """Load users from JSON file"""
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, "r") as f:
            return json.load(f)
    return {}

def get_current_user(authorization: Optional[str] = Header(None)):
    """Get current user from token"""
    if not authorization:
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    # Extract token from "Bearer <token>"
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

@router.get("/profile", response_model=UserResponse)
async def get_profile(authorization: Optional[str] = Header(None)):
    """Get user profile"""
    user_id = get_current_user(authorization)
    
    users = load_users()
    user = users.get(user_id)
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse(**user)

@router.put("/profile")
async def update_profile(
    name: Optional[str] = None,
    authorization: Optional[str] = Header(None)
):
    """Update user profile"""
    user_id = get_current_user(authorization)
    
    users = load_users()
    user = users.get(user_id)
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    if name:
        user["name"] = name
    
    users[user_id] = user
    
    with open(USERS_FILE, "w") as f:
        json.dump(users, f)
    
    return {"message": "Profile updated", "user": user}

@router.get("/preferences")
async def get_preferences(authorization: Optional[str] = Header(None)):
    """Get user preferences"""
    user_id = get_current_user(authorization)
    
    # Return default preferences for now
    return {
        "theme": "dark",
        "language": "en",
        "notifications_enabled": True,
        "auto_sync": True
    }