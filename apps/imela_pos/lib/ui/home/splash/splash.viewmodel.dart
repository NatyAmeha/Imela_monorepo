import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/authentication/staff_signin.page.dart';
import 'package:imela_pos/ui/authentication/workspace_auth/workspace_auth.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashViewmodel extends GetxController with BaseViewmodel {
  final IExceptiionHandler exceptiionHandler;

  SplashViewmodel({
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static SplashViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<SplashViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final context = data?['context'];
    checkStaffAuthentication(context);
  }

  Future<void> checkStaffAuthentication(BuildContext context) async {
    try {
      isLoading.value = true;
      WorkspaceAuth.navigate(context);
    } catch (e) {
      // exceptiionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
