import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/profile/update_profile/update_profile_page.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_core/user/dto/update_user_input.dart';
import 'package:imela_core/user/model/user.response.dart';
import 'package:imela_core/user/user.usecase.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateProfileViewmodel extends GetxController with BaseViewmodel {
  static const PROFILE_UPDATED_KEY = 'profile_updated';
  final IExceptiionHandler exceptiionHandler;
  final UserUsecase userUsecase;

  UpdateProfileViewmodel({
    required this.userUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  static UpdateProfileViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<UpdateProfileViewmodel>());
  }

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var user = Rxn<UserResponse>();

  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var emailController = TextEditingController();
  late String redirectUrl;
  late Map<String, dynamic> redirectExtra;

  // getters
  var appViewmodel = AppController.getInstance;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    redirectUrl = data?[UpdateProfilePage.REDIRECT_URL_KEY];
    redirectExtra = data?[UpdateProfilePage.REDIRECT_EXTRA_KEY];
  }

  Future<void> updateProfile(BuildContext context) async {
    try {
      isLoading.value = true;
      if (firstNameController.text.isEmpty) {
        appViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'First name is required');
        return;
      }
      final input = UpdateUserInput(
        firstName: firstNameController.text,
        lastName: lastNameController.text.isEmpty ? null : lastNameController.text,
        email: emailController.text.isEmpty ? null : emailController.text,
      );
      final result = await userUsecase.updateProfile(input);
      if (!result.isSuccessfull) {
        appViewmodel.getWidgetFactory(context).showFlashMessage(context, message: 'Unable to update profile', actionText: 'Try again', onActinClicked: () => updateProfile(context));
        return;
      }
      appViewmodel.setLoggedInUser(result.user);
      UpdateProfilePage.handleRedirect(context, redirectUrl, redirectExtra);
    } catch (e) {
      exception.value = exceptiionHandler.getException(e as Exception);
    } finally {
      isLoading.value = false;
    }
  }

  String? validateFirstName() {
    return firstNameController.text.isNotEmpty ? null : 'First name is required';
  }
}
