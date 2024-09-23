import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/resources/values.dart';
import 'package:imela_admin/shared/component/multi_input_textfield.dart';
import 'package:imela_admin/ui/product/components/main_product_info_form.dart';
import 'package:imela_admin/ui/product/components/product_price_form.dart';
import 'package:imela_admin/ui/product/product_addon/product_addon_form.dart';
import 'package:imela_admin/ui/product/components/product_creation_progress.dart';
import 'package:imela_admin/ui/inventory/components/product_inventory_form.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_admin/ui/product/components/product_payment_form.dart';
import 'package:imela_admin/ui/product/create_product_viewmodel.dart';
import 'package:imela_core/business/model/business.model.dart';
import 'package:imela_ui_kit/components/image/image_uploader.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class CreateProductPage extends StatefulWidget {
  static const routeName = '/product/create';
  static const businessArgKey = 'business';
  final Business selectedBusiness;
  const CreateProductPage({super.key, required this.selectedBusiness});

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();

  static void navigate(BuildContext context, Business business) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, extra: {businessArgKey: business});
  }
}

class _CreateProductPageState extends State<CreateProductPage> {
  final viewmodel = CreateProductViewmodel.getInstance();
  final P = PageController();

  void initViewmodel() {
    Future.delayed(Duration.zero, () {
      viewmodel.initViewmodel(data: {CreateProductPage.businessArgKey: widget.selectedBusiness});
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
      appBar: AppBar(),
      body: Obx(
        () => PageContentLoader(
          content: Row(
            children: [
              if (Responsive.isLargeOrMediumScreen(context)) ...[
                ProductCreationProgressComponenet(
                  steps: viewmodel.productCreatioSteps,
                  selectedStep: viewmodel.selectedStepIndex,
                  width: viewmodel.getProgressCardWidth(context),
                  isSmallScreen: Responsive.isSmallScreen(context),
                  onStepSelected: (index, step) {
                    viewmodel.navigateToStep(index);
                  },
                ),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (Responsive.isSmallScreen(context)) ...[
                        ProductCreationProgressComponenet(
                          steps: viewmodel.productCreatioSteps,
                          selectedStep: viewmodel.selectedStepIndex,
                          width: viewmodel.getProgressCardWidth(context),
                          isSmallScreen: Responsive.isSmallScreen(context),
                          onStepSelected: (index, step) {
                            viewmodel.navigateToStep(index);
                          },
                        ),
                      ],
                      Obx(
                        () => IndexedStack(
                          index: viewmodel.selectedStepIndex,
                          children: [
                            MainProductInfoForm(onContinue: () {
                              viewmodel.saveMainProductInfo();
                            }),
                            ProductOptionsForm(
                              onSkip: () {
                                viewmodel.navigateToInventoryStep();
                              },
                              onContinue: () {
                                viewmodel.navigateToInventoryStep();
                              },
                            ),
                            Obx(() => ProductInventoryForm(
                                  locations: viewmodel.locations,
                                  variants: viewmodel.selectedVariants.toList(),
                                  onCreateNeWBranch: () {
                                    viewmodel.showBranchCreateModal(context);
                                  },
                                  onContinue: (updatedVariants) {
                                    viewmodel.updateSelectedVariants(updatedVariants);
                                  },
                                )),
                            ProductAddonForm(onContinue: (addons) {
                              viewmodel.updateProductAddons(addons);
                            }),
                            Obx(() => ProductPriceForm(
                                  branches: viewmodel.branches.value,
                                  variants: viewmodel.selectedVariants.value,
                                  onContinue: (updatedVaraints) {
                                    viewmodel.createPRoduct(updatedVaraints);
                                  },
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
