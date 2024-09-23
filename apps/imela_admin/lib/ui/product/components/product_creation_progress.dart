import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_ui_kit/helpers/widget_extesions.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';

class ProgressStep {
  int id;
  final String title;
  final bool isCompleted;
  final Widget? cotnent;

  ProgressStep({
    required this.id,
    required this.title,
     this.cotnent,
    this.isCompleted = false,

  });
}

class ProductCreationProgressComponenet extends StatelessWidget {
  final int selectedStep;
  final List<ProgressStep> steps;
  final bool isSmallScreen;
  final double width;
  final Function(int index, ProgressStep step)? onStepSelected;
  const ProductCreationProgressComponenet({
    super.key,
    this.selectedStep =1,
    required this.steps,
    this.isSmallScreen = false,
    this.width = double.infinity,
    this.onStepSelected,
  });

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);

    return widgetFactory.createCard(
      elevation: 40,
      color: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      width: width,
      padding: Responsive.paddingSymetric(context),
      child: isSmallScreen ? _buildSmallScreen(context) : _buildLargeScreen(context),
    );
  }

  Widget _buildSmallScreen(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: steps.mapIndexed((index, step) {
          return ProgressStepListItem(
              step: step,
              onSelected: () {
                onStepSelected?.call(index, step);
              }).withPaddingSymetric(horizontal: 8);
        }).toList(),
      ),
    );
  }

  Widget _buildLargeScreen(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: steps.mapIndexed((index, step) {
        return ProgressStepListItem(
            step: step,
            onSelected: () {
              onStepSelected?.call(index, step);
            }).withPaddingSymetric(vertical: 8);
      }).toList(),
    );
  }
}

class ProgressStepListItem extends StatelessWidget {
  final ProgressStep step;
  final Function? onSelected;
  const ProgressStepListItem({super.key, required this.step, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return InkWell(
      onTap: () {
        onSelected?.call();
      },
      child: Row(
        children: [
          widgetFactory.createIcon(materialIcon: step.isCompleted ? Icons.check_circle : Icons.radio_button_off, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          widgetFactory.createText(context, step.title, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
