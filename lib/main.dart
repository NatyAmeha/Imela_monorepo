import 'package:flutter/material.dart';
import 'package:melegna_customer/app/app.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/services/routing_service.dart';

void main() async {
  setupGetIt();
  await getIt.allReady();
  // initialize singleton custom go_rotuer_service
  GoRouterService();
  runApp(MelegnaCustomerApp.instance);
}

