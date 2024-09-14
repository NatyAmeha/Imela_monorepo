import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business_payment/business_payment_page.dart';
import 'package:imela_admin/ui/business_subscription/components/platform_service_details.dart';
import 'package:imela_admin/ui/business_subscription/components/selected_platform_service_list.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_core/subscription/model/subscription_renewal.model.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class PlatformServiceViewmodel extends GetxController with BaseViewmodel {
  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();
  double gridItemWidth(BuildContext context) {
    return Responsive.isSmallScreen(context) ?  350 : 400;
  }
  // page variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var allServices = <PlatformService>[].obs;
  List<Customization> get allCustomizations {
    return allServices.fold<List<Customization>>([], (previousValue, element) {
      final categoryCustomoizations = element.customizationCategories?.map((category) => category.customizations ?? []).flatten().toList() ?? [];
      previousValue.addAll(categoryCustomoizations);
      return previousValue;
    });
  }

  var selectedPricingOption = Rxn<SubscriptionRenewal>();
  final _selectedPlatformServices = <PlatformService>[].obs;
  String get selectedPricingOptionId => selectedPricingOption.value?.id ?? '';
  List<PlatformService> get selectedPlatformServices {
    if (_selectedPlatformServices.isEmpty) {
      exception.value = AppException(message: 'No platform service selected', isMainError: true);
      return [];
    }
    exception.value = null;
    return _selectedPlatformServices.value;
  }

  var selectedCustomizations = <String, List<String>>{}.obs;

  static PlatformServiceViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<PlatformServiceViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    allServices.value = data!['platformServices'];
  }

  void addToSelectedCustomization(Map<String, List<String>> customizations) {
    selectedCustomizations.addAll(customizations);
  }

  void addToSelectedPlatformServices(BuildContext context, PlatformService platformService) {
    final fullSelectedCustomizations = selectedCustomizations.map((key, value) => MapEntry(key, value.map((e) => allCustomizations.firstWhere((element) => element.id == e)).toList()));
    final updatedServiceInfo = platformService.updateSelectedCustomizationInfo(fullSelectedCustomizations).updateSelectedSubscriptionRenewalInfo(selectedPricingOption.value);
    _selectedPlatformServices.add(updatedServiceInfo);
    selectedCustomizations.clear();
    selectedPricingOption.value = null;
    AppModalSheet.closeModal();
  }

  void removeFromSelectedPlatformServices(String platformServiceId) {
    _selectedPlatformServices.removeWhere((element) => element.id == platformServiceId);
  }

  void editSelectedPlatformService(PlatformService platformService) {
    final index = _selectedPlatformServices.indexWhere((element) => element.id == platformService.id);
    if (index != -1) {
      final fullSelectedCustomizations = selectedCustomizations.map((key, value) => MapEntry(key, value.map((e) => allCustomizations.firstWhere((element) => element.id == e)).toList()));
      final updatedServiceInfo = platformService.updateSelectedCustomizationInfo(fullSelectedCustomizations).updateSelectedSubscriptionRenewalInfo(selectedPricingOption.value);
      _selectedPlatformServices[index] = updatedServiceInfo;
      selectedCustomizations.clear();
      selectedPricingOption.value = null;
      _selectedPlatformServices.refresh();
      AppModalSheet.closeModal();
    }
  }

  void addEditServiceDetailPagetoOpenedModal(BuildContext context, String platformServiceId) {
    final platformService = _selectedPlatformServices.firstWhereOrNull((element) => element.id == platformServiceId);
    if (platformService != null) {
      AppModalSheet.addPageToModal(
        AppModalSheet.modalContext!,
        ModalContent(
            title: const Text('Service details'),
            content: PlatformServiceDetails(platformService: platformService, isEditMode: true),
            leading: AppViewmodel.getWidgetFactory(context).createIcon(
                materialIcon: Icons.arrow_back_ios,
                onPressed: () {
                  AppModalSheet.previousPage();
                })),
      );
    }
  }

  Future<void> showPlatformServiceDetailModel(BuildContext context, PlatformService platformService) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Service details'),
        content: PlatformServiceDetails(platformService: platformService),
      ),
    ]);
  }

  Future<void> showSelectedPlatformServiceListModal(BuildContext context) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(title: const Text('Selected platform services'), content: const SelectedPlatformServiceList(),),
    ]);
  }

  void updateSelectedPricingOption(SubscriptionRenewal? option) {
    if (option != null) {
      selectedPricingOption.value = option;
    }
  }

  bool isPricingOptionSelected(String renewalId) {
    return selectedPricingOption.value?.id == renewalId;
  }

  String getTotalSelectedServiceString() {
    return '${_selectedPlatformServices.length} services';
  }

  void navigateToPaymentPage(BuildContext context) {
    BusinessPaymentPage.navigateTo(context, services: _selectedPlatformServices);
  }
}
