import 'package:get/get.dart';
import 'package:imela/presentation/ui/shared/base_viewmodel.dart';
import 'package:imela/services/routing_service.dart';
import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/branch.usecase.dart';

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
