import 'package:flutter/material.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/error_widget.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_utils/exception/app_exception.dart';


class PageContentLoader extends StatelessWidget {
  final Widget content;
  final bool showContent;
  final bool isDataLoading;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Function? onTryAgain;
  final bool hasError;
  final AppException? exception;

  const PageContentLoader({super.key, required this.content, this.showContent = true, this.isDataLoading = false, this.isLoading = false, this.loadingWidget, this.hasError = false, this.errorWidget, this.onTryAgain, this.exception});

  @override
  Widget build(BuildContext context) {
    var appWidgetFactory = WidgetFactory(Theme.of(context).platform);

    if (hasError) {
      return errorWidget ?? AppErrorWidget(callback: onTryAgain);
    } else {
      return Stack(
        children: [
          if (showContent) content,
          if (isDataLoading) showContent ? Center(child: appWidgetFactory.createLoadingIndicator(context)) : loadingWidget ?? Center(child: appWidgetFactory.createLoadingIndicator(context)),
          
        ],
      );
    }
  }
}
