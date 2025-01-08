import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/membership/components/user_membership_card.dart';
import 'package:imela/presentation/ui/membership/membership_list/membership_list_viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class UserMembershipListPage extends StatefulWidget {
  static const MEMBERSHIP_LIST_TYPE_KEY = 'membership_list_type';
  static const routeName = '/membership_list';
  final String membershipListType;
  const UserMembershipListPage({super.key, required this.membershipListType});

  @override
  State<UserMembershipListPage> createState() => _UserMembershipListPageState();

  static void navigateTo(BuildContext context, MembershipListType membershipListType) {
    final router = AppController.getInstance.router;
    router.navigateTo(context, routeName, extra: {MEMBERSHIP_LIST_TYPE_KEY: membershipListType.name});
  }
}

class _UserMembershipListPageState extends State<UserMembershipListPage> {
  var viewmodel = MembershipListViewmodel.getInstance();
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppController.getInstance.getWidgetFactory(context);
    viewmodel.initViewmodel(
      data: {
        'context': context,
        UserMembershipListPage.MEMBERSHIP_LIST_TYPE_KEY: widget.membershipListType,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership List'),
      ),
      body: Obx(
        () => RefreshIndicator(
          onRefresh: () async {
            viewmodel.getUserMemberships(context);
          },
          child: PageContentLoader(
            isLoading: viewmodel.isLoading.value,
            exception: viewmodel.exception.value,
            hasError: viewmodel.exception.value?.isMainError ?? false,
            onTryAgain: () {
              viewmodel.getUserMemberships(context);
            },
            content: AppListView(
              items: viewmodel.membershipList,
              padding: Responsive.paddingSymetric(context),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, item, index) {
                return UserMembershipCard(
                  membership: item,
                  widgetFactory: widgetFactory,
                  qrCode: viewmodel.getQrCode(item.id!),
                  selectedLanguage: viewmodel.selectedLanguage,
                  backgroundColor: viewmodel.getRandomBackgroundColor(index),
                  onQrCodePressed: () {
                    viewmodel.showMembershipBenefitsModal(context, item);
                  },
                  onViewDetailsPressed: () {
                    viewmodel.navigateToMembershipDetails(context, item);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
