import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/ui/business_payment/business_payment_page.dart';
import 'package:imela_admin/ui/business_subscription/components/platform_service_details.dart';
import 'package:imela_admin/ui/business_subscription/components/selected_platform_service_list.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/subscription/model/customization.model.dart';
import 'package:imela_core/subscription/model/platform_service.model.dart';
import 'package:imela_core/subscription/model/subscription_renewal.model.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/exception/exception_type.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/subscription/subscription.usecase.dart';

@injectable
class PlatformServiceViewmodel extends GetxController with BaseViewmodel {
  final SubscriptioniUsecase subscriptionUsecase;
  final IExceptiionHandler exceptiionHandler;

  PlatformServiceViewmodel({
    required this.subscriptionUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  // page variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var allServices = <PlatformService>[].obs;

  var selectedPricingOption = Rxn<SubscriptionRenewal>();
  final _selectedPlatformServices = <PlatformService>[].obs;

  var selectedCustomizations = <String, List<String>>{}.obs;
  var isSelectedServiceInEditMode = false.obs;

  var selectedPlatformServiceForDetailView = Rxn<PlatformService>();

  // getters
  List<Customization> get allCustomizations {
    return allServices.fold<List<Customization>>([], (previousValue, element) {
      final categoryCustomoizations = element.customizationCategories?.map((category) => category.customizations ?? []).flatten().toList() ?? [];
      previousValue.addAll(categoryCustomoizations);
      return previousValue;
    });
  }

  String get selectedPricingOptionId => selectedPricingOption.value?.id ?? '';
  List<PlatformService> get selectedPlatformServices {
    if (_selectedPlatformServices.isEmpty) {
      exception.value = AppException(message: 'No platform service selected', isMainError: true);
      return [];
    }
    exception.value = null;
    return _selectedPlatformServices.value;
  }

  String get getTotalPriceForSelectedService {
    final basePrice = selectedPlatformServiceForDetailView.value?.basePrice ?? 0.0;
    final selectedPricingTotal = selectedPricingOption.value?.getTotalPrice(basePrice) ?? 0.0;
    final customizationTotal = getSelectedCustomizationFullInfo().values.flattened.map((e) => e.additionalPrice).sumBy((element) => element ?? 0);
    return 'ETB ${customizationTotal + selectedPricingTotal}';
  }

  bool get canEnableContinueBtn {
    return selectedPricingOption.value != null && selectedCustomizations.isNotEmpty;
  }

  String get saveOrEditButtonString {
    return isSelectedServiceInEditMode.value ? 'Edit Service' : 'Add Service';
  }

  static PlatformServiceViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<PlatformServiceViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    selectedCustomizations.clear();
    getPlatformServices();
  }

  void cleanupStateVariables() {
    allServices.clear();
    exception.value = null;
    isLoading.value = true;
  }

  Future<void> getPlatformServices() async {
    try {
      cleanupStateVariables();
      final response = await subscriptionUsecase.getPlatformServices();
      if (response.success == true) {
        allServices.value = response.platformServices ?? [];
      } else {
        exception.value = AppException(type: ExceptionType.USER_OWNED_BUSINESS_NOT_FOUND.name);
      }
    } catch (ex) {
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  void addToSelectedCustomization(Map<String, List<String>> customizations) {
    print('customizations data inner ${customizations.length}');
    selectedCustomizations.addAll(customizations);
  }

  Map<String, List<Customization>> getSelectedCustomizationFullInfo() {
    return selectedCustomizations.map((key, value) => MapEntry(key, value.map((e) => allCustomizations.firstWhere((element) => element.id == e)).toList()));
  }

  void handleEditOrAddClick(BuildContext context, PlatformService platformService) {
    isSelectedServiceInEditMode.value ? editSelectedPlatformService(platformService) : addToSelectedPlatformServices(context, platformService);
  }

  void addToSelectedPlatformServices(BuildContext context, PlatformService platformService) {
    final fullSelectedCustomizations = getSelectedCustomizationFullInfo();
    var updatedServiceInfo = platformService.updateSelectedCustomizationInfo(fullSelectedCustomizations);
    selectedCustomizations.clear();
    updatedServiceInfo = updatedServiceInfo.updateSelectedSubscriptionRenewalInfo(selectedPricingOption.value);
    selectedPricingOption.value = null;
    _selectedPlatformServices.add(updatedServiceInfo);
    AppModalSheet.closeModal();
  }

  void removeFromSelectedPlatformServices(String platformServiceId) {
    _selectedPlatformServices.removeWhere((element) => element.id == platformServiceId);
  }

  void editSelectedPlatformService(PlatformService platformService) {
    final index = _selectedPlatformServices.indexWhere((element) => element.id == platformService.id);
    if (index != -1) {
      final fullSelectedCustomizations = getSelectedCustomizationFullInfo();
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
    isSelectedServiceInEditMode.value = true;
    if (platformService != null) {
      AppModalSheet.addPageToModal(
        AppModalSheet.modalContext!,
        ModalContent(
            title: const Text('Service details'),
            content: PlatformServiceDetails(platformService: platformService),
            leading: AppViewmodel.getWidgetFactory(context).createIcon(
                materialIcon: Icons.arrow_back_ios,
                onPressed: () {
                  AppModalSheet.previousPage();
                })),
      );
    }
  }

  Future<void> showPlatformServiceDetailModel(BuildContext context, PlatformService platformService) async {
    selectedPricingOption.value = null;
    selectedPlatformServiceForDetailView.value = platformService;
    selectedCustomizations.clear();
    isSelectedServiceInEditMode.value = false;
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Service details'),
        content: PlatformServiceDetails(platformService: platformService),
      ),
    ]);
  }

  Future<void> showSelectedPlatformServiceListModal(BuildContext context) async {
    await AppModalSheet.showModal(context, type: AppModalSheetType.BOTTOMSHEET, pages: [
      ModalContent(
        title: const Text('Selected platform services'),
        content: const SelectedPlatformServiceList(),
      ),
    ]);
  }

  void updateSelectedPricingOption(SubscriptionRenewal? option) {
    if (option != null) {
      selectedPricingOption.value = option;
    }
  }

  void updateSelectedCustomizations(Map<String, List<Customization>>? customizations) {
    if (customizations != null) {
      selectedCustomizations.value = customizations.map((key, value) => MapEntry(key, value.map((e) => e.id!).toList()));
    }
  }

  bool isPricingOptionSelected(String renewalId) {
    return selectedPricingOption.value?.id == renewalId;
  }

  String getTotalSelectedServiceString() {
    return '${_selectedPlatformServices.length} services';
  }

  void navigateToPaymentPage(BuildContext context) {
    AppModalSheet.closeModal();
    BusinessPaymentPage.navigateTo(context, services: _selectedPlatformServices.value);
  }

  double gridItemWidth(BuildContext context) {
    return Responsive.isSmallScreen(context) ? 350 : 400;
  }
}
