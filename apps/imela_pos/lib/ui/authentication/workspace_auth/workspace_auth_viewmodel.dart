import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/branch.usecase.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business_response.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/authentication/staff_signin.page.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class WorkspaceAuthViewmodel extends GetxController with BaseViewmodel {
  final BusinessUsecase authUsecase;
  final BusinessUsecase businessUsecase;
  final BranchUsecase branchUsecase;
  final IExceptiionHandler exceptiionHandler;

  WorkspaceAuthViewmodel({
    required this.authUsecase,
    required this.businessUsecase,
    required this.branchUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static WorkspaceAuthViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<WorkspaceAuthViewmodel>());
  }

  final workspaceInputController = TextEditingController();

  var workspaceInput = ''.obs;

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  // getters
  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    Future.delayed(Duration.zero, () {
      handleWorkspaceUrlInitialInput();
    });
  }

  void onWorkspaceInputChanged(String value) {
    workspaceInput.value = value;
  }

  void checkBusinessWorkspace(BuildContext context) async {
    try {
      if (workspaceInput.value.isEmpty) {
        exception.value = AppException(message: "Workspace is required", isMainError: false);
        return;
      }
      isLoading.value = true;
      final result = await businessUsecase.getBusinessByWorkspaceUrl(workspaceInput.value);
      if (!result.isBusinessFetchForPOSSuccessfull) {
        exception.value = AppException(message: result!.message ?? "Unable to authenticate this staff", isMainError: false);
        return;
      }
      appviewmodel.setSelectedBusiness(result!.business!);
      POSStaffSignInPage.navigate(context);
    } catch (e) {
      print(e);
      exception.value = e as AppException;
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> handleWorkspaceUrlInitialInput() async {
    try {
      final url = await businessUsecase.getWorkspaceUrlFromPreference();
      if (url != null) {
        workspaceInputController.text = url;
        workspaceInput.value = url;
      }
    } catch (e) {
      print(e);
    }
  }
}
