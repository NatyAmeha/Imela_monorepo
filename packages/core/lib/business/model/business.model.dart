import 'package:collection/collection.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/product/model/discount.model.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/base.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/database/entity/localized_field_entity.dart';
import 'package:imela_data/database/entity/pos_business.entity.dart';

part 'business.model.freezed.dart';
part 'business.model.g.dart';

enum BusinessRegistrationStages {
  CREATED,
  SERVICE_SELECTED,
  PAYMENT_STAGE,
  COMPLETED,
}

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
    String? workspaceUrl,
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
    @Default(0) int? totalViews,
    List<PriceList>? priceLists,
    List<PaymentOption>? paymentOptions,
    List<Discount>? discounts,

    // DeliveryInfo? deliveryInfo
    List<ProductBundle>? bundles,
  }) = _Business;

  factory Business.fromJson(Map<String, dynamic> json) => _$BusinessFromJson(json);

  BusinessRegistrationStages get getBusinessStage {
    return BusinessRegistrationStages.values.firstWhereOrNull((e) => e.name == stage) ?? BusinessRegistrationStages.CREATED;
  }

  bool get isBusinessCreated => stage == BusinessRegistrationStages.CREATED.toString();
  bool get isBusinessInPaymentStage => stage == BusinessRegistrationStages.PAYMENT_STAGE.toString();
  bool get isBusinessRegistrationCompleted => stage == BusinessRegistrationStages.COMPLETED.toString();

  String? getLocalizedBusinessName(String locale) {
    return name?.localize(locale);
  }

  POSBusinessEntity toPOSBusinessEntity() {
    return POSBusinessEntity(
      name: name?.map((e) => LocalizedFieldEntity(key: e.key, value: e.value)).toList() ?? [],
      workspaceUrl: workspaceUrl!,
      phoneNumber:  phoneNumber!,
      

    );
  }

  List<ProductAddon> getSectionsOrderAddon(List<String> sectionIds){
    if(sections == null) return [];
    final addons = <ProductAddon>[];
    sections?.forEach((section) {
      if (sectionIds.contains(section.id)) {
        addons.addAll(section.orderAddons ?? []);
      }
    });
    return addons;
  }
}
