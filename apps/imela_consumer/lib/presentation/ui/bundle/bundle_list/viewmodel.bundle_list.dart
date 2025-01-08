import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/bundle/bundle_list/bundle_list_page.dart';
import 'package:imela_core/bundle/bundle.usecase.dart';
import 'package:imela_core/bundle/model/bundle.response.dart';
import 'package:imela_core/bundle/model/product_bundle.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';
import 'package:imela/services/routing_service.dart';

enum BundleListFetchPolicy { all, favorite, recent, previous }

@injectable
class BundleListViewModel extends GetxController with BaseViewmodel {
  final BundleUsecase bundleUsecase;
  final IExceptiionHandler exceptionHandler;
  final IRoutingService router;

  BundleListViewModel({
    required this.bundleUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // Observable variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var bundles = <ProductBundle>[].obs;

  // Getter
  AppController get appController => AppController.getInstance;

  // Current fetch policy
  var currentFetchPolicy = BundleListFetchPolicy.all.name.obs;

  static BundleListViewModel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BundleListViewModel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final bundleListFromPreviousPage = data?[BundleListPage.BUNDLES_KEY] as List<ProductBundle>? ?? [];
    Future.delayed(Duration.zero, () {
      if (bundleListFromPreviousPage.isNotEmpty) {
        bundles.value = bundleListFromPreviousPage;
      }
      fetchBundles();
    });
  }

  Future<void> fetchBundles() async {
    try {
      isLoading(true);
      exception(null);

      final result = await _getBundlesBasedOnPolicy();
      if (result != null) {
        // bundles.value = result;
      }
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<List<BundleResponse>?> _getBundlesBasedOnPolicy() async {
    // switch (currentFetchPolicy.value) {
    //   case BundleListFetchPolicy.all:
    //     return await bundleUsecase.getAllBundles();
    //   case BundleListFetchPolicy.favorite:
    //     return await bundleUsecase.getFavoriteBundles();
    //   case BundleListFetchPolicy.recent:
    //     return await bundleUsecase.getRecentBundles();
    //   case BundleListFetchPolicy.previous:
    //     return await bundleUsecase.getPreviousBundles();
    // }
  }

  void changeFetchPolicy(BundleListFetchPolicy policy) {
    if (currentFetchPolicy.value != policy.name) {
      currentFetchPolicy.value = policy.name;
      fetchBundles();
    }
  }

  void refreshBundles() {
    fetchBundles();
  }

  @override
  void dispose() {
    bundles.clear();
    exception.value = null;
    super.dispose();
  }
}
