import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/routing_service.dart';
import 'package:imela_admin/injection.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/base_viewmodel.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:injectable/injectable.dart';

@injectable
class AppViewmodel extends GetxController with BaseViewmodel {
  late GoRouterService appRouter;
  static WidgetFactory? _widgetFactoryInstance;
  @override
  Future<void> initViewmodel({Map<String, dynamic>? data}) async {
    Get.put(this);
    appRouter = getIt<GoRouterService>(instanceName: GoRouterService.injectName);
  }
  

  static AppViewmodel getInstance() {
    return BaseViewmodel.isViewmodelRegistered(getIt<AppViewmodel>());
  }

  static WidgetFactory getWidgetFactory(BuildContext context) {
    return _widgetFactoryInstance ??= WidgetFactory(Theme.of(context).platform); 
  }


  var selectedLanguage = AppLanguage.ENGLISH.name;
  var selectedCurrency = 'USD';


  



}
