from datetime import datetime
from enum import Enum
from typing import Optional

from pydantic import BaseModel, EmailStr, Field

class UserRole(str, Enum):
    rider = "rider"
    driver = "driver"

class RideStatus(str, Enum):
    requested = "requested"
    accepted = "accepted"
    in_progress = "in_progress"
    completed = "completed"
    canceled = "canceled"

class UserBase(BaseModel):
    email: EmailStr
    name: str
    role: UserRole = UserRole.rider

class UserCreate(UserBase):
    password: str = Field(..., min_length=8)

class UserUpdate(BaseModel):
    name: Optional[str] = None
    current_lat: Optional[float] = None
    current_lng: Optional[float] = None
    is_available: Optional[bool] = None

class UserOut(UserBase):
    id: int
    is_active: bool
    is_available: bool
    current_lat: Optional[float] = None
    current_lng: Optional[float] = None
    created_at: datetime

    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"

class TokenData(BaseModel):
    email: Optional[str] = None
    role: Optional[UserRole] = None

class RideCreate(BaseModel):
    origin_lat: Optional[float] = None
    origin_lng: Optional[float] = None
    destination_lat: Optional[float] = None
    destination_lng: Optional[float] = None
    origin_address: Optional[str] = None
    destination_address: Optional[str] = None

    def validate_location(self):
        if self.origin_address and self.destination_address:
            return
        if self.origin_lat is not None and self.origin_lng is not None and self.destination_lat is not None and self.destination_lng is not None:
            return
        raise ValueError("Provide either origin/destination coordinates or both addresses")

class RideUpdate(BaseModel):
    status: Optional[RideStatus] = None

class RideOut(BaseModel):
    id: int
    rider_id: int
    driver_id: Optional[int]
    status: RideStatus
    origin_lat: float
    origin_lng: float
    destination_lat: float
    destination_lng: float
    origin_address: Optional[str] = None
    destination_address: Optional[str] = None
    distance_km: Optional[float]
    duration_minutes: Optional[int]
    price_amount: Optional[float]
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True

class PaymentIntentCreate(BaseModel):
    ride_id: int
    amount: Optional[float] = None

class PaymentOut(BaseModel):
    id: int
    ride_id: int
    rider_id: int
    driver_id: int
    amount: float
    status: str
    created_at: datetime

    class Config:
        orm_mode = True
