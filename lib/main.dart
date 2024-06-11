import 'package:flutter/material.dart';
import 'package:melegna_customer/app/app.dart';
import 'package:melegna_customer/injection.dart';

void main() async {
  setupGetIt();
  await getIt.allReady();
  runApp(MelegnaCustomerApp.instance);
}

