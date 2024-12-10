import 'package:imela_data/database/entity/localized_field_entity.dart';
import 'package:imela_data/database/entity/price_entity.dart';
import 'package:isar/isar.dart';

part 'pos_order_entity.g.dart';

@collection
@Name('pos_order')
class OrderEntity {
  Id dbId = Isar.autoIncrement;
  String? id;
  int? orderNumber;
  String? status;
  List<OrderItem>? items;
  String? userId;
  String? paymentType;
  double? subTotal;
  List<ItemDiscount>? discount;
  double? totalAmount;
  double? paidAmount;
  double? remainingAmount;
  List<SelectedPaymentMethod>? paymentMethods;
  String? note;
  List<String>? businessId;
  String? branchId;
  DateTime? createdAt;
  DateTime? updatedAt;

  OrderEntity({
    this.id,
    this.orderNumber,
    this.status,
    this.items,
    this.userId,
    this.paymentType,
    this.subTotal,
    this.discount,
    this.totalAmount,
    this.paidAmount,
    this.remainingAmount,
    this.paymentMethods,
    this.note,
    this.businessId,
    this.branchId,
    this.createdAt,
    this.updatedAt,
  });
}

@embedded
class OrderItem {
  String? id;
  List<LocalizedFieldEntity>? name;
  double quantity;
  String? branchId;
  String? image;
  String? productId;
  double? originalPrice;
  double? subTotal;
  double? total;
  double? point;
  double? tax;
  List<ItemDiscount>? discount;
  List<OrderConfig>? config;

  OrderItem({
    this.id,
    this.name,
    this.quantity = 0.0,
    this.branchId,
    this.image,
    this.productId,
    this.originalPrice,
    this.subTotal,
    this.total,
    this.point,
    this.tax,
    this.discount,
    this.config,
  });
}

@embedded
class ItemDiscount {
  String? id;
  List<LocalizedFieldEntity>? name;
  double? amount;
  List<String>? claimedRewardId;

  ItemDiscount({
    this.id,
    this.name,
    this.amount,
    this.claimedRewardId,
  });
}

@embedded
class OrderConfig {
  List<LocalizedFieldEntity>? name;
  String? type;
  String? singleValue;
  List<String>? multipleValue;
  List<String>? productIds;
  double additionalPrice;
  String? addonId;

  OrderConfig({
    this.name,
    this.type,
    this.singleValue,
    this.multipleValue,
    this.productIds,
    this.additionalPrice = 0.0,
    this.addonId,
  });
}

@embedded
class SelectedPaymentMethod {
  String? id;
  List<LocalizedFieldEntity>? name;
  PriceEntity? amount;
  bool requireReceiptImag;
  List<String>? receiptImages;

  SelectedPaymentMethod({
    this.id,
    this.name,
    this.amount,
    this.requireReceiptImag = false,
    this.receiptImages,
  });
}
