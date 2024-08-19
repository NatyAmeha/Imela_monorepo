import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/branch/model/branch.model.dart';
import 'package:melegna_customer/domain/shared/gallery.model.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_choicechip_group.component.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';

class BranchBannerCard extends StatelessWidget {
  final Branch branch;
  final double height;
  final double width;
  final WidgetFactory widgetFactory;
  const BranchBannerCard({
    super.key,
    required this.branch,
    this.width = double.infinity,
    this.height = 300,
    required this.widgetFactory,
  });

  double get imageHeight => width * 0.5;

  @override
  Widget build(BuildContext context) {
    return widgetFactory.createCard(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                AppImage(imageUrl: branch.business?.gallery?.getImage(), width: width, height: imageHeight),
              ],
            ),
          ),
          Positioned(
            child: Align(
              alignment: Alignment.center,
              child: widgetFactory.createCard(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorManager.primaryBackground, width: 1),
                padding: const EdgeInsets.all(16),
                width: width,
                child: Column(
                  children: [
                    widgetFactory.createText(context, branch.name.localize(), style: Theme.of(context).textTheme.headlineLarge),
                    AppChoiceChipGroup(
                      choices: ["Holiday price", ""],
                      onSelectionChanged: (value) {},
                    ),
                    widgetFactory.createText(context, branch.address?.city ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    Row(
                      children: [
                        Column(
                          children: [
                            widgetFactory.createText(context, "12 am - 12 PM", style: Theme.of(context).textTheme.labelSmall),
                            widgetFactory.createText(context, "Open", style: Theme.of(context).textTheme.bodyMedium, color: Colors.green),
                          ],
                        ),
                        const Spacer(),
                        widgetFactory.createIcon(materialIcon: Icons.mail_rounded),
                        widgetFactory.createIcon(materialIcon: Icons.call)
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
