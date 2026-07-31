import 'package:flutter/material.dart';
import '../../widgets/driver_card.dart';
import '../../widgets/fare_card.dart';
import '../../widgets/primary_button.dart';

class ConfirmRideScreen extends StatefulWidget {
  const ConfirmRideScreen({super.key});

  @override
  State<ConfirmRideScreen> createState() => _ConfirmRideScreenState();
}

class _ConfirmRideScreenState extends State<ConfirmRideScreen> {
  int selectedRide = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirm Ride"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// Map Placeholder
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Icon(
                  Icons.map,
                  size: 80,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose your Ride",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            FareCard(
              rideType: "Mini",
              price: "₹149",
              time: "3",
              icon: Icons.local_taxi,
              selected: selectedRide == 0,
              onTap: () {
                setState(() {
                  selectedRide = 0;
                });
              },
            ),

            FareCard(
              rideType: "Sedan",
              price: "₹229",
              time: "4",
              icon: Icons.directions_car,
              selected: selectedRide == 1,
              onTap: () {
                setState(() {
                  selectedRide = 1;
                });
              },
            ),

            FareCard(
              rideType: "SUV",
              price: "₹389",
              time: "6",
              icon: Icons.airport_shuttle,
              selected: selectedRide == 2,
              onTap: () {
                setState(() {
                  selectedRide = 2;
                });
              },
            ),

            const SizedBox(height: 15),

            const DriverCard(
              driverName: "Rahul Sharma",
              vehicleNumber: "MH31 AB 1234",
              rating: 4.9,
              arrivalTime: "3 min",
            ),

            const Spacer(),

          PrimaryButton(
  text: "Confirm Ride",
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Ride Confirmed Successfully 🚖"),
      ),
    );
  },
),
          ],
        ),
      ),
    );
  }
}