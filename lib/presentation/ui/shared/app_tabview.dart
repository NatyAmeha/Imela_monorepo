import 'package:flutter/material.dart';

class AppTabView extends StatelessWidget {
  final List<Widget> tabs;
  final List<Widget> tabViews;
  final TabController? controller;
  final TextStyle? labelStyle;
  final TextStyle? unselectedLabelStyle;
  const AppTabView({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.controller,
    this.labelStyle,
    this.unselectedLabelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            controller: controller,
            tabs: tabs,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).unselectedWidgetColor,
            // labelPadding: labelPadding,
            labelStyle: labelStyle,
            unselectedLabelStyle: unselectedLabelStyle,
          ),
          Expanded(
            child: TabBarView(controller: controller, children: tabViews),
          ),
        ],
      ),
    );
  }
}
