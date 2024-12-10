class AppLatLng {
  final double latitude;
  final double longitude;

  AppLatLng(this.latitude, this.longitude);
}

class SearchResult {
  final String name;
  final AppLatLng location;

  SearchResult({required this.name, required this.location});
}
