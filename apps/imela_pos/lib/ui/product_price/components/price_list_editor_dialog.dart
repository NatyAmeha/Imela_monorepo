import 'package:flutter/material.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class PriceListEditorDialog extends StatefulWidget {
  final PriceList? priceList; // null for create, non-null for edit
  final String selectedLanguage;
  final List<String> availableBranchIds;
  final Function(String, List<LocalizedField>, List<LocalizedField>, List<String>) onSave;
  
  const PriceListEditorDialog({
    Key? key,
    this.priceList,
    required this.selectedLanguage,
    required this.availableBranchIds,
    required this.onSave,
  }) : super(key: key);
  
  @override
  State<PriceListEditorDialog> createState() => _PriceListEditorDialogState();
}

class _PriceListEditorDialogState extends State<PriceListEditorDialog> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late List<String> selectedBranchIds;
  
  @override
  void initState() {
    super.initState();
    // Initialize with existing data if editing
    nameController = TextEditingController(
      text: widget.priceList?.name?.localize(widget.selectedLanguage) ?? ''
    );
    descriptionController = TextEditingController(
      text: widget.priceList?.description?.localize(widget.selectedLanguage) ?? ''
    );
    selectedBranchIds = widget.priceList?.branchIds?.toList() ?? [];
  }
  
  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    final isEditing = widget.priceList != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Edit Price List' : 'Create Price List'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name field
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Price List Name',
                hintText: 'Enter a name for this price list',
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description field
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter a description (optional)',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // Branch selection
            const Text('Available in Branches:'),
            const SizedBox(height: 8),
            
            // Branch checkboxes
            ...widget.availableBranchIds.map((branchId) {
              final isSelected = selectedBranchIds.contains(branchId);
              return CheckboxListTile(
                title: Text('Branch $branchId'),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedBranchIds.add(branchId);
                    } else {
                      selectedBranchIds.remove(branchId);
                    }
                  });
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Create LocalizedField objects
            final name = [LocalizedField(key: 'ENGLISH', value: nameController.text)];
            final description = [LocalizedField(key: 'ENGLISH', value: descriptionController.text)];
            
            // Call the save callback with the gathered data
            widget.onSave(
              widget.priceList?.id ?? '',
              name,
              description,
              selectedBranchIds,
            );
            
            Navigator.of(context).pop();
          },
          child: Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }
} 