import 'package:json_annotation/json_annotation.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';

part 'business_response.g.dart';

@JsonSerializable()
class BusinessResponse { 
  @JsonKey(name: 'business')
  Business? business;

  @JsonKey(name: 'businesses')
  List<Business>? businesses;

  // @JsonKey(name: 'products')
  // List<Product>? products;

  // @JsonKey(name: 'branches')
  // List<Branch>? branches;

  // @JsonKey(name: 'branchAdded')
  // List<Branch>? branchAdded;

  // @JsonKey(name: 'branchUpdated')
  // List<Branch>? branchUpdated;

  BusinessResponse({
    this.business,
    this.businesses,
  });

  // JSON serialization
  factory BusinessResponse.fromJson(Map<String, dynamic> json) => _$BusinessResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BusinessResponseToJson(this);
}
