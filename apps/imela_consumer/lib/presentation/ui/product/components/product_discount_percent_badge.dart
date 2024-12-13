import 'package:flutter/material.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductDiscountPercentBadge extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final String discountPercentage;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  const ProductDiscountPercentBadge({
    super.key,
    required this.widgetFactory,
    required this.discountPercentage,
    this.color,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ArrowClipper(),
      child: Container(
        
        color: color ?? Theme.of(context).colorScheme.primary,
        padding: padding,
        child: Text(
          discountPercentage,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
    // return widgetFactory.createCard(
    //   color: color ?? Theme.of(context).colorScheme.secondaryContainer,
    //   borderRadius: Borderradiu,
    //   padding: padding,
    //   child: widgetFactory.createText(context, discountPercentage, style: Theme.of(context).textTheme.titleMedium),
    // );
  }
}

class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width - 10, 0);
    path.lineTo(size.width, size.height );
    path.lineTo(size.width - 10, size.height);
    path.lineTo(0, size.height);
    // path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
