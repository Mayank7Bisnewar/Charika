from datetime import datetime
from typing import List, Optional

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core import calculate_distance_km, calculate_ride_price, estimate_duration_minutes, geocode_address
from app.dependencies import get_current_active_driver, get_current_active_rider, get_db
from app.models import Ride, RideStatus, User, UserRole
from app.schemas import RideCreate, RideOut, RideUpdate

router = APIRouter()

@router.post("/request", response_model=RideOut)
async def request_ride(ride_data: RideCreate, current_user=Depends(get_current_active_rider), db: AsyncSession = Depends(get_db)):
    ride_data.validate_location()
    if ride_data.origin_lat is None or ride_data.origin_lng is None:
        if not ride_data.origin_address:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Origin address is required")
        origin_geo = await geocode_address(ride_data.origin_address)
        ride_data.origin_lat = origin_geo["lat"]
        ride_data.origin_lng = origin_geo["lng"]
        ride_data.origin_address = origin_geo["formatted_address"]

    if ride_data.destination_lat is None or ride_data.destination_lng is None:
        if not ride_data.destination_address:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Destination address is required")
        destination_geo = await geocode_address(ride_data.destination_address)
        ride_data.destination_lat = destination_geo["lat"]
        ride_data.destination_lng = destination_geo["lng"]
        ride_data.destination_address = destination_geo["formatted_address"]

    distance_km = calculate_distance_km(
        ride_data.origin_lat,
        ride_data.origin_lng,
        ride_data.destination_lat,
        ride_data.destination_lng,
    )
    ride = Ride(
        rider_id=current_user.id,
        origin_lat=ride_data.origin_lat,
        origin_lng=ride_data.origin_lng,
        destination_lat=ride_data.destination_lat,
        destination_lng=ride_data.destination_lng,
        origin_address=ride_data.origin_address,
        destination_address=ride_data.destination_address,
        distance_km=distance_km,
        duration_minutes=estimate_duration_minutes(distance_km),
        price_amount=calculate_ride_price(distance_km),
        status=RideStatus.requested,
    )
    db.add(ride)
    await db.commit()
    await db.refresh(ride)
    return ride

@router.get("/available", response_model=List[RideOut])
async def available_rides(current_user=Depends(get_current_active_driver), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Ride).where(Ride.status == RideStatus.requested))
    return query.scalars().all()

@router.post("/{ride_id}/accept", response_model=RideOut)
async def accept_ride(ride_id: int, current_user=Depends(get_current_active_driver), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Ride).where(Ride.id == ride_id))
    ride = query.scalars().first()
    if not ride or ride.status != RideStatus.requested:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ride not available")
    ride.driver_id = current_user.id
    ride.status = RideStatus.accepted
    await db.commit()
    await db.refresh(ride)
    return ride

@router.post("/{ride_id}/start", response_model=RideOut)
async def start_ride(ride_id: int, current_user=Depends(get_current_active_driver), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Ride).where(Ride.id == ride_id))
    ride = query.scalars().first()
    if not ride or ride.driver_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ride not found")
    if ride.status != RideStatus.accepted:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ride must be accepted before starting")
    ride.status = RideStatus.in_progress
    ride.started_at = datetime.utcnow()
    await db.commit()
    await db.refresh(ride)
    return ride

@router.post("/{ride_id}/complete", response_model=RideOut)
async def complete_ride(ride_id: int, current_user=Depends(get_current_active_driver), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Ride).where(Ride.id == ride_id))
    ride = query.scalars().first()
    if not ride or ride.driver_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ride not found")
    if ride.status != RideStatus.in_progress:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ride must be in progress to complete")
    ride.status = RideStatus.completed
    ride.completed_at = datetime.utcnow()
    await db.commit()
    await db.refresh(ride)
    return ride

@router.post("/{ride_id}/cancel", response_model=RideOut)
async def cancel_ride(ride_id: int, current_user=Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Ride).where(Ride.id == ride_id))
    ride = query.scalars().first()
    if not ride:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ride not found")
    if current_user.role == UserRole.rider and ride.rider_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your ride")
    if current_user.role == UserRole.driver and ride.driver_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not your ride")
    if ride.status in {RideStatus.completed, RideStatus.canceled}:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ride cannot be canceled")
    ride.status = RideStatus.canceled
    await db.commit()
    await db.refresh(ride)
    return ride

@router.get("/", response_model=List[RideOut])
async def list_rides(status: Optional[RideStatus] = None, current_user=Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    query = select(Ride)
    if status:
        query = query.where(Ride.status == status)
    if current_user.role == UserRole.rider:
        query = query.where(Ride.rider_id == current_user.id)
    elif current_user.role == UserRole.driver:
        query = query.where(Ride.driver_id == current_user.id)
    result = await db.execute(query)
    return result.scalars().all()
