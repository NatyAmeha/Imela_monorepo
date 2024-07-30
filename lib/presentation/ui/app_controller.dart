import 'package:get/get.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class AppController extends GetxController{

  static AppController get getInstance {
    return  Get.isRegistered<AppController>() ? Get.find<AppController>() : Get.put(AppController());
  }
  
  AppLanguage selectedLanguage = AppLanguage.ENGLISH;
}