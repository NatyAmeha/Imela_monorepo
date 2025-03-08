import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/inventory/model/inventory.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/ui/inventory/inventory.viewmodel.dart';

class InventoryEditorDialog extends StatefulWidget {
  final InventoryViewModel viewmodel;
  final Product product;
  final Inventory? inventory; // null for create, non-null for edit
  final VoidCallback onCancel;
  final Function(BuildContext) onSave;
  
  const InventoryEditorDialog({
    Key? key,
    required this.viewmodel,
    required this.product,
    this.inventory,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);
  
  @override
  State<InventoryEditorDialog> createState() => _InventoryEditorDialogState();
}

class _InventoryEditorDialogState extends State<InventoryEditorDialog> {
  late TextEditingController qtyController;
  late TextEditingController unitController;
  late bool isAvailable;
  
  @override
  void initState() {
    super.initState();
    // Initialize with existing data if editing
    qtyController = TextEditingController(
      text: widget.inventory?.qty?.toString() ?? '0'
    );
    unitController = TextEditingController(
      text: widget.inventory?.unit ?? 'Unit'
    );
    isAvailable = widget.inventory?.isAvailable ?? true;
    
    // Set values in viewmodel
    widget.viewmodel.editingQty.value = widget.inventory?.qty ?? 0;
    widget.viewmodel.editingUnit.value = widget.inventory?.unit ?? 'Unit';
    widget.viewmodel.editingIsAvailable.value = isAvailable;
  }
  
  @override
  void dispose() {
    qtyController.dispose();
    unitController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.inventory != null;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product name (non-editable)
        Text(
          widget.product.name?.localize(widget.viewmodel.selectedLanguage) ?? 'Unnamed Product',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        
        const SizedBox(height: 24),
        
        // Quantity input
        TextField(
          decoration: const InputDecoration(
            labelText: 'Quantity',
            hintText: 'Enter stock quantity',
          ),
          keyboardType: TextInputType.number,
          controller: qtyController,
          onChanged: (value) {
            widget.viewmodel.editingQty.value = 
                value.isEmpty ? 0 : double.tryParse(value) ?? 0;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Unit input
        TextField(
          decoration: const InputDecoration(
            labelText: 'Unit',
            hintText: 'e.g. Unit, Kg, L',
          ),
          controller: unitController,
          onChanged: (value) {
            widget.viewmodel.editingUnit.value = value;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Available switch
        SwitchListTile(
          title: const Text('Available in Stock'),
          value: isAvailable,
          onChanged: (value) {
            setState(() {
              isAvailable = value;
              widget.viewmodel.editingIsAvailable.value = value;
            });
          },
        ),
        
        const SizedBox(height: 24),
        
        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 16),
            Obx(() => ElevatedButton(
              onPressed: widget.viewmodel.isSaving.value 
                ? null 
                : () => widget.onSave(context),
              child: widget.viewmodel.isSaving.value 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.0)
                  )
                : Text(isEditing ? 'Update Inventory' : 'Add Inventory'),
            )),
          ],
        ),
      ],
    );
  }
} 