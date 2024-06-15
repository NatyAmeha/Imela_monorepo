import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:melegna_customer/domain/branch/branch.model.dart';
import 'package:melegna_customer/domain/business/model/business.section.dart';
import 'package:melegna_customer/domain/product/product.model.dart';
import 'package:melegna_customer/domain/product/product_bundle.model.dart';
import 'package:melegna_customer/domain/shared/address.model.dart';
import 'package:melegna_customer/domain/shared/base.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
part 'business.model.freezed.dart';
part 'business.model.g.dart';

@freezed
class Business extends BaseModel with _$Business {
  const Business._();
  const factory Business({
    String? id,
    List<LocalizedField>? name,
    List<LocalizedField>? description,
    String? type,
    List<String>? categories,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? creator,
    Gallery? gallery,
    String? productIds,
    List<Product>? products,
    Address? mainAddress,
    String? phoneNumber,
    String? email,
    String? website,
    List<String>? branchIds,
    List<Branch>? branches,
    String? stage,
    List<BusinessSection>? sections,
    String? activeSubscriptionId,
    List<String>? subscriptionIds,
    List<String>? trialPeriodUsedServiceIds,

    // DeliveryInfo? deliveryInfo
    ProductBundle? bundles,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);

  String? getLocalizedBusinessName(String locale) {
    return name?.getLocalizedValue(locale);
  }

}

