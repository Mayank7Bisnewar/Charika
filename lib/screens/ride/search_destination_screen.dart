import 'package:flutter/material.dart';

class SearchDestinationScreen extends StatelessWidget {
  const SearchDestinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Where to?"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.my_location),
                hintText: "Pickup Location",
              ),
            ),

            SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                hintText: "Destination",
              ),
            ),

            SizedBox(height: 30),

            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              subtitle: Text("Nagpur"),
            ),

            ListTile(
              leading: Icon(Icons.work),
              title: Text("Office"),
              subtitle: Text("IT Park"),
            ),

            ListTile(
              leading: Icon(Icons.school),
              title: Text("College"),
              subtitle: Text("Priyadarshini College"),
            ),
          ],
        ),
      ),
    );
  }
}