import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_page.dart';
import 'package:imela/presentation/ui/membership/membership_detail/membership_detail_viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class MembershipConfirmationPage extends StatefulWidget {
  final String membershipId;
  static const MEMBERSHIP_ID_KEY = 'membershipId';
  static const routeName = '/membership-confirmation';
  const MembershipConfirmationPage({super.key, required this.membershipId});

  @override
  State<MembershipConfirmationPage> createState() => _MembershipConfirmationPageState();

  static void navigate(BuildContext context, {required String membershipId}) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {MEMBERSHIP_ID_KEY: membershipId});
  }
}

class _MembershipConfirmationPageState extends State<MembershipConfirmationPage> {
  var viewmodel = MembershipDetailsViewModel.getInstance();
  late WidgetFactory widgetFactory;
  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirmation'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            MembershipDetailsPage.navigate(context, widget.membershipId, replace: true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            widgetFactory.createIcon(materialIcon: Icons.check_circle, size: 100, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            widgetFactory.createText(context, 'Membership request submitted', style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            widgetFactory.createCard(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              child: Column(
                children: [
                  Row(
                    children: [
                      widgetFactory.createIcon(materialIcon: Icons.info, size: 24, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: 8),
                      widgetFactory.createText(context, 'Status', style: Theme.of(context).textTheme.labelMedium),
                      const Spacer(),
                      widgetFactory.createText(context, 'Pending', style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                  Divider(height: 32, color: Colors.grey[400]),
                  widgetFactory.createText(context, 'The business will review your membership request and approve it shortly. We will notify you via notification when your membership is approved.', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Spacer(),
            widgetFactory.createButton(
              context: context,
              content: const Text('Complete'),
              onPressed: () {
                viewmodel.goBackToMembershipDetailsPage(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
