from datetime import datetime

class User:
    """User model for database"""
    
    def __init__(
        self,
        id: str,
        email: str,
        name: str,
        hashed_password: str,
        is_active: bool = True,
        created_at: datetime = None,
    ):
        self.id = id
        self.email = email
        self.name = name
        self.hashed_password = hashed_password
        self.is_active = is_active
        self.created_at = created_at or datetime.utcnow()