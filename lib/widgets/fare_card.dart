import 'package:flutter/material.dart';

class FareCard extends StatelessWidget {
  final String rideType;
  final String price;
  final String time;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const FareCard({
    super.key,
    required this.rideType,
    required this.price,
    required this.time,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.black : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36,
              color: selected ? Colors.white : Colors.black,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rideType,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$time min away",
                    style: TextStyle(
                      color: selected ? Colors.white70 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              price,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}