import 'package:get/get.dart';
import 'package:imela_core/business/business.usecase.dart';
import 'package:imela_core/user/auth.usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardViewmodel extends GetxController{
  final AuthUsecase authUsecase;
  final BusinessUsecase businessUsecase;

  DashboardViewmodel({required this.authUsecase, required this.businessUsecase});

  Future<String> getbusinessDetails(String businessID ) async {
     try {
       var businessResponse = await businessUsecase.getBusinessDetails(businessID);
      var businessName = businessResponse?.business?.name?.map((e) => e.value).join(',');
      return businessName ?? '';
     } catch (e) {
       print('Error: $e');
        return 'Error: $e';
     }
  }

}