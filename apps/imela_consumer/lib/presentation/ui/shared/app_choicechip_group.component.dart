import 'package:flutter/material.dart';

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
    return Wrap(
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
