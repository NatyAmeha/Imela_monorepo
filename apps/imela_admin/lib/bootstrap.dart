import 'dart:async';
import 'dart:developer';
import 'package:flutter/widgets.dart';
import 'package:imela_admin/injection.dart';


Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupGetIt();
  // initialize singleton custom go_rotuer_service
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };


  // Add cross-flavor configuration here

  runApp(await builder());
}
