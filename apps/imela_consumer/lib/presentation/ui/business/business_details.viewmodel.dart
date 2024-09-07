import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/bundle/bundle_detail/bundle_detail.page.dart';
import 'package:imela/presentation/ui/product/product_list/product_list_page.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:imela/presentation/ui/shared/list/list_display_style.constants.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'component/business_info.dart';

@injectable
class BusinessDetailsViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  BusinessDetailsViewModel({
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

// widget controllers
  final productListController = Get.put(CustomListController<Product>(), tag: 'AllProducts');
  late TabController businessSectionTabControllers;
  ScrollController businessHeaderScrollController = ScrollController();

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;
  var businessDetails = Rxn<BusinessResponse>();
  var isAppbarExpanded = true.obs;

  Map<String, CustomListController<Product>> sectionsWithProductsControllers = {};
  static const businessUiHeaderHeight = 170;

  // getters
  Business? get businessData => businessDetails.value?.business;
  List<BusinessSection> get sections => businessDetails.value?.business?.sections ?? [];
  List<Product> get featuredProducts => businessDetails.value?.products?.where((element) => element.featured == true).toList() ?? [];
  List<Branch> get businessBranches => businessDetails.value?.branches ?? [];
  List<PaymentOption> get businessPaymentOption => businessData?.paymentOptions ?? [];

  List<ProductBundle> get businessBundles  => businessData?.bundles ?? [];

  void createBusinessSectionsWithProductListController() {
    sectionsWithProductsControllers = {'Overview': productListController};
    for (var section in sections) {
      final sectionName = section.name?.localize('ENGLISH');
      if (sectionName?.isNotEmpty == true) {
        var products = productListController.items.where((element) => section.productIds?.contains(element.id) == true).toList();
        var newProductListController = Get.put(CustomListController<Product>(), tag: sectionName);
        newProductListController.addItems(products);
        sectionsWithProductsControllers[sectionName!] = newProductListController;
      }
    }
  }

  List<String> get categories => businessDetails.value?.business?.categories ?? [];

  void assignTabController(int length, TickerProvider vsync) {
    businessSectionTabControllers = TabController(length: length, vsync: vsync);
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final businessId = data!['id'] as String;
    getBusinessDetails(businessId);
  }

  void listenAppbarHeaderScroll() {
    businessHeaderScrollController.addListener(() {
      if (businessHeaderScrollController.offset > businessUiHeaderHeight) {
        isAppbarExpanded(false);
      } else if (businessHeaderScrollController.offset <= businessUiHeaderHeight) {
        isAppbarExpanded(true);
      }
    });
  }

  Future<void> getBusinessDetails(String id) async {
    try {
      cleanupStateVariables();
      isLoading(true);
      final response = await businessUsecase.getBusinessDetails(id);
      if (response?.isBusinessDetailFetchSuccessfull() == true) {
        businessDetails.value = response;
        productListController.addItems(response!.products);
        createBusinessSectionsWithProductListController();
      } else {
        exception(AppException(message: 'Business not found'));
      }
    } catch (e) {
      exception(exceptiionHandler.getException(e as Exception));
    } finally {
      isLoading(false);
    }
  }

  void showBusinessInfoDialog(BuildContext context, WidgetFactory widgetFactory) {
    widgetFactory.createModalBottomSheet(context, initialHeight: 1.0, content: (scrollController) {
      return BusinessInfoDialog(
        business: businessData!,
        branches: businessBranches,
        widgetFactory: widgetFactory,
        onClose: () {
          router.goBack(context);
        },
      );
    });
  }

  void navigateToFeaturedProductListPage(BuildContext context) {
    router.navigateTo(context, '${ProductListPage.baseRouteName}/featured', extra: {'title': 'Featured products', 'products': featuredProducts, 'displayStyle': ListDisplayStyle.List});
  }

  void navigateToAllProductsPage(BuildContext context) {
    router.navigateTo(context, '${ProductListPage.baseRouteName}/all', extra: {'title': 'All products', 'products': businessDetails.value?.products, 'displayStyle': ListDisplayStyle.Grid});
  }

  // Widget helpers
  List<Widget> getBusinessSectionTabs() {
    return sectionsWithProductsControllers.keys.map((e) => Tab(text: e)).toList();
  }

  // navigation helpers
  void navigateToProductDetails(BuildContext context, Product productInfo) {
    router.navigateTo(context, '/product/${productInfo.id!}', extra: {'name': productInfo.name?.localize('ENGLISH')});
  }

  void navigateToBundleDetailPage(BuildContext context, ProductBundle bundle, {Widget? previousPage}) {
    BundleDetailPage.navigateToBundleDetailPage(context, router, bundle);
  }

  void cleanupStateVariables() {
    isLoading(false);
    businessDetails.value = null;
    exception.value = null;
    productListController.items.clear();
    sectionsWithProductsControllers.forEach((key, value) {
      value.items.clear();
    });
  }

  @override
  void dispose() {
    print("dispose business details viewmodel");

    // businessHeaderScrollController.dispose();
    sectionsWithProductsControllers.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
