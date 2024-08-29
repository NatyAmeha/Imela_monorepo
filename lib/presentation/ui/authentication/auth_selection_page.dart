import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela/injection.dart';
import 'package:imela/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:imela/presentation/ui/authentication/small_screen_auth_selection.dart';
import 'package:imela/presentation/ui/factory/widget.factory.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:imela/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';
import 'package:imela/services/routing_service.dart';

class AuthSelectionPage extends StatefulWidget {
  static const routeName = '/auth_selection';
  static const REDIRECT_URL_KEY = 'redirect_url';
  late AuthViewmodel? authViewmodel;
  final String? redirectionRoute;

  AuthSelectionPage({super.key, this.authViewmodel, this.redirectionRoute = '/'}) {
    authViewmodel ??= Get.put(getIt<AuthViewmodel>());
  }

  @override
  State<AuthSelectionPage> createState() => _AuthSelectionPageState();

  static void navigate(BuildContext context, IRoutingService router, {String? redirectT}) {
    router.navigateTo(context, routeName);
  }
}

class _AuthSelectionPageState extends State<AuthSelectionPage> {
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel();
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
        isDataLoading: viewmodel.isLoading.value,
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
