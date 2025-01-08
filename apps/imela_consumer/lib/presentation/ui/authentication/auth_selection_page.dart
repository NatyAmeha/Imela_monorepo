import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/app_controller.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela/presentation/ui/authentication/small_screen_auth_selection.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/responsive_wrapper.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class AuthSelectionPage extends StatefulWidget {
  static const routeName = '/auth_selection';
  static const REDIRECT_URL_KEY = 'REDIRECT_URL';
  static const REDIRECT_EXTRA_KEY = 'REDIRECT_EXTRA';
  late AuthViewmodel? authViewmodel;
  final String? redirectionRoute;
  final Map<String, dynamic>? redirectExtra;

  AuthSelectionPage({super.key, this.authViewmodel, this.redirectionRoute = '/', this.redirectExtra}) {
    authViewmodel ??= Get.put(getIt<AuthViewmodel>());
  }

  @override
  State<AuthSelectionPage> createState() => _AuthSelectionPageState();

  static void navigate(BuildContext context, {String? redirectUrl, Map<String, dynamic>? redirectExtra}) {
    AppController.getInstance.router.navigateTo(context, routeName, extra: {REDIRECT_URL_KEY: redirectUrl, REDIRECT_EXTRA_KEY: redirectExtra});
  }
}

class _AuthSelectionPageState extends State<AuthSelectionPage> {
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {AuthSelectionPage.REDIRECT_URL_KEY: widget.redirectionRoute, AuthSelectionPage.REDIRECT_EXTRA_KEY: widget.redirectExtra});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  AuthViewmodel get viewmodel => widget.authViewmodel!;

  @override
  Widget build(BuildContext context) {
    final appWidgetfactory = WidgetFactory(Theme.of(context).platform);
    return Scaffold(
      body: PageContentLoader(
        isLoading: viewmodel.isLoading.value,
        hasError: viewmodel.exception.value?.isMainError ?? false,
        showContent: true,
        exception: viewmodel.exception.value,
        onTryAgain: () {
          initializeViewmodel();
        },
        content: ResponsiveWrapper(
          smallScreen: SmallScreenAuthSelection(viewmodel: viewmodel, widgetFactory: appWidgetfactory),
        ),
      ),
    );
  }
}
