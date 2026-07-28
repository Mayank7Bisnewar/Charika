from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_current_active_driver, get_current_active_user, get_db
from app.models import User
from app.schemas import UserOut, UserUpdate

router = APIRouter()

@router.get("/me", response_model=UserOut)
async def read_current_user(current_user=Depends(get_current_active_user)):
    return current_user

@router.patch("/me", response_model=UserOut)
async def update_current_user(user_data: UserUpdate, current_user=Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    if user_data.name is not None:
        current_user.name = user_data.name
    if user_data.current_lat is not None:
        current_user.current_lat = user_data.current_lat
    if user_data.current_lng is not None:
        current_user.current_lng = user_data.current_lng
    if user_data.is_available is not None:
        current_user.is_available = user_data.is_available
    db.add(current_user)
    await db.commit()
    await db.refresh(current_user)
    return current_user

@router.get("/drivers", response_model=List[UserOut])
async def list_available_drivers(db: AsyncSession = Depends(get_db), current_user=Depends(get_current_active_user)):
    query = await db.execute(select(User).where(User.role == "driver", User.is_available == True))
    return query.scalars().all()

@router.get("/", response_model=List[UserOut])
async def list_users(db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(User))
    return query.scalars().all()
