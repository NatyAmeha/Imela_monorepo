import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_tier/loyalty_tier_page.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoyaltyTierViewmodel extends GetxController with BaseViewmodel {
  final LoyaltyUsecase loyaltyUsecase;
  final IExceptiionHandler exceptiionHandler;

  LoyaltyTierViewmodel({
    required this.loyaltyUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  // getters
  String get selectedLanguage => AppController.getInstance.selectedLanguage.name;

  static LoyaltyTierViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<LoyaltyTierViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var businessLoyalityTiers = <LoyaltyTier>[].obs;
  late String businessId;
  // getters
  AppController get appViewmodel => AppController.getInstance;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    businessId = data?[LoyaltyTierListPage.BUSINESS_ID_KEY] as String? ?? '';
    var context = data?[LoyaltyTierListPage.CONTEXT_KEY] as BuildContext;
    getBusinessLoyaltyTiers(context);
  }

  Future<void> getBusinessLoyaltyTiers(BuildContext context) async {
    try {
      isLoading(true);
      exception(null);
      businessLoyalityTiers.value = [];
      var tierResponse = await loyaltyUsecase.getBusinessLoyaltyTiers(businessId);
      if (!(tierResponse?.success ?? false)) {
        exception(AppException(message: 'Error occurred, please try again', isMainError: true));
        return;
      }
      if (tierResponse?.tiers?.isEmpty ?? true) {
        exception(AppException(message: 'No loyalty tiers found', isMainError: true));
        return;
      }
      applyBusinessLoyaltyTiers(tierResponse?.tiers ?? []);
      final customerTier = await appViewmodel.getCustomerBusinessLoyalty(context, businessId);
      if (customerTier?.success ?? false) {
        tierResponse?.applyCustomerTier(customerTier?.tier);
      }
      applyBusinessLoyaltyTiers(tierResponse?.tiers ?? []);
    } catch (e) {
      print('error: $e');
      var ex = exceptiionHandler.getException(e as Exception);
      if (!ex.isUnAuthorizedException) {
        exception(ex);
      }

    } finally {
      isLoading(false);
    }
  }

  void applyBusinessLoyaltyTiers(List<LoyaltyTier> tiers) {
    businessLoyalityTiers.value = tiers;
  }

  void navigateToLoyaltyTierDetails(BuildContext context, LoyaltyTier loyaltyTier) {
    LoyaltyDetailsPage.navigate(context, programName: loyaltyTier.name.localize(selectedLanguage), businessId: businessId, tierId: loyaltyTier.id!);
  }
}
