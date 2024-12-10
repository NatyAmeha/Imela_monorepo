import 'package:isar/isar.dart';

part 'locationentity.g.dart';

@collection
class LocationEntity {
  Id id = Isar.autoIncrement;
  @Index(unique: true)
  String name;
  AppLatLngEntity? latLng;

  LocationEntity({required this.name, required this.latLng});
}

@embedded 
class AppLatLngEntity {
  double? latitude;
  double? longitude;

  AppLatLngEntity({this.latitude, this.longitude});
}
