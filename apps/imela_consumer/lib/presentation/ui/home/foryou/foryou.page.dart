import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela/presentation/ui/home/foryou/for_you_small_screen.dart';
import 'package:imela/presentation/ui/home/home_page.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/responsive_wrapper.dart';

class ForYouPage extends StatefulWidget {
  const ForYouPage({super.key});

  @override
  State<ForYouPage> createState() => _ForYouPageState();
}

class _ForYouPageState extends State<ForYouPage> {
  HomepageViewmodel get viewmodel => HomepageViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.getForYouData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          isLoading: viewmodel.isForYouDataLoading.value,
          hasError: viewmodel.foryouPageException.value?.isMainError ?? false,
          showContent: viewmodel.forYouData.value != null,
          exception: viewmodel.foryouPageException.value,
          content: const ResponsiveWrapper(
            smallScreen: ForYouSmallScreen(),
          ),
          onTryAgain: () {
            viewmodel.getForYouData(context);
          },
        ),
      ),
    );
  }
}
