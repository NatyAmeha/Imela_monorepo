import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class BadgeList extends StatelessWidget {
  final List<String>? values;
  final List<Widget>? widgets;
  final List<Color> colors;
  final List<Color>? borderColors;
  final WidgetFactory widgetFactory;
  final double width;
  final double height;
  final TextStyle? textStyle;
  final double maxCeilWidth;
  final WrapAlignment? alignment;
  const BadgeList({
    super.key,
    this.values,
    this.widgets,
    required this.colors,
    this.borderColors,
    required this.widgetFactory,
    this.width = double.infinity,
    this.height = 25,
    this.textStyle,
    this.maxCeilWidth = 150,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: alignment ?? WrapAlignment.start,
          runSpacing: 4,
          children: [
            for (var i = 0; i < (values?.length ?? widgets?.length ?? 0); i++)
              BadgeListTile(
                widgetFactory: widgetFactory,
                value: values?[i],
                widget: widgets?[i],
                color: colors[i],
                borderColor: borderColors?[i],
                isFirst: i == 0,
                isLast: i == (values?.length ?? widgets?.length ?? 0) - 1,
                textStyle: textStyle,
                // width: maxCeilWidth,
                height: height,
                alignment: alignment,
              ),
          ],
        ),
      ],
    );
  }
}

class BadgeListTile extends StatelessWidget {
  final WidgetFactory widgetFactory;
  final String? value;
  final Widget? widget;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final bool isFirst;
  final bool isLast;
  final TextStyle? textStyle;
  final double width;
  final double height;
  final WrapAlignment? alignment;

  const BadgeListTile({
    super.key,
    required this.widgetFactory,
    this.value,
    this.widget,
    this.color,
    this.borderColor,
    this.padding,
    this.isFirst = false,
    this.isLast = false,
    this.textStyle,
    this.width = 80,
    this.height = 20,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: ParallelogramClipper(isFirst: isFirst, alignment: alignment),
      child: Container(
        height: height,
        // width: width,
        
        decoration: BoxDecoration(
          color: color ?? Colors.transparent,
          border: Border.all(color: borderColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(4),
        ),
        alignment: Alignment.center,
        // constraints:  BoxConstraints(maxWidth: width + 25),
        padding: padding ?? (alignment == WrapAlignment.start ? const EdgeInsets.only(left: 6, right: 12, top: 2, bottom: 2) : const EdgeInsets.only(left: 12, right: 6, top: 2, bottom: 2)),
        child: widget ??
            widgetFactory.createText(
              context,
              value ?? '',
              enableResize: true,
              style: (textStyle ?? Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
            ),
      ),
    );
  }
}

class ParallelogramClipper extends CustomClipper<Path> {
  final bool isFirst;
  final WrapAlignment? alignment;

  ParallelogramClipper({required this.isFirst, this.alignment});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (alignment == null) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else if (alignment == WrapAlignment.end) {
      // Right-to-left cutout
      path.moveTo(5, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      // Left-to-right cutout (default)
      if (!isFirst) {
        path.moveTo(5, 0);
      } else {
        path.moveTo(0, 0);
      }
      path.lineTo(size.width, 0);
      path.lineTo(size.width - 5, size.height);
      path.lineTo(0, size.height);
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
