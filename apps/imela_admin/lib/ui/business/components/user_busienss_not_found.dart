import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class UserBusinessNotFoundComponent extends StatelessWidget {
  final Function onCreateBusinessClicked;
  const UserBusinessNotFoundComponent({super.key, required this.onCreateBusinessClicked});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return widgetFactory.createCard(
      padding: Responsive.paddingSymetric(context, largeHorizontal: 50, smallVertical: 50),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        
        children: [
          widgetFactory.createIcon(materialIcon: Icons.hourglass_empty_outlined, size: 100),
          widgetFactory.createText(context, 'No Business found', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          widgetFactory.createText(context, 'Create your first business and integrate our services to your business', style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          widgetFactory.createButton(
              context: context,
              content: const Text('Create your first business'),
              onPressed: () {
                onCreateBusinessClicked();
              })
        ],
      ),
    );
  }
}
