import 'package:imela_data/database/entity/localized_field_entity.dart';
import 'package:isar/isar.dart';

part 'pos_customer_entity.g.dart';

@collection
class PosCustomerEntity {
  Id dbId = Isar.autoIncrement;
  String id;
  String name;
  String? userId;
  String? businessId;
  String? phoneNumber;
  String? email;
  List<CustomerLoyaltyEntity>? customerLoyalties;
  DateTime? createdAt;
  DateTime? updatedAt;

  PosCustomerEntity({
    required this.id,
    required this.name,
    this.userId,
    this.businessId,
    this.phoneNumber,
    this.email,
    this.customerLoyalties,
    this.createdAt,
    this.updatedAt,
  });
}

@embedded
class CustomerLoyaltyEntity {
  String? id;
  String? customerId;
  List<LocalizedFieldEntity>? name;
  String? businessId;
  double? currentPoints;
  DateTime? createdAt;
  DateTime? updatedAt;

  CustomerLoyaltyEntity({
    this.id,
    this.customerId,
    this.name,
    this.businessId,
    this.currentPoints,
    this.createdAt,
    this.updatedAt,
  });
}
