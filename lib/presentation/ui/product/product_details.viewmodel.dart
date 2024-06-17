import 'package:get/get.dart';
import 'package:get/get_connect/sockets/src/socket_notifier.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/product_response.dart';
import 'package:melegna_customer/domain/product/product.usecase.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';

@injectable
class ProductDetailsViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptiionHandler;

  ProductDetailsViewmodel({required this.productUsecase, @Named(AppExceptionHandler.injectName) required this.exceptiionHandler});

  // page state variables
  final productDetails = Rxn<ProductResponse>();
  final isLoading = false.obs;
  final exception = Rxn<AppException>();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final productId = data!['id'] as String;
    getProductDetails(productId);
  }

  // data fetching
  Future<void> getProductDetails(String productId) async {
    try {
      isLoading.value = true;
      productDetails.value = null;
      productDetails.value = await productUsecase.getProductDetails(productId);
    } on AppException catch (e) {
      exception.value = e;
    } catch (e) {
      exception.value = AppException.unexpectedError(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    print("product controller closed");
    super.onClose();
  }
}
