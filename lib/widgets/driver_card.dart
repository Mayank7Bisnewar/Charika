import 'package:flutter/material.dart';

class DriverCard extends StatelessWidget {
  final String driverName;
  final String vehicleNumber;
  final double rating;
  final String arrivalTime;

  const DriverCard({
    super.key,
    required this.driverName,
    required this.vehicleNumber,
    required this.rating,
    required this.arrivalTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              child: Icon(
                Icons.person,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driverName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(rating.toString()),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(vehicleNumber),

                  const SizedBox(height: 5),

                  Text(
                    "$arrivalTime away",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.call,
                color: Colors.green,
              ),
            )
          ],
        ),
      ),
    );
  }
}