import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/branch/branch_details/branch_details.viewmodel.dart';
import 'package:imela/presentation/ui/branch/branch_details/small_screen_branch_detail.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';

class BranchDetailPage extends StatefulWidget {
  static const baseRouteName = '/branch';
  static const routeName = '$baseRouteName/:id';
  static const idQueryParameter = 'id';
  late final BranchDetailViewmodel? branchDetailViewmodel;
  final String branchId;
  final String? branchName;

  BranchDetailPage({super.key, required this.branchId, this.branchName, this.branchDetailViewmodel}) {
    branchDetailViewmodel ??= Get.put(getIt<BranchDetailViewmodel>());
  }

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  BranchDetailViewmodel get viewmodel => widget.branchDetailViewmodel!;

  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'id': widget.branchId});
    });
  }

  @override
  void initState() {
    super.initState();
    print("viewmodel init state");
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final appWidgetFactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isDataLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          showContent: true,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            initializeViewmodel();
          },
          content: ResponsiveWrapper(
            smallScreen: SmallScreenBranchDetailPage(branchDetailViewmodel: viewmodel, widgetFactory: appWidgetFactory),
          ),
        ),
      ),
    );
  }
}
