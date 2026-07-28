from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core import decode_access_token
from app.database import AsyncSessionLocal
from app.models import User, UserRole

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/token")


async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as db:
        yield db


async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    token_data = decode_access_token(token)
    if token_data is None or token_data.email is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Could not validate credentials")

    user = await db.execute(select(User).where(User.email == token_data.email))
    user_obj = user.scalars().first()
    if user_obj is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found")
    return user_obj


async def get_current_active_user(current_user: User = Depends(get_current_user)) -> User:
    if not current_user.is_active:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user")
    return current_user


async def get_current_active_driver(current_user: User = Depends(get_current_active_user)) -> User:
    if current_user.role != UserRole.driver:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only drivers can access this resource")
    return current_user


async def get_current_active_rider(current_user: User = Depends(get_current_active_user)) -> User:
    if current_user.role != UserRole.rider:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Only riders can access this resource")
    return current_user
