import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/app/app.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/app_controller.dart';
import 'package:melegna_customer/services/routing_service.dart';

void main() async {
  setupGetIt();
  await getIt.allReady();
  // initialize singleton custom go_rotuer_service
  GoRouterService();
  CachedNetworkImage.logLevel = CacheManagerLogLevel.none;
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is! NetworkImageLoadException) {
      FlutterError.dumpErrorToConsole(details);
    }
  };
  Get.put(AppController());
  // debugRepaintRainbowEnabled = true;
  runApp(MelegnaCustomerApp.instance);
}
 