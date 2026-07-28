from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.dependencies import get_current_active_user, get_current_active_rider, get_db
from app.models import Payment, Ride, RideStatus, UserRole
from app.schemas import PaymentIntentCreate, PaymentOut

router = APIRouter()

@router.post("/create", response_model=PaymentOut)
async def create_payment_intent(payment_data: PaymentIntentCreate, current_user=Depends(get_current_active_rider), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Ride).where(Ride.id == payment_data.ride_id))
    ride = query.scalars().first()
    if not ride:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Ride not found")
    if ride.rider_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Cannot pay for this ride")
    if ride.status != RideStatus.completed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ride must be completed before payment")

    amount = payment_data.amount if payment_data.amount is not None else ride.price_amount or 0.0
    payment = Payment(
        ride_id=ride.id,
        rider_id=ride.rider_id,
        driver_id=ride.driver_id,
        amount=amount,
        status="succeeded",
    )
    db.add(payment)
    await db.commit()
    await db.refresh(payment)
    return payment

@router.get("/ride/{ride_id}", response_model=PaymentOut)
async def get_payment_for_ride(ride_id: int, current_user=Depends(get_current_active_user), db: AsyncSession = Depends(get_db)):
    query = await db.execute(select(Payment).where(Payment.ride_id == ride_id))
    payment = query.scalars().first()
    if not payment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Payment not found")
    if current_user.role == UserRole.rider and payment.rider_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Cannot access this payment")
    if current_user.role == UserRole.driver and payment.driver_id != current_user.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Cannot access this payment")
    return payment
