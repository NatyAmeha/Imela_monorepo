import 'package:flutter/material.dart';
import 'package:imela_core/staff/model/staff_model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/authentication/components/account_popup.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_ui_kit/components/search_component.dart';

class HomePageNavbar extends StatelessWidget {
  final String businessName;
  final String branchName;
  final Staff? staff;
  final TextEditingController controller;
  final String? selectedSectionId;
  final Function() onSync;
  final Function() onChatClicked;
  final Function() onSearchClicked;
  final Function()? onLogout;
  final String selectedLanguage;
  const HomePageNavbar({
    super.key,
    required this.businessName,
    required this.branchName,
    this.staff,
    required this.controller,
    this.selectedSectionId,
    required this.onSync,
    required this.selectedLanguage,
    required this.onSearchClicked,
    required this.onChatClicked,
     this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetFactory.createText(context, branchName, style: Theme.of(context).textTheme.titleLarge, enableResize: true, maxLines: 1),
                  widgetFactory.createText(context, businessName, style: Theme.of(context).textTheme.bodyMedium, color: Theme.of(context).colorScheme.secondary),
                ],
              ).withPaddingSymetric(horizontal: 24, vertical: 12),
            ),
            SearchComponent(controller: controller, widgetFactory: widgetFactory, onTap: onSearchClicked),
            widgetFactory.createIcon(materialIcon: Icons.chat, size: 30, onPressed: onChatClicked),
            widgetFactory.createIcon(
                materialIcon: Icons.sync,
                size: 30,
                onPressed: () {
                  onSync();
                }),
            // const SizedBox(width: 16),
            InkWell(
                onTap: () {
                  final RenderBox renderBox = context.findRenderObject() as RenderBox;
                  final offset = renderBox.localToGlobal(Offset.zero);
                  final Size size = renderBox.size;

                  const double popupWidth = 200.0;

                  // Calculate the position for the popup to appear directly under the widget, starting from the right
                  final position = Offset(offset.dx + size.width - popupWidth, offset.dy);

                  AccountPopupFactory.showAccountPopup(
                    context: context,
                    userName: staff?.name ?? '',
                    phoneNumber: staff?.phoneNumber ?? '',
                    onLogout: () {
                      onLogout?.call();
                    },
                    onLanguageChanged: (String language) {
                      // Handle language change
                    },
                    triggerPosition: position,
                  );
                },
                child: CircleAvatar(child: widgetFactory.createText(context, staff?.name?.substring(0, 1) ?? '', style: Theme.of(context).textTheme.titleMedium))),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
