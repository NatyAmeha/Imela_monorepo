import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_tier/loyalty_tier_page.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
import 'package:imela_core/loyalty/model/loyalty_tier.model.dart';
import 'package:imela_core/loyalty/model/reward.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class LoyaltyDetailsViewmodel extends GetxController with BaseViewmodel {
  final LoyaltyUsecase loyaltyUsecase;
  final IExceptiionHandler exceptiionHandler;

  LoyaltyDetailsViewmodel({
    required this.loyaltyUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static LoyaltyDetailsViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<LoyaltyDetailsViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var loyaltyDetail = Rxn<LoyaltyResponse>();
  var customerTier = Rxn<LoyaltyTier>();

  // getters
  AppController get appViewmodel => AppController.getInstance;

  CustomerLoyalty? get customerLoyaltyInfo => loyaltyDetail.value?.customerLoyalty;
  List<Reward> get loyaltyRewards => loyaltyDetail.value?.tier?.rewards ?? [];
  List<Business> get loyaltyBusinesses => loyaltyDetail.value?.tier?.businesses ?? [];

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final businessId = data?[LoyaltyDetailsPage.BUSINESS_ID_KEY] as String;
    final tierId = data?[LoyaltyDetailsPage.TIER_ID_KEY] as String?;
    final context = data?[LoyaltyDetailsPage.CONTEXT_KEY] as BuildContext;
    Future.delayed(Duration.zero, () {
      getBusinessLoyaltyDetailsWithCustomerInfo(context, businessId, tierId);
    });
  }

  Future<void> getBusinessLoyaltyDetailsWithCustomerInfo(BuildContext context, String businessId, String? tierId) async {
    try {
      exception.value = null;
      isLoading.value = true;
      loyaltyDetail.value = null;
      LoyaltyResponse? loyaltyDetailResult;
      if (tierId != null) {
        loyaltyDetailResult = await loyaltyUsecase.getLoyaltyTier(businessId, tierId);
      }
      // else{
      //   loyaltyDetailResult = await loyaltyUsecase.getCustomerTierByPoints(businessId, customerLoyaltyInfo?.points ?? 0);
      // }
      if (loyaltyDetailResult?.success ?? false) {
        loyaltyDetail.value = loyaltyDetailResult;
      }

      final loyaltyInfo = await appViewmodel.getCustomerBusinessLoyalty(context, businessId);
      if (loyaltyInfo?.success ?? false) {
        if (tierId == null) {
          loyaltyDetail.value = loyaltyInfo;
        }
        if (loyaltyInfo?.customerLoyalty != null) {
          loyaltyDetail.value = loyaltyDetail.value?.copyWith(customerLoyalty: loyaltyInfo?.customerLoyalty);
        }
        customerTier.value = loyaltyInfo?.tier;
      }
    } catch (e) {
      print('loyalty details: $e $businessId');
      var ex = exceptiionHandler.getException(e as Exception);
      if (ex.isUnAuthorizedException) {
        return;
      }
      exception(ex);
    } finally {
      isLoading.value = false;
    }
  }

  double getRewardHeight(Reward reward) {
    if (reward.isProductReward()) {
      return 320;
    }
    return 150;
  }

  void goToBusinessRewardPrograms(BuildContext context) {
    final businessId = customerLoyaltyInfo?.businessId ?? '';
    LoyaltyTierListPage.navigate(context, businessId: businessId);
  }
}
