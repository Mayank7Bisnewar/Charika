import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapLibreMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carika Map'),
      ),
      body: MapLibreMap(
        styleString: 'https://demotiles.maplibre.org/style.json',

        initialCameraPosition: const CameraPosition(
          target: LatLng(21.1458, 79.0882),
          zoom: 10,
        ),

        onMapCreated: (controller) {
          _controller = controller;
          debugPrint('MAP CREATED');
        },

        onStyleLoadedCallback: () {
          debugPrint('MAP STYLE LOADED');
        },
      ),
    );
  }
}