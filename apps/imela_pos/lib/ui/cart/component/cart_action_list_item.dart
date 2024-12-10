import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CartActionInfo {
  final String actionName;
  final String? selectedValue;
  final VoidCallback onTap;
  final Widget? clearIcon;
  final Function? onClear;
  final IconData icon;

  CartActionInfo({
    required this.actionName,
    this.selectedValue,
    required this.onTap,
    required this.icon,
    this.clearIcon,
    this.onClear,
  });
}

class CartActionList extends StatelessWidget {
  final List<CartActionInfo> actions;

  CartActionList({Key? key, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    return AppGridView(
      itemExtent: 50,
      crossAxisCount: 2,
      items: actions,
      shrinkWrap: true,
      
      itemBuilder: (context, action, index) {
        return _buildActionItem(context, action, widgetFactory);
      },
    );
  }

  Widget _buildActionItem(BuildContext context, CartActionInfo action, WidgetFactory widgetFactory) {
    return InkWell(
      onTap: action.onTap,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    widgetFactory.createIcon(materialIcon: action.icon, size: 24),
                    Expanded(child: widgetFactory.createText(context, action.actionName)),
                  ],
                ),
                if (action.selectedValue != null) widgetFactory.createText(context, action.selectedValue!, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (action.clearIcon != null)
            Positioned(
              right: 0,
              top: 0,
              child: InkWell(
                child: action.clearIcon,
                onTap: () {
                  action.onClear?.call();
                },
              ),
            ),
        ],
      ),
    );
  }
}
