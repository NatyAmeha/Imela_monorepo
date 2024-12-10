import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SearchComponent extends StatelessWidget {
  final TextEditingController controller;
  final WidgetFactory widgetFactory;
  final Function() onTap;
  const SearchComponent({super.key, required this.controller, required this.widgetFactory, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (context.isPhone) {
      return SizedBox(width: 50, child: widgetFactory.createIcon(materialIcon: Icons.search, onPressed: () => onTap()));
    }

    else {
      return Expanded(
        child: SearchBar(
          leading: const Icon(Icons.search),
          hintText: 'Search products, orders, customer',
          onTap: () {
            onTap();
          },
        ),
      );
    }
  }
}
