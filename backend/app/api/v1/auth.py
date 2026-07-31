from fastapi import APIRouter, HTTPException, status
from datetime import timedelta
from app.schemas.user_schemas import (
    UserCreate,
    UserLogin,
    UserResponse,
    TokenResponse
)
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token
)
from app.core.config import settings
import uuid
import json
import os

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])

# Simple in-memory storage (replace with database later)
USERS_FILE = "users.json"

def load_users():
    """Load users from JSON file"""
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, "r") as f:
            return json.load(f)
    return {}

def save_users(users):
    """Save users to JSON file"""
    with open(USERS_FILE, "w") as f:
        json.dump(users, f)

@router.post("/signup", response_model=TokenResponse)
async def signup(user_data: UserCreate):
    """Register new user"""
    users = load_users()
    
    # Check if email already exists
    if any(u.get("email") == user_data.email for u in users.values()):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create new user
    user_id = f"user_{uuid.uuid4().hex[:12]}"
    hashed_pwd = hash_password(user_data.password)
    
    users[user_id] = {
        "id": user_id,
        "email": user_data.email,
        "name": user_data.name,
        "hashed_password": hashed_pwd,
        "is_active": True
    }
    
    save_users(users)
    
    # Create token
    token, expires_in = create_access_token({"sub": user_id})
    
    return TokenResponse(
        access_token=token,
        expires_in=expires_in
    )

@router.post("/login", response_model=TokenResponse)
async def login(credentials: UserLogin):
    """Login user"""
    users = load_users()
    
    # Find user by email
    user = None
    for u in users.values():
        if u.get("email") == credentials.email:
            user = u
            break
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Verify password
    if not verify_password(credentials.password, user.get("hashed_password")):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Create token
    token, expires_in = create_access_token({"sub": user.get("id")})
    
    return TokenResponse(
        access_token=token,
        expires_in=expires_in
    )

@router.post("/login/google")
async def login_google(id_token: str):
    """Google login (placeholder)"""
    # This would verify Google ID token
    # For now, just return success
    return {
        "message": "Google login - implement with google-auth library",
        "token": "placeholder"
    }