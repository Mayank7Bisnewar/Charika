import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Carika",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Good Afternoon 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 10),
                  Text(
                    "Where are you going?",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  "Google Map Coming Soon",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Ride Categories",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [

                RideCard(
                  icon: Icons.directions_car,
                  title: "Mini",
                ),

                RideCard(
                  icon: Icons.local_taxi,
                  title: "Sedan",
                ),

                RideCard(
                  icon: Icons.airport_shuttle,
                  title: "SUV",
                ),

              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Recent Places",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              subtitle: Text("Nagpur"),
            ),

            const ListTile(
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

class RideCard extends StatelessWidget {

  final IconData icon;
  final String title;

  const RideCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 100,
      height: 100,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Icon(icon, size: 35),

          SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }
}