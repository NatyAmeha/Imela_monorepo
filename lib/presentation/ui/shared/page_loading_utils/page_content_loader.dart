import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';

class PageContentLoader extends StatelessWidget {
  final Widget content;
  final bool showContent;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget errorWidget;
  final Function? onTryAgain;
  final bool hasError;

  const PageContentLoader({
    super.key,
    required this.content,
    this.showContent = true,
    this.isLoading = false,
    this.loadingWidget,
    this.hasError = false,
    this.errorWidget = const Text("Error occured please try again"),
    this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);

    if (hasError) {
      return Center(child: errorWidget);
    } else {
      return Stack(
        children: [
          if (showContent) content,
          if (isLoading) loadingWidget ?? Center(child: appWidgetFactory.createLoadingIndicator(context)),
        ],
      );
    }
  }
}
