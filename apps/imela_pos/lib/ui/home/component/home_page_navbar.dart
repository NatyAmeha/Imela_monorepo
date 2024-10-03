import 'package:flutter/material.dart';
import 'package:imela_pos/app/app_viewmodel.dart';

class HomePageNavbar extends StatelessWidget {
  final String businessName;
  final String branchName;
  final String userName;
  final TextEditingController controller;
  final Function() onSync;
  const HomePageNavbar({
    super.key,
    required this.businessName,
    required this.branchName,
    required this.userName,
    required this.controller,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            widgetFactory.createIcon(materialIcon: Icons.menu, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widgetFactory.createText(context, branchName, style: Theme.of(context).textTheme.titleMedium),
                widgetFactory.createText(context, businessName, style: Theme.of(context).textTheme.bodyMedium, color: Theme.of(context).colorScheme.secondary),
              ],
            ),
          ],
        ),
        SizedBox(
          width: 300,
          child: widgetFactory.createTextField(controller: controller, hintText: 'Search'),
        ),
        const Spacer(),
        widgetFactory.createIcon(materialIcon: Icons.sync, size: 30, onPressed: () {
          onSync();
        }),
        const SizedBox(width: 16),
        CircleAvatar(child: widgetFactory.createText(context, userName.substring(0, 1), style: Theme.of(context).textTheme.titleMedium)),
        // AppImage(
        //   imageUrl: userImage,
        //   width: 40,
        //   height: 40,
        //   borderRadius: BorderRadius.circular(100),
        // ),
      ],
    );
  }
}
