import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/ui/home/splash/splash.viewmodel.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final viewmodel = SplashViewmodel.getInstance();

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {'context': context});
    });
  }

  @override
  void initState() {
    super.initState();
    initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widgetFactory.createText(context, 'Splash Page', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              if (viewmodel.isLoading.value) widgetFactory.createLoadingIndicator(context),
            ],
          ),
        ),
      ),
    );
  }
}
