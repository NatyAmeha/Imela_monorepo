import 'package:flutter/material.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class StatusLadder extends StatelessWidget {
  final List<Widget> items;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;
  final Axis orientation;
  final double lineHeight;
  final Function(int index)? onTap;
  final WidgetFactory widgetFactory;

  const StatusLadder({
    required this.items,
    required this.currentIndex,
    required this.widgetFactory,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.orientation = Axis.vertical,
    this.lineHeight = 25,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: orientation,
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return widgetFactory.createCard(
          onTap: () {
            onTap?.call(index);
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: index <= currentIndex ? activeColor : inactiveColor,
                      shape: BoxShape.circle,
                    ),
                    child: index <= currentIndex ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                  ),
                  if (index < items.length - 1)
                    Container(
                      width: 2,
                      height: lineHeight,
                      color: index < currentIndex ? activeColor : inactiveColor,
                    ),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(child: items[index]),
            ],
          ),
        );
      },
    );
  }
}
