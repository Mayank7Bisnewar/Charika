import math
import os
from datetime import datetime, timedelta
from typing import Optional

import httpx
from jose import JWTError, jwt
from passlib.context import CryptContext

from app.schemas import TokenData, UserRole

GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")


def get_google_maps_api_key() -> str:
    if not GOOGLE_MAPS_API_KEY:
        raise RuntimeError("GOOGLE_MAPS_API_KEY is not configured")
    return GOOGLE_MAPS_API_KEY


async def geocode_address(address: str) -> dict:
    api_key = get_google_maps_api_key()
    url = "https://maps.googleapis.com/maps/api/geocode/json"
    params = {"address": address, "key": api_key}
    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.get(url, params=params)
        response.raise_for_status()
        data = response.json()
    if data.get("status") != "OK" or not data.get("results"):
        raise ValueError("Could not geocode address")
    result = data["results"][0]
    location = result["geometry"]["location"]
    return {
        "formatted_address": result.get("formatted_address"),
        "lat": float(location["lat"]),
        "lng": float(location["lng"]),
    }

SECRET_KEY = os.getenv("JWT_SECRET_KEY", "change-me")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


def decode_access_token(token: str) -> TokenData | None:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        role: str | None = payload.get("role")
        if email is None:
            return None
        return TokenData(email=email, role=UserRole(role) if role else None)
    except JWTError:
        return None


def calculate_distance_km(origin_lat: float, origin_lng: float, destination_lat: float, destination_lng: float) -> float:
    radius_km = 6371.0
    lat1 = math.radians(origin_lat)
    lat2 = math.radians(destination_lat)
    delta_lat = math.radians(destination_lat - origin_lat)
    delta_lng = math.radians(destination_lng - origin_lng)

    a = math.sin(delta_lat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(delta_lng / 2) ** 2
    distance = radius_km * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return round(distance, 2)


def estimate_duration_minutes(distance_km: float) -> int:
    return max(5, int(distance_km * 4))


def calculate_ride_price(distance_km: float) -> float:
    base_fare = 2.50
    per_km = 1.20
    booking_fee = 1.50
    return round(base_fare + (distance_km * per_km) + booking_fee, 2)
