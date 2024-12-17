import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela/presentation/ui/shared/app_image.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/helpers/button_style.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'profile_viewmodel.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  ProfilePage({super.key});

  static void navigate(BuildContext context) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName);
  }

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileViewmodel viewmodel = ProfileViewmodel.getInstance();
  final HomepageViewmodel homepageViewmodel = HomepageViewmodel.getInstance();

  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {'context': context});
  }

  @override
  Widget build(BuildContext context) {
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    return Scaffold(
      body: SafeArea(
        child: Obx(
          () => PageContentLoader(
            isLoading: viewmodel.isLoading.value,
            hasError: viewmodel.exception.value?.isMainError ?? false,
            exception: viewmodel.exception.value,
            content: SingleChildScrollView(
              child: Column(
                children: [
                  if (viewmodel.appViewmodel.loggedInUser.value == null)
                    _buildNonLoggedInUserHeader()
                  else ...[
                    _buildProfileHeader(),
                    // _buildQuickActions(),
                  ],
                  const Divider(height: 16),
                  _buildSettingsList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNonLoggedInUserHeader() {
    return widgetFactory.createCard(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.amber, child: Icon(Icons.person_outline)),
              const SizedBox(width: 16),
              widgetFactory.createText(context, 'Not signed in', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              widgetFactory.createButton(
                context: context,
                content: const Text('Sign in'),
                style: AppButtonStyle.filledbuttonStyle(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1)),
                onPressed: () {
                  viewmodel.navigateToLogin(context);
                },
              )
            ],
          ),
          const SizedBox(height: 10),
          widgetFactory.createText(context, 'Sign in to see your profile and rewards', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 32),
        if (viewmodel.appViewmodel.loggedInUser.value?.profileImageUrl != null)
          AppImage(
            imageUrl: viewmodel.appViewmodel.loggedInUser.value?.profileImageUrl,
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(200),
          )
        else
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: widgetFactory.createText(context, viewmodel.fullNameInitial, style: Theme.of(context).textTheme.displayMedium),
          ),
        const SizedBox(height: 16),
        if (viewmodel.fullName != null)
          widgetFactory.createText(context, viewmodel.fullName!, style: Theme.of(context).textTheme.titleLarge)
        else
          widgetFactory.createButton(
            context: context,
            content: const Text('Add Name'),
            style: AppButtonStyle.textButtonStyle(context, color: Theme.of(context).colorScheme.secondary),
            onPressed: () {
              viewmodel.navigateToUpdateProfile(context);
            },
          ),
        widgetFactory.createText(context, viewmodel.phoneNumber, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  // Widget _buildQuickActions() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       _buildActionItem(Icons.document_scanner, 'QR code'),
  //       Obx(
  //         () => _buildActionItem(
  //           Icons.loyalty,
  //           'Rewards: ${viewmodel.loyaltyResponse.value?.customerLoyalties?.length ?? 0}',
  //           onTap: () {
  //             viewmodel.navigateToLoyaltyRewards(context);
  //           },
  //         ),
  //       ),
  //       _buildActionItem(Icons.help_outline, 'Help Center'),
  //     ],
  //   );
  // }

  Widget _buildActionItem(IconData icon, String label, {Function()? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap?.call();
        },
        child: Column(
          children: [
            widgetFactory.createIcon(materialIcon: icon),
            const SizedBox(height: 4),
            widgetFactory.createText(context, label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSettingsItem(Icons.receipt_long, 'Orders', 'View All', onTap: () {
          viewmodel.navigateToOrderList(context);
        }),
        _buildSettingsItem(Icons.card_membership, 'Your Memberships', 'View All', onTap: () {
          viewmodel.navigateToMembershipList(context);
        }),
        _buildSettingsItem(Icons.loyalty, 'Loyalty programs', 'View All', onTap: () {
          viewmodel.navigateToLoyaltyRewards(context);
        }),
        const Divider(height: 24),
        widgetFactory.createText(context, 'Settings', style: Theme.of(context).textTheme.titleMedium).paddingSymmetric(horizontal: 16),
        const SizedBox(height: 10),
        Obx(
          () => _buildSettingsItem(Icons.language, 'Language', viewmodel.language, onTap: () {
            viewmodel.showLanguageSelectorDialog(context);
          }),
        ),
        _buildSettingsItem(Icons.attach_money, 'Currency', viewmodel.currency),
        _buildSettingsItem(Icons.notifications, 'Notification Settings', '', onTap: () {
          viewmodel.appViewmodel.loggedInUser.refresh();
        }),
        if (viewmodel.appViewmodel.loggedInUser.value != null) ...[
          _buildSettingsItem(Icons.person, 'Profile Settings', 'Edit Profile'),
          _buildSettingsItem(Icons.logout, 'Log out', 'Log Out', isLogout: true, onTap: () {
            viewmodel.logout(context);
          }),
        ],
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String label, String value, {bool isLogout = false, Function()? onTap}) {
    return widgetFactory.createListTile(
      leading: widgetFactory.createIcon(materialIcon: icon),
      title: widgetFactory.createText(context, label),
      trailing: widgetFactory.createText(context, value, style: TextStyle(color: isLogout ? Colors.red : Colors.green)),
      onTap: onTap,
    );
  }
}
