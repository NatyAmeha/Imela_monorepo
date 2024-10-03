import 'package:imela_data/database/entity/localized_field_entity.dart';
import 'package:isar/isar.dart';

part 'pos_business.entity.g.dart';

@collection
class POSBusinessEntity {
  Id id = Isar.autoIncrement;
  List<LocalizedFieldEntity> name = [];
  String workspaceUrl;
  String phoneNumber;
  String? email;
  List<String>? categories;
  List<BusinessSectionEntity>? sections;
  List<PriceListEntity> priceLists;
  List<PaymentOptionEntity>? paymentOptions;

  POSBusinessEntity({
    required this.name,
    required this.workspaceUrl,
    required this.phoneNumber,
    this.email,
    this.categories = const [],
    this.sections = const [],
    this.priceLists = const [],
    this.paymentOptions = const [],
  });
}

@embedded
class BusinessSectionEntity {
  String? id;
  List<LocalizedFieldEntity>? name;
  String? categoryId;
  List<String>? productIds;
  List<String>? images;
  List<LocalizedFieldEntity>? description;

  BusinessSectionEntity({
    this.id,
    this.name,
    this.categoryId,
    this.productIds,
    this.images,
    this.description,
  });
}

@embedded
class PaymentOptionEntity {
  String? id;
  List<LocalizedFieldEntity>? name;
  String? type;
  double? upfrontPayment;
  DateTime? dueDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  PaymentOptionEntity({
    this.id,
    this.name,
    this.type,
    this.upfrontPayment,
    this.dueDate,
    this.createdAt,
    this.updatedAt,
  });
}

@embedded
class PriceListEntity {
  String? id;
  List<LocalizedFieldEntity>? name;
  List<LocalizedFieldEntity>? description;
  List<String>? branchIds;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  PriceListEntity({
    this.name,
    this.description,
    this.branchIds,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });
}
