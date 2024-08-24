import 'package:flutter/material.dart';
import 'package:melegna_customer/presentation/resources/colors.dart';
import 'package:melegna_customer/presentation/resources/string_values.dart';
import 'package:melegna_customer/presentation/ui/authentication/auth.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/factory/widget.factory.dart';
import 'package:melegna_customer/presentation/ui/shared/app_image.dart';
import 'package:melegna_customer/presentation/utils/button_style.dart';
import 'package:melegna_customer/presentation/utils/widget_extesions.dart';

class SmallScreenAuthSelection extends StatelessWidget {
  final AuthViewmodel viewmodel;
  final WidgetFactory widgetFactory;
  const SmallScreenAuthSelection({super.key, required this.viewmodel, required this.widgetFactory});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Stack(
        children: [
          widgetFactory.createCard(
            width: double.infinity,
            height: double.infinity,
            child: AppImage(
              imageUrl: StringValues.authOnboardingImageUrl,
              gradient: LinearGradient(colors: [
                Colors.transparent,
                Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.9),
                Theme.of(context).colorScheme.secondaryContainer,
              ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              widgetFactory.createIcon(materialIcon: Icons.store, size: 100, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 40),
              widgetFactory.createText(
                context,
                'Discover and engage with your favorite businesses',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              widgetFactory.createButton(
                context: context,
                content: const Text('Continue with phone'),
                icon: const Icon(Icons.phone),
                onPressed: () {
                  viewmodel.navigateToPhoneLoginPage(context);
                },
              ),
              const SizedBox(height: 32),
              widgetFactory.createButton(
                context: context,
                content: const Text('Continue with Google'),
                style: AppButtonStyle.outlinedButtonStyle(context),
                icon: const Icon(Icons.email),
                onPressed: () {},
              ),
            ],
          ).withPaddingSymetric(horizontal: 16, vertical: 50)
        ],
      ),
    );
  }
}
