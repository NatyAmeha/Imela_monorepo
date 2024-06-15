import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/domain/business/business.usecase.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/business/model/business.section.dart';
import 'package:melegna_customer/domain/product/product.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

@injectable
class BusinessDetailsViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;
  BusinessDetailsViewModel({required this.businessUsecase, @Named(AppExceptionHandler.injectName) required this.exceptiionHandler});
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = "".obs;

  var businessDetails = Rxn<BusinessResponse>();
  final productListController = Get.put(CustomListController<Product>());
  Business? get businessData => businessDetails.value?.business;

  List<BusinessSection> get sections => businessDetails.value?.business?.sections ?? [];
  Map<String, CustomListController> get sectionsWithProducts {
    var sectionsWithProducts = {'Overview': productListController};
    
    for (var section in sections) {
      if (section.name.getLocalizedValue(AppLanguage.ENGLISH.name) != null) {
        var products = productListController.items.where((element) => section.productIds?.contains(element.id) == true).toList();
        final sectionName = section.name.getLocalizedValue(AppLanguage.ENGLISH.name)!;
        var newProductListController = Get.put(CustomListController<Product>(), tag: sectionName);
        newProductListController.addItems(products);
        sectionsWithProducts[sectionName] = newProductListController;
      }
    }
    return sectionsWithProducts;
  }

  List<String> get categories => businessDetails.value?.business?.categories ?? [];

  // widget controllers
  var businessOfferringListController = CustomListController<String>();
  late TabController businessSectionTabControllers;
  businesofferingList() {
    businessOfferringListController.addItems(businessDetails.value?.business?.categories ?? []);
  }

  @override
  void initViewmodel() {
    super.initViewmodel();
    getbusinessDetails();
    businesofferingList();
  }

  assignTabController(int length,  TickerProvider vsync) {
    businessSectionTabControllers = TabController(length: length, vsync: vsync);
    businessSectionTabControllers.addListener(() {
      if (businessSectionTabControllers.indexIsChanging) {
      }
    });
  }

  Future<void> getbusinessDetails() async {
    try {
      isLoading(true);
      print("viewmodel getbusinessDetails");
      final result = await businessUsecase.getBusinessDetails("662505ca50948fabb12180ba");
      businessDetails.value = result;
      productListController.addItems(result?.products);
    } catch (e) {
      exception(exceptiionHandler.getException(e as Exception));
    } finally {
      isLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
