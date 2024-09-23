import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_core/branch/branch.usecase.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/branch/model/inventory_location.model.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class BranchCreateViewmodel extends GetxController with BaseViewmodel {
  final BranchUsecase branchUsecase;
  final IExceptiionHandler exceptiionHandler;

  BranchCreateViewmodel({
    required this.branchUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptiionHandler,
  });

  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  var phoneNumberController = '';
  final branchNameInputViewodel = TextInputViewmodel.getInstance(key: 'branchName');
  final branchEmailController = TextEditingController();
  final cityInputViewmodel = TextInputViewmodel.getInstance(key: 'city');
  final addressInputViewmodel = TextInputViewmodel.getInstance(key: 'address');
  final locationController = TextEditingController();

  // state variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var showEmailInput = true.obs;

  var inputOptions = <String, String>{AppLanguage.ENGLISH.name: '', AppLanguage.AMHARIC.name: ''};
  var selectedInputOptionKey = AppLanguage.ENGLISH.name.obs;

  // getters
  AppViewmodel get appcontroller => AppViewmodel.getInstance();

  static BranchCreateViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<BranchCreateViewmodel>());
  }

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    exception.value = null;
  }

  void updatePhoneNumber(String phoneNumber) {
    phoneNumberController = phoneNumber;
  }

  Branch getBranchInfo() {
    return Branch(
      id: Random().nextInt(1000000).toString(),
      name: branchNameInputViewodel.options.toLocalizedFieldArray(),
      phoneNumber: phoneNumberController,
      email: branchEmailController.text,
      address: Address(
        city: cityInputViewmodel.options.toLocalizedFieldArray().first.value ?? '',
        address: addressInputViewmodel.options.toLocalizedFieldArray().first.value ?? '',
      ),
      inventoryLocations: [
        InventoryLocation(
          name: branchNameInputViewodel.options.toLocalizedFieldArray().first.value ?? '',
          address: addressInputViewmodel.options.toLocalizedFieldArray().first.value ?? '',
        ),
      ],
    );
  }
}
