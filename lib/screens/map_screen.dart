import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecione o Local')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(-15.7942, -47.8822), // Brasília
          zoom: 14,
        ),
        onTap: (LatLng point) {
          setState(() => _selected = point);
        },
        markers: _selected != null
            ? {
          Marker(
            markerId: const MarkerId('selected'),
            position: _selected!,
          )
        }
            : {},
      ),
      floatingActionButton: _selected == null
          ? null
          : FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, _selected); // envia o local de volta
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
