import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';


Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
   WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  // initialize singleton custom go_rotuer_service
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };
  final appViewmodel = getIt<AppViewmodel>();
  await appViewmodel.initViewmodel();

  runApp(await builder());
}
