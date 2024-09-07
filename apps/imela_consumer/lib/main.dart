import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/firebase_options.dart';
import 'app/app.dart';
import 'injection.dart';
import 'presentation/ui/app_controller.dart';
import 'services/routing_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
 