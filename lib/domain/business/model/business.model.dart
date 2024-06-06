import 'package:json_annotation/json_annotation.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
part 'business.model.g.dart';


@JsonSerializable(explicitToJson: true)
class Business{
  final String id;
  final List<LocalizedField> name;
  final String type;
  final List<String> categories;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String creator;

  const Business({
    required this.id,
    required this.name,
    required this.type,
    required this.categories,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.creator,
  });

  factory Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);
  Map<String, dynamic> toJson() => _$BusinessToJson(this);






}