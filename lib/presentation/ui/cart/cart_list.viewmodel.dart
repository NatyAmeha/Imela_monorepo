import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/order/model/cart.model.dart';
import 'package:melegna_customer/domain/order/order.usecase.dart';
import 'package:melegna_customer/presentation/ui/app_controller.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list/list_componenet.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';

@injectable
class CartListViewmodel extends GetxController with BaseViewmodel {
  static const FETCH_CART_FROM_API_KEY = 'fetch_cart_from_api';

  // page state variables
  final isLoading = false.obs;
  final exception = Rxn<AppException>();

  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;
  CartListViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppController get appController => AppController.getInstance;

  List<Cart> get carts => appController.carts;

  //controller
  var cartListController = Get.put(CustomListController<Cart>(), tag: 'businessListController');

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    final fetchCartFromApi = data?[FETCH_CART_FROM_API_KEY] as bool? ?? true;
    super.initViewmodel(data: data);
    if (fetchCartFromApi) {
      getCartsFromApi();
    }
  }

  Future<void> getCartsFromApi() async {
    try {
      isLoading(true);
      final response = await orderUsecase.getUserCartList();
      if (response?.success == true && response?.carts?.isNotEmpty == true) {
        appController.addToCart(response?.carts ?? []);
      }
      cartListController.setItems(appController.carts);
      
    } catch (ex) {
      print("exception ${ex.toString()}");
      exception.value = exceptiionHandler.getException(ex as Exception);
    } finally {
      isLoading(false);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
