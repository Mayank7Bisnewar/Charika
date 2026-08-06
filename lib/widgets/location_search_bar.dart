import 'package:flutter/material.dart';

class LocationSearchBar extends StatelessWidget {
  final VoidCallback? onTap;

  const LocationSearchBar({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.search),
            SizedBox(width: 12),
            Text(
              "Where are you going?",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}