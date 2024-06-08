import 'package:freezed_annotation/freezed_annotation.dart';

part 'address.model.freezed.dart';
part 'address.model.g.dart';

@freezed
class Address with _$Address {
  const factory Address({
    String? id,
    String? address,
    required String city,
    String? location,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
}