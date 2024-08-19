import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/response.model.dart/branch.response.dart';
import 'package:melegna_customer/domain/branch/branch.usecase.dart';
import 'package:melegna_customer/domain/branch/model/branch.model.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';
import 'package:melegna_customer/services/routing_service.dart';

@injectable
class BranchDetailViewmodel extends GetxController with BaseViewmodel {
  final BranchUsecase branchUsecase;
  final IExceptiionHandler exceptiionHandler;
  final IRoutingService router;

  BranchDetailViewmodel({
    required this.branchUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
    @Named(GoRouterService.injectName) required this.router,
  });

  // page state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = ''.obs;
  var isAppbarExpanded = true.obs;

  var branchDetailsResponse = Rxn<BranchResponse>();
  Branch get branchInfo => branchDetailsResponse.value!.branch!;


  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
  }
}
