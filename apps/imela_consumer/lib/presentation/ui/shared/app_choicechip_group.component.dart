import 'package:flutter/material.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

enum ChoiceChipSelectionMode {
  single,
  multiple,
}

class AppChoiceChipGroup extends StatefulWidget {
  final List<String> choices;
  List<String> selectedChoices;
  final ChoiceChipSelectionMode selectionMode;
  final Function(List<String>) onSelectionChanged;
  final Color? selectedColor;
  final Color? unselectedColor;
  final TextStyle? selectedTextStyle;
  final TextStyle? unselectedTextStyle;
  final EdgeInsetsGeometry? padding;
  final double? spacing;
  final bool isScrollable;
  final double? height;

  AppChoiceChipGroup({
    required this.choices,
    required this.onSelectionChanged,
    this.selectedChoices = const [],
    this.selectionMode = ChoiceChipSelectionMode.single,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextStyle,
    this.unselectedTextStyle,
    this.padding,
    this.spacing,
    this.isScrollable = false,
    this.height,
  });

  @override
  State<AppChoiceChipGroup> createState() => _AppChoiceChipGroupState();
}

class _AppChoiceChipGroupState extends State<AppChoiceChipGroup> {
  List<String> _selectedChoices = [];
  @override
  initState() {
    super.initState();
    assignInitialSelectedChoices();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isScrollable
        ? AppListView(
            height: widget.height,
            items: widget.choices,
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, item, index) {
              return ChoiceChip(
                label: Text(item, style: widget.selectedChoices.contains(index) ? widget.selectedTextStyle : widget.unselectedTextStyle),
                selected: widget.selectedChoices.contains(item),
                onSelected: (selected) => _onChipSelected(selected, item),
                selectedColor: widget.selectedColor,
                backgroundColor: widget.unselectedColor,
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12.0),
              );
            },
          )
        : Wrap(
            spacing: widget.spacing ?? 8.0,
            children: widget.choices.asMap().entries.map((entry) {
              int index = entry.key;
              String choice = entry.value;

              return ChoiceChip(
                label: Text(choice, style: widget.selectedChoices.contains(index) ? widget.selectedTextStyle : widget.unselectedTextStyle),
                selected: widget.selectedChoices.contains(choice),
                onSelected: (selected) => _onChipSelected(selected, choice),
                selectedColor: widget.selectedColor,
                backgroundColor: widget.unselectedColor,
                padding: widget.padding ?? EdgeInsets.symmetric(horizontal: 12.0),
              );
            }).toList(),
          );
  }

  void assignInitialSelectedChoices() {
    if (widget.selectionMode == ChoiceChipSelectionMode.single) {
      _selectedChoices = widget.selectedChoices.isNotEmpty ? [widget.selectedChoices[0]] : [];
    } else {
      _selectedChoices = widget.selectedChoices;
    }
  }

  void _onChipSelected(bool selected, String value) {
    setState(() {
      if (widget.selectionMode == ChoiceChipSelectionMode.single) {
        _selectedChoices = selected ? [value] : [];
      } else {
        if (selected) {
          _selectedChoices.add(value);
        } else {
          _selectedChoices.remove(value);
        }
      }
      widget.onSelectionChanged(_selectedChoices);
    });
  }
}
