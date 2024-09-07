import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/branch/component/branch_banner_card.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'branch_details.viewmodel.dart';


class SmallScreenBranchDetailPage extends StatelessWidget {
  final BranchDetailViewmodel branchDetailViewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenBranchDetailPage({super.key, required this.branchDetailViewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 225,
          collapsedHeight: 60,
          pinned: true,
          title: Text("Branch Name"),
          floating: false,
          automaticallyImplyLeading: false,
          leading: widgetFactory.createIcon(
            materialIcon: Icons.arrow_back_ios,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: const [],
          toolbarHeight: 60,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            expandedTitleScale: 1.0,
            background: BranchBannerCard(branch: branchDetailViewmodel.branchInfo, widgetFactory: widgetFactory),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
