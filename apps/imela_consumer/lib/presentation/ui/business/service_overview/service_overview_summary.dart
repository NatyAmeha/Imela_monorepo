import 'package:flutter/material.dart';
import 'package:imela/presentation/resources/colors.dart';
import 'package:imela/presentation/ui/business/service_overview/service_overview_listitem.dart';
import 'package:imela_core/business/model/service_overview.model.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ServiceOverviewSummary extends StatelessWidget {
  final List<ServiceOverview> serviceOverviews;
  final WidgetFactory widgetFactory;
  final String selectedLanguage;
  final double width;
  final double height;
  final PageController controller;
  final Function(int index) onTap;
  const ServiceOverviewSummary({
    super.key,
    required this.serviceOverviews,
    required this.widgetFactory,
    required this.selectedLanguage,
    required this.width,
    required this.height,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createPageView(
      context,
      itemCount: serviceOverviews.length,
      itemBuilder: (context, index) => ServiceOverviewListItem(
        serviceOverview: serviceOverviews[index],
        color: ColorManager.colors[index % ColorManager.colors.length],
        widgetFactory: widgetFactory,
        selectedLanguage: selectedLanguage,
        onTap: () {
          onTap(index);
        },
        onCallToActionPressed: () {},
      ),
      controller: controller,
      width: MediaQuery.sizeOf(context).width,
      height: Responsive.getHeight(context, small: 60, medium: 60, large: 65),
      showIndicator: false,
      autoScroll: true,
      autoScrollDuration: const Duration(seconds: 10),
    );
  }
}
