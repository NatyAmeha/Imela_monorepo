import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:geolocator/geolocator.dart';
import 'package:imela_utils/location/location_info.dart';
import 'package:injectable/injectable.dart';

abstract class ILocationService {
  Future<AppLatLng> getCurrentLocation();
  Future<String> getAddressFromLatLng(AppLatLng latLng);
  Future<List<SearchResult>> searchPlaces(String query);
  void setMapController(dynamic controller); // Use dynamic type since it's abstract here
  double calculateDistance(AppLatLng from, AppLatLng to);
  AppLatLng findNearestLocation(List<AppLatLng> locations, AppLatLng targetLocation);
}

@Injectable(as: ILocationService)
@Named(LocationService.injectName)
class LocationService implements ILocationService {
  static const injectName = 'LocationService';
  late dynamic _mapController;

  LocationService(); // Initialize with the Places SDK API key

  @override
  Future<AppLatLng> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high, forceAndroidLocationManager: true);
    return AppLatLng(position.latitude, position.longitude);
  }

  @override
  Future<String> getAddressFromLatLng(AppLatLng latLng) async {
    // Implement Geocoding logic using Google Geocoding API or any alternative API
    // Return a dummy address for now
    
    return "123 Main Street, Example City";
  }

  @override
  Future<List<SearchResult>> searchPlaces(String query) async {
    try {
      // Use autocomplete predictions for the search query
      final placesSdk = FlutterGooglePlacesSdk("AIzaSyCVd5XDKVV5K0TmznvClUaqy6F51wvYkRw");
      final response = await placesSdk.findAutocompletePredictions(query, countries: ['et']);

      if (response.predictions.isNotEmpty) {
        final results = <SearchResult>[];

        for (var prediction in response.predictions) {
          // Fetch the place details for each prediction to get the location
          final placeDetails = await placesSdk.fetchPlace(
            prediction.placeId,
            fields: [
              PlaceField.Name,
              PlaceField.Location,
            ],
          );

          final latLng = placeDetails.place?.latLng;
          if (latLng != null) {
            results.add(
              SearchResult(
                name: prediction.primaryText ?? '',
                location: AppLatLng(latLng.lat, latLng.lng),
              ),
            );
          }
        }
        return results;
      }
      return [];
    } catch (e) {
      // Handle errors appropriately
      print('Error searching places: $e');
      rethrow;
    }
  }

  @override
  void setMapController(dynamic controller) {
    _mapController = controller; // Store the map controller instance
  }

  @override
  double calculateDistance(AppLatLng from, AppLatLng to) {
    return Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  @override
  AppLatLng findNearestLocation(List<AppLatLng> locations, AppLatLng targetLocation) {
    
    if (locations.isEmpty) {
      throw ArgumentError('Locations list cannot be empty');
    }

    AppLatLng nearestLocation = locations.first;
    double shortestDistance = calculateDistance(targetLocation, locations.first);

    for (var location in locations) {
      double distance = calculateDistance(targetLocation, location);
      if (distance < shortestDistance) {
        shortestDistance = distance;
        nearestLocation = location;
      }
    }

    return nearestLocation;
  }
}
