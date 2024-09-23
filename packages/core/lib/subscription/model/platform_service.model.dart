import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_core/subscription/model/subscription_renewal.model.dart';

part 'platform_service.model.freezed.dart';
part 'platform_service.model.g.dart';

@freezed
class PlatformService with _$PlatformService {
  const PlatformService._();
  const factory PlatformService({
    String? id,
    List<LocalizedField>? name,
    String? type,
    List<LocalizedField>? description,
    double? basePrice,
    String? image,
    List<LocalizedField>? features,
    List<CustomizationCategory>? customizationCategories,
    List<String>? relatedServicesId,
    List<PlatformService>? relatedServices,
    List<SubscriptionRenewal>? subscriptionRenewalInfo,

    // not part of the api
    Map<String, List<Customization>>? selectedCustomization,
    SubscriptionRenewal? selectedSubscriptionRenewal,
  }) = _PlatformService;

  factory PlatformService.fromJson(Map<String, dynamic> json) => _$PlatformServiceFromJson(json);

  String getBasePriceString(String currency) {
    return 'Starting at $currency $basePrice / month';
  }

  String renewalOptionsString() {
    return '${subscriptionRenewalInfo?.length} options available';
  }

  bool hasTrialPeriod(String renewalId) {
    final selectedSubscriptionRenewalInfo = subscriptionRenewalInfo?.firstWhere((info) => info.id == renewalId);
    if (selectedSubscriptionRenewalInfo?.trialPeriod != null && selectedSubscriptionRenewalInfo!.trialPeriod > 0) {
      return true;
    }
    return false;
  }

  List<String>? getSelectedCustomizationNameList(String selectedLanguage) {
    
    return selectedCustomization?.values.expand((element) => element).map((e) => e.name!.localize(selectedLanguage)).toList();
  }

  double getTotalPrice() {
    final customizations = selectedCustomization?.values.flattened.toList();
    final totalAdditionalPrice = customizations?.sumBy((element) => element.additionalPrice ?? 0);
    final selectedRenewalPricing =  selectedSubscriptionRenewal?.getTotalPrice(basePrice ?? 0) ?? 0.0;
    print('total ${selectedRenewalPricing + (totalAdditionalPrice ?? 0)}');
    return selectedRenewalPricing + (totalAdditionalPrice ?? 0);
  }

  String totalCustomizationPriceString(String currency) {
    return '$currency ${getTotalPrice()}';
  }

  PlatformService updateSelectedCustomizationInfo(Map<String, List<Customization>> customizations) {
    return copyWith(selectedCustomization: customizations);
  }

  PlatformService updateSelectedSubscriptionRenewalInfo(SubscriptionRenewal? subscriptionRenewal) {
    if (subscriptionRenewal == null) {
      return this;
    }
    return copyWith(selectedSubscriptionRenewal: subscriptionRenewal);
  }
}


