import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/business/model/business.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/services/routing_service.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';
   HomePage({super.key});

  final _routingService = GoRouterService();

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(TargetPlatform.iOS);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Home Page'),
        ),
        body: Center(
          child: appWidgetFactory.createButton(context: context, content: Text("Navigate to business details"), onPressed: () {
            _routingService.navigateTo(context, '/business/662505ca50948fabb12180ba', extra: {"name" : "Custom business name"});
          }),
        ));
  }
}
