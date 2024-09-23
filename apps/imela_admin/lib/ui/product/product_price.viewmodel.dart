import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_admin/shared/component/input_field.viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_admin/ui/product/components/product_payment_form.dart';
import 'package:imela_core/branch/model/branch.model.dart';
import 'package:imela_core/product/product.usecase.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/exception_handler.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProductPriceViewmodel extends GetxController with BaseViewmodel {
  final ProductUsecase productUsecase;
  final IExceptiionHandler exceptionHandler;

  ProductPriceViewmodel({
    required this.productUsecase,
    @Named(AppExceptionHandler.injectName) required this.exceptionHandler,
  });

  AppViewmodel get appviewmodel => AppViewmodel.getInstance();

  static ProductPriceViewmodel getInstance() => BaseViewmodel.isViewmodelRegistered(getIt<ProductPriceViewmodel>());

  // State variables
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var branches = <Branch>[].obs;
  var variants = <ProductVariant>[].obs;

  var priceInputOptions = <String, String>{Currency.ETB.name: '', Currency.USD.name: ''};
  var selectedPriceInputKey = Currency.ETB.name.obs;

  var priceInputs = <String, TextInputViewmodel>{}.obs;

  @override
  void initViewmodel({Map<String, dynamic>? data}) {
    super.initViewmodel(data: data);
    final branchData = data?[ProductPaymentForm.kBranches] as List<Branch>;
    final variantData = data?[ProductPaymentForm.kVariants] as List<ProductVariant>;
    setBranches(branchData);
    setVariants(variantData);
    initPriceInputs();
  }

  void setBranches(List<Branch> branches) {
    this.branches.value = branches;
  }

  void setVariants(List<ProductVariant> variants) {
    this.variants.value = variants;
  }

  String getDefaultPriceInputKey(ProductVariant variant) {
    return '${variant.variantName}-default';
  }

  String getBranchPriceInputKey(ProductVariant variant, Branch branch) {
    return variant.variantName + branch.id!;
  }

  void initPriceInputs() {
    for (var variant in variants) {
      final defaultKey = getDefaultPriceInputKey(variant);
      priceInputs[defaultKey] = TextInputViewmodel.getInstance(key: defaultKey);
      for (var branch in branches) {
        final key = getBranchPriceInputKey(variant, branch);

        priceInputs[key] = TextInputViewmodel.getInstance(key: key);
      }
    }
  }

  TextInputViewmodel getInputViewmodelByKey(String key) {
    return priceInputs[key]!;
  }

  void updateVariantsPriceInputs() {
    for (var variant in variants) {
      final defaultKey = getDefaultPriceInputKey(variant);
      variant.defaultPrice = priceInputs[defaultKey]!.options.toPriceArray();
      for (var branch in branches) {
        final key = getBranchPriceInputKey(variant, branch);
        variant.branchPrices?[branch.id!] = priceInputs[key]!.options.toPriceArray();
      }
    }
  }
}
