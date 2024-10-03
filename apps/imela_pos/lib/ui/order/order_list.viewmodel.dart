import 'package:get/get.dart';
import 'package:imela_core/order/model/cart.model.dart';
import 'package:imela_core/order/order.usecase.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrderListViewmodel extends GetxController with BaseViewmodel {
  final OrderUsecase orderUsecase;
  final IExceptiionHandler exceptiionHandler;

  OrderListViewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static OrderListViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<OrderListViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var orders = <Order>[].obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    getOrders();
  }

  Future<void> getOrders() async {}
}
