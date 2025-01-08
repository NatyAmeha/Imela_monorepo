import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/business/business_details.viewmodel.dart';
import 'package:imela/presentation/ui/business/business_section/business_section_page.dart';
import 'package:imela/presentation/ui/product/product_details/product_details.page.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_data/network/graphql/graphql_datasource.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class BusinessSectionViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;

  BusinessSectionViewModel({
    required this.businessUsecase,
  });

  static BusinessSectionViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BusinessSectionViewModel>());
  }

  late String businessId;
  late String sectionId;
  String? branchId;

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;
  var sectionInfo = Rxn<BusinessSection>();

  var businessSectionDetails = Rxn<BusinessResponse>();
  var filteredProducts = RxList<Product>();
  var selectedTag = 'All'.obs;

  // getter
  AppController get appViewmodel => AppController.getInstance;
  BusinessDetailsViewModel businessDetailsViewModel = BusinessDetailsViewModel.getInstance();

  ScrollController businessHeaderScrollController = ScrollController();
  String get sectionName => sectionInfo.value?.name.localize(appViewmodel.selectedLanguage.name) ?? '';
  List<Product> get products => businessSectionDetails.value?.products ?? [];

  List<String> get sectionProductstags {
    final tags = businessSectionDetails.value?.products?.map((e) => e.tag ?? []).flattened.toList();
    final distinctTags = tags?.toSet().toList() ?? [];
    distinctTags.insert(0, 'All');
    return distinctTags;
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) async {
    Future.delayed(Duration.zero, () async {
      businessId = data![BusinessSectionPage.BUSINESS_ID_KEY] as String;
      sectionId = data[BusinessSectionPage.SECTION_ID_KEY] as String;
      sectionInfo.value = data[BusinessSectionPage.SECTION_INFO_KEY] as BusinessSection?;
      super.initViewmodel(data: data);

      await getBusinessSectionDetails();
    });
  }

  Future<void> getBusinessSectionDetails({bool isRefresh = false}) async {
    try {
      isLoading.value = true;
      exception.value = null;
      businessSectionDetails.value = null;
      final result = await businessUsecase.getBusinessSectionDetails(businessId, sectionId, fetchPolicy: isRefresh ? ApiDataFetchPolicy.networkOnly : ApiDataFetchPolicy.cacheFirst);
      if (result?.isBusinessSectionDetailsFetchSuccessfull() ?? false) {
        exception.value = AppException(message: 'Failed to load business section details', isMainError: true);
        return;
      }
      if (result?.products?.isEmpty ?? true) {
        exception.value = AppException(message: 'No products found in this section', isMainError: true);
        return;
      }
      businessSectionDetails.value = result;
      filteredProducts.value = products;
    } catch (exception) {
      print("exception data: $exception");
      this.exception.value = AppException.unexpectedError(exception);
    } finally {
      isLoading.value = false;
    }
  }
  void chooseProductsByTags(List<String> value) {
    selectedTag.value = value.first;
    if (selectedTag.value == 'All') {
      filteredProducts.value = products;
    } else {
      filteredProducts.value = products.where((e) => e.tag?.contains(selectedTag.value) ?? false).toList();
    }
  }

  void navigateToProductDetails(BuildContext context, Product productInfo) {
    ProductDetailPage.navigateBeta(context, product: productInfo);
  }

}
