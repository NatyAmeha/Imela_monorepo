import 'package:imela_data/database/entity/locationentity.dart';
import 'package:imela_utils/location/location_info.dart';

class Location {
  final int? id;
  final String name;
  final AppLatLng latLng;

  Location({this.id, required this.name, required this.latLng});

  // LocationEntity toLocationEntity() {
  //   return LocationEntity(name: name, latLng: AppLatLngEntity(latitude: latLng.latitude, longitude: latLng.longitude));
  // }

  // static Location fromLocationEntity(LocationEntity entity) {
  //   return Location(id: entity.id, name: entity.name, latLng: AppLatLng(entity.latLng?.latitude ?? 0, entity.latLng?.longitude ?? 0));
  // }
}
