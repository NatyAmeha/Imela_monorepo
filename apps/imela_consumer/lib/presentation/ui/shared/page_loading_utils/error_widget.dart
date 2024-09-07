import 'package:flutter/material.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';


class AppErrorWidget extends StatelessWidget {
  final Function? callback;
  final AppException? exception;
  const AppErrorWidget({super.key, this.exception, this.callback});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = WidgetFactory(Theme.of(context).platform);
    return widgetFactory.createCard(
      width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            widgetFactory.createIcon(materialIcon: Icons.error_outline, size: 75),
            const SizedBox(height: 8),
            widgetFactory.createText(context, exception?.message ??  'Error occured, please try again', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 16),
            widgetFactory.createButton(context: context, content: const Text('Try Again'), onPressed: (){
              callback?.call();
            }),
          ], 
        ),
      );
  }
}
