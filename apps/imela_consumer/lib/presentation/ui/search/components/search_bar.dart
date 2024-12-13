import 'package:flutter/material.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SearchBar extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final double width;
  final double? height;
  final Function onTap;

  const SearchBar({
    Key? key,
    required this.widgetFactory,
    required this.onTap,
    this.width = double.infinity,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: widgetFactory.createCard(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
        width: width,
        height: height,
        child: Row(
          children: [
            widgetFactory.createIcon(materialIcon: Icons.search, color: Colors.grey).withPaddingSymetric(horizontal: 16),
            Expanded(
              child: widgetFactory.createText(
                context,
                'Search products...',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
