import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_admin/ui/business_subscription/components/selected_platform_service_list_item.dart';
import 'package:imela_admin/ui/business_subscription/platform_service.viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SelectedPlatformServiceList extends StatelessWidget {
  const SelectedPlatformServiceList({super.key});

  PlatformServiceViewmodel get platformServiceViewmodel => PlatformServiceViewmodel.getInstance();

  @override
  Widget build(BuildContext context) {
    WidgetFactory widgetFactory = WidgetFactory(Theme.of(context).platform);
    return Obx(
      () => PageContentLoader(
        showContent: true,
        isLoading: platformServiceViewmodel.isLoading.value,
        exception: platformServiceViewmodel.exception.value,
        hasError: platformServiceViewmodel.exception.value?.isMainError ?? false,
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              widgetFactory.createText(context, 'Selected Services', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              AppListView(
                shrinkWrap: true,
                primary: false,
                items: platformServiceViewmodel.selectedPlatformServices,
                itemBuilder: (context, platformService, index) {
                  return SelectedPlatformServiceListItem(
                    platformService: platformService,
                    onEdit: () {
                      platformServiceViewmodel.addEditServiceDetailPagetoOpenedModal(context, platformService.id!);
                    },
                    onDelete: () {
                      platformServiceViewmodel.removeFromSelectedPlatformServices(platformService.id!);
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              widgetFactory.createButton(
                context: context,
                content: const Text('Continue to Payment'),
                onPressed: () {
                  platformServiceViewmodel.navigateToPaymentPage(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
