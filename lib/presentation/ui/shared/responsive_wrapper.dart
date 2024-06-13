import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/utils/screen_size_utils.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget smallScreen;
  final Widget? mediumScreen;
  final Widget? largeScreen;

  const ResponsiveWrapper({
    super.key,
    required this.smallScreen,
    this.mediumScreen,
    this.largeScreen,
  });

  @override
  Widget build(BuildContext context) {
    ScreenSize screenSize = Responsive.getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return smallScreen;
      case ScreenSize.medium:
        return mediumScreen ?? smallScreen;
      case ScreenSize.large:
        return largeScreen ?? mediumScreen ?? smallScreen;
    }
  }
}
