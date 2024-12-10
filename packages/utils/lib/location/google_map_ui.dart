// utils_package/lib/src/widgets/custom_map_component.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imela_utils/location/location_info.dart';

class GoogleMapUI extends StatelessWidget {
  final AppLatLng initialLocation;
  final void Function(AppLatLng) onLocationSelected;

  const GoogleMapUI({
    Key? key,
    required this.initialLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(initialLocation.latitude, initialLocation.longitude),
        zoom: 15,
      ),
      onTap: (latLng) {
        // Notify parent widget about selected location
        onLocationSelected(AppLatLng(latLng.latitude, latLng.longitude));
      },
      markers: {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: LatLng(initialLocation.latitude, initialLocation.longitude),
        ),
      },
    );
  }
}
