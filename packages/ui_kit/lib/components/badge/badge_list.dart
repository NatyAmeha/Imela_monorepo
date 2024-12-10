import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BadgeList extends StatelessWidget {
  final List<String>? values;
  final List<Widget>? widgets;
  final List<Color> colors;
  final WidgetFactory widgetFactory;
  final double width;
  final double height;
  final TextStyle? textStyle;
  const BadgeList({
    super.key,
    this.values,
    this.widgets,
    required this.colors,
    required this.widgetFactory,
    this.width = 200,
    this.height = 25,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppListView(
        height: height,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        items: values ?? widgets,
        itemBuilder: (context, item, index) {
          return BadgeListTile(
            widgetFactory: widgetFactory,
            value: item is String ? item : null,
            widget: item is Widget ? item : null,
            color: colors[index],
            isFirst: index == 0,
            isLast: index == (values?.length ?? widgets?.length ?? 0) - 1,
            textStyle: textStyle,
          );
        },
      ),
    );
  }
}

class BadgeListTile extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final String? value;
  final Widget? widget;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final bool isFirst;
  final bool isLast;
  final TextStyle? textStyle;

  const BadgeListTile({
    super.key,
    required this.widgetFactory,
    this.value,
    this.widget,
    this.color,
    this.padding = const EdgeInsets.only(left: 6, right: 16, top: 2, bottom: 2),
    this.isFirst = false,
    this.isLast = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ParallelogramClipper(
        isFirst: isFirst,
      ),
      child: Container(
        height: 30,
        color: color ?? Theme.of(context).colorScheme.primary,
        alignment: Alignment.center,
        // margin: EdgeInsets.only(left: isFirst ? 0 : 10) ,
        padding: padding,
        child: widget ??
            widgetFactory.createText(
              context,
              value ?? '',
              enableResize: true,
              style: (textStyle ?? Theme.of(context).textTheme.bodySmall)?.copyWith(color: Colors.white),
            ),
      ),
    );
  }
}

class ParallelogramClipper extends CustomClipper<Path> {
  final bool isFirst;

  ParallelogramClipper({required this.isFirst});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Start at the top-left corner
    if (!isFirst) {
      path.moveTo(5, 0); // Start with a slant for non-first elements
    } else {
      path.moveTo(0, 0); // No slant for the first element
    }

    // Top-right corner
    path.lineTo(size.width, 0);

    // Bottom-right corner
    path.lineTo(size.width - 5, size.height); // Slant the bottom-right corner

    // Bottom-left corner
    path.lineTo(0, size.height);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
