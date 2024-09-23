import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/business/model/business.section.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductSectionViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptionHandler;

  ProductSectionViewmodel({
    required this.productUsecase,
    required this.businessUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptionHandler,
  });

  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  static ProductSectionViewmodel getInstance() => BaseViewmodel.isViewmodelRegistered(getIt<ProductSectionViewmodel>());

  // State variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();

  var inputOptions = LocalizationUtils.getDefaultInputOptions();
  var selectedInputOptionKey = LocalizationUtils.getDefaultSelectedKey(AppLanguage.ENGLISH.name).obs;
  final sectionNameInputViewodel = TextInputViewmodel.getInstance(key: 'sectionName');
  final sectionDescriptionInputViewodel = TextInputViewmodel.getInstance(key: 'sectionDescription');

  Future<void> createSection(BuildContext context, Function(List<BusinessSection>) onSuccess) async {
    try {
      isLoading.value = true;
      final sectionName = sectionNameInputViewodel.options.toLocalizedFieldArray();
      final sectionDescription = sectionDescriptionInputViewodel.options.toLocalizedFieldArray();

      final section = BusinessSection(name: sectionName, description: sectionDescription, images: []);
      final sectionCreateResult = await businessUsecase.createBusinessProductSection(appviewmodel.selectedBusinessId!, [section]);
      if (sectionCreateResult?.success == true) {
        print('section result ${sectionCreateResult?.sections?.length}');
        onSuccess(sectionCreateResult?.sections ?? []);
      }
    } catch (e) {
      // exceptiionHandler.handleException(e);
    } finally {
      isLoading.value = false;
    }
  }
}
