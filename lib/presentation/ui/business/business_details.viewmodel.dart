import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/domain/business/business.usecase.dart';
import 'package:melegna_customer/domain/product/product.model.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';
import 'package:melegna_customer/presentation/ui/shared/list.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';

@injectable
class BusinessDetailsViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  final IExceptiionHandler exceptiionHandler;
  final CustomListController<Product> productListController = Get.put(CustomListController<Product>());
  BusinessDetailsViewModel({required this.businessUsecase, @Named(AppExceptionHandler.injectName) required this.exceptiionHandler}) {
  }

  var businessDetails = Rxn<BusinessResponse>();
  var isLoading = false.obs;
  var exception = Rxn<AppException>();
  var errorMessage = "".obs;

  @override
  void initViewmodel() {
    super.initViewmodel();
    getbusinessDetails();
  }

  Future<void> getbusinessDetails() async {
    try {
      isLoading(true);
      print("viewmodel getbusinessDetails");
      final result = await businessUsecase.getBusinessDetails("662505ca50948fabb12180ba");
      businessDetails.value = result;
      productListController.addItems(result?.products);
    }  catch (e) {
      print("viewmodel level exception ${e.toString()}");
      exception(exceptiionHandler.getException(e as Exception));
    } finally {
      isLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
