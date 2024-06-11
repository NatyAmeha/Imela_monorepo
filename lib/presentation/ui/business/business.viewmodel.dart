import 'package:get/get.dart';
import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/business_response.dart';
import 'package:melegna_customer/domain/business/business.usecase.dart';
import 'package:melegna_customer/presentation/ui/shared/base_viewmodel.dart';

@injectable
class BusinessDetailsViewModel extends GetxController with BaseViewmodel {
  final BusinessUsecase businessUsecase;
  BusinessDetailsViewModel({required this.businessUsecase}) {
    init();
  }
  var businessDetails = Rxn<BusinessResponse>();
  var dropdownValue = Rxn<String>();

  @override
  void init() {
    super.init();
    getbusinessDetails();
  }

  Future<void> getbusinessDetails() async {
    final result = await businessUsecase.getBusinessDetails("662505ca50948fabb12180ba");
    businessDetails.value = result;
  }

  @override
  void dispose() {
    getbusinessDetails();
    super.dispose();
  }
}
