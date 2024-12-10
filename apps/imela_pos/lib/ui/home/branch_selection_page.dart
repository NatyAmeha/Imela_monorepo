import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/home/branch_selection.viewmodel.dart';
import 'package:imela_pos/ui/home/component/branch_list_item.dart';
import 'package:imela_ui_kit/components/list/gridview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class BranchSelectionPage extends StatefulWidget {
  static const routeName = '/branch-selection';
  const BranchSelectionPage({super.key});

  @override
  State<BranchSelectionPage> createState() => _BranchSelectionPageState();

  static void navigate(BuildContext context, {bool replace = false}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, replace: replace);
  }
}

class _BranchSelectionPageState extends State<BranchSelectionPage> {
  final viewmodel = BranchSelectionViewmodel.getInstance();
  final selectedLanguage = AppViewmodel.getInstance().selectedLanguage;

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel(data: {});
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Branch'),
        actions: [
          IconButton(
              onPressed: () {
                viewmodel.showLogoutAlertDialog(context);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: Obx(
        () => PageContentLoader(
          showContent: viewmodel.branchLists.isNotEmpty,
          isLoading: viewmodel.isLoading.value,
          exception: viewmodel.exception.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          content: SingleChildScrollView(
            child: Column(
              children: [
                widgetFactory.createCard(
                  padding: Responsive.paddingSymetric(context),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widgetFactory.createText(context, 'Available branches', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 24),
                      AppGridView(
                        shrinkWrap: true,
                        items: viewmodel.branchLists.value,
                        itemExtent: 170,
                        crossAxisSpacing: viewmodel.getCrossAxisSpacing(context),
                        crossAxisCount: Responsive.getGridCount(context, itemWidth: 450),
                        itemBuilder: (conext, branch, index) {
                          return BranchListItem(
                            branchInfo: branch,
                            selectedLanguage: selectedLanguage,
                            onStartSession: () {
                              viewmodel.startSession(context, branch, widgetFactory);
                            },
                          );
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
