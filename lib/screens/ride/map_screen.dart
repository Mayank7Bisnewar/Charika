import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Carika Map"),
      ),
      body:  MapLibreMap(
        styleString: "https://demotiles.maplibre.org/style.json",
        initialCameraPosition: CameraPosition(
          target: LatLng(21.1458, 79.0882), // Nagpur
          zoom: 13,
        ),
      ),
    );
  }
}