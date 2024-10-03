import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/branch/branch.usecase.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/branch.response.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/home/home_page.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class BranchSelectionViewmodel extends GetxController with BaseViewmodel {
  final BranchUsecase branchUsecase;

  final IExceptiionHandler exceptiionHandler;

  BranchSelectionViewmodel({
    required this.branchUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static BranchSelectionViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BranchSelectionViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var branchLists = <Branch>[].obs;

  // getters
  AppViewmodel get appViewmodel => AppViewmodel.getInstance();

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    getBranchLists();
  }

  void getBranchLists() async {
    try {
      isLoading.value = true;
      exception.value = null;
      branchLists.value = appViewmodel.staffBranchList;
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startSession(BuildContext context, Branch branch, WidgetFactory widgetFactory ) async {
    try {
      exception.value = null;
      isLoading.value = true;
      final result = await branchUsecase.getPosBranchDetails(appViewmodel.selectedBusinessId, appViewmodel.selectedBranchId);
      if (!result.isPosBranchFetchSuccessfull) {
        exception.value = AppException(message: result!.message ?? 'Unable to get branch details', isMainError: false);
        return;
      }
      appViewmodel.selectBranch(result!.branch); 
      HomePage.navigate(context, replace: true);
    } catch (e) {
      // widgetFactory.showFlashMessage(context, message: exception.value?.message ?? 'Error occured, please try again');
    } finally {
      isLoading.value = false;
    }
  }

  int getGridCount(BuildContext context) {
    return Responsive.isSmallScreen(context) ? 2 : 3;
  }

  double getCrossAxisSpacing(BuildContext context) {
    return Responsive.isSmallScreen(context) ? 16 : 40;
  }
}
