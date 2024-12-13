import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/membership/membership_plan_list/membership_plan_list_page.dart';
import 'package:imela_core/membership/membership_usecase.dart';
import 'package:imela_core/membership/model/membership.model.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class MembershipPLanListViewModel extends GetxController with BaseViewmodel {
  final MembershipUseCase membershipUseCase;

  MembershipPLanListViewModel({required this.membershipUseCase});

  static MembershipPLanListViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<MembershipPLanListViewModel>());
  }

  late String businessId;
  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var membershipPlans = <Membership>[].obs;

  // getters
  AppController get appViewmodel => AppController.getInstance;
  String get selectedLanguage => appViewmodel.selectedLanguage.name;
  String get selectedCurrency => appViewmodel.selectedCurrency.name;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      businessId = data?[MembershipPlanListPage.BUSINESS_ID_KEY] ?? '';
      getMembershipPlans();
    });
  }

  Future<void> getMembershipPlans() async {
    try {
      isLoading.value = true;
      exception.value = null;
      membershipPlans.value = [];
      final result = await membershipUseCase.getBusinessMembershipPlans(businessId);
      if (result == null || result.success == false) {
        exception.value = AppException(message: "something went wrong");
      }
      if (result!.memberships?.isEmpty == true) {
        exception.value = AppException(message: "No membership plans found");
      }
      membershipPlans.addAll(result.memberships ?? []);
    } catch (e) {
      print('exception $e');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToMembershipDetails(BuildContext context, Membership membership) {
    MembershipDetailsPage.navigate(context, membership.id!);
  }
}
