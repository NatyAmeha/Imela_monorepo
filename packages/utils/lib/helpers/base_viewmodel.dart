import 'package:get/get.dart';

mixin class BaseViewmodel {
  void initViewmodel({Map<String, dynamic>? data}) {}

  static T isViewmodelRegistered<T extends GetxController>(T controller, {String? tag}) {
    return Get.isRegistered<T>() ? Get.find<T>() : Get.put(controller, tag: tag);
  }

  void dispose() {}
}
