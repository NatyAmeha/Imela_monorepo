import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/loyalty/pages/loyalty_details_page.dart';
import 'package:imela_core/loyalty/dto/loyalty.response.dart';
import 'package:imela_core/loyalty/loyalty_usecase.dart';
import 'package:imela_core/loyalty/model/customer_loyalty.model.dart';
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

  // getters
  AppController get appViewmodel => AppController.getInstance;

  CustomerLoyalty? get customerLoyaltyInfo => loyaltyDetail.value?.customerLoyalty;
  List<Reward> get loyaltyRewards => loyaltyDetail.value?.rewards ?? [];

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final loyaltyInfo = data?[LoyaltyDetailsPage.LOYALTY_INFO_KEY] as LoyaltyResponse?;
    final businessId = data?[LoyaltyDetailsPage.BUSINESS_ID_KEY] as String?;
    getCustomerBusinessLoyalty(loyaltyInfo, businessId);
  }

  Future<void> getCustomerBusinessLoyalty(LoyaltyResponse? loyaltyResponse, String? businessId) async {
    try {
      exception.value = null;
      isLoading.value = true;
      loyaltyDetail.value = loyaltyResponse;
      final result = await loyaltyUsecase.getCustomerBusinessLoyalty(businessId ?? '');
      if (result != null && result.success) {
        loyaltyDetail.value = result;
      } else {
        loyaltyDetail.value = loyaltyResponse;
      }
    } catch (e) {
      print('loyalty details: $e $businessId');
      exception(exceptiionHandler.getException(e as Exception));
    } finally {
      isLoading.value = false;
    }
  }
}
