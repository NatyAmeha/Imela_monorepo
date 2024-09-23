import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_data/network/graphql/__generated__/schema.schema.gql.dart';

part 'address.model.freezed.dart';
part 'address.model.g.dart';

@freezed
class Address with _$Address {
  const Address._();
  const factory Address({
    String? id,
    String? address,
    required String city,
    String? location,
  }) = _Address;

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);


  Function toGraphQLInput() {
    return (b) => b
      ..address = address
      ..city = city
      ..location = location;
  }
}
