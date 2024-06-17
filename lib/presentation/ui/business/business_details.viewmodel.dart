import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/domain/business/business.usecase.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/business/model/business.section.dart';
import 'package:melegna_customer/domain/product/model/product.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class BusinessDetailsViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  BusinessDetailsViewModel({required this.businessUsecase, 
  @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  @Named(GoRouterService.injectName) required this.router,
  });
  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;
  var businessDetails = Rxn<BusinessResponse>();
  var isAppbarExpanded = true.obs;

  static const businessUiHeaderHeight = 170;

  // getters
  Business? get businessData => businessDetails.value?.business;
  List<BusinessSection> get sections => businessDetails.value?.business?.sections ?? [];

  Map<String, CustomListController<Product>> get businessSectionsWithProductListController {
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
  final productListController = Get.put(CustomListController<Product>());
  late TabController businessSectionTabControllers;
  ScrollController businessHeaderScrollController = ScrollController();

  void assignTabController(int length, TickerProvider vsync) {
    businessSectionTabControllers = TabController(length: length, vsync: vsync);
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final businessId = data!['id'] as String;
    getbusinessDetails(businessId);
  }

  void listenAppbarHeaderScroll() {
    businessHeaderScrollController.addListener(() {
      if (businessHeaderScrollController.offset > businessUiHeaderHeight && isAppbarExpanded.value) {
        isAppbarExpanded(false);
      } else if (businessHeaderScrollController.offset <= businessUiHeaderHeight && !isAppbarExpanded.value) {
        isAppbarExpanded(true);
      }
    });
  }

  Future<void> getbusinessDetails(String id) async {
    try {
      isLoading(true);
      final result = await businessUsecase.getBusinessDetails(id);
      if(result == null){
        exception(AppException(message: 'Business not found'));
      }
      businessDetails.value = result;
      productListController.addItems(result?.products);
    } catch (e) {
      exception(exceptiionHandler.getException(e as Exception));
    } finally {
      isLoading(false);
    }
  }


  // Widget helpers
  List<Widget> getBusinessSectionTabs(){
    return businessSectionsWithProductListController.keys.map((e) => Tab(text: e)).toList();
  }


  // navigation helpers
  void navigateToProductDetails(BuildContext context, Product productInfo) {
    router.navigateTo(context, '/product/${productInfo.id!}', extra:  {'name': productInfo.name?.getLocalizedValue(AppLanguage.ENGLISH.name)});
  }

  
}
