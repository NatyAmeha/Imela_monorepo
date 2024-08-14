import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/error_widget.dart';
import 'package:melegna_customer/presentation/utils/exception/app_exception.dart';

class PageContentLoader extends StatelessWidget {
  final Widget content;
  final bool showContent;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Function? onTryAgain;
  final bool hasError;
  final AppException? exception;

  const PageContentLoader({
    super.key,
    required this.content,
    this.showContent = true,
    this.isLoading = false,
    this.loadingWidget,
    this.hasError = false,
    this.errorWidget,
    this.onTryAgain,
    this.exception
  });

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);

    if (hasError) {
      return errorWidget ?? AppErrorWidget(callback: onTryAgain);
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
