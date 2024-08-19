import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/domain/order/order.usecase.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class OrderDetailviewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;
  OrderUsecase orderUsecase;

  OrderDetailviewmodel({
    required this.orderUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
  }
}
