import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_pos/ui/product_price/product_price_list.viewmodel.dart';

class PriceEditorDialog extends StatefulWidget {
  final ProductPriceListViewModel viewmodel;
  final VoidCallback onCancel;
  final Function(BuildContext) onSave;
  
  const PriceEditorDialog({
    Key? key,
    required this.viewmodel,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);
  
  @override
  State<PriceEditorDialog> createState() => _PriceEditorDialogState();
}

class _PriceEditorDialogState extends State<PriceEditorDialog> {
  late TextEditingController priceController;
  
  @override
  void initState() {
    super.initState();
    // Initialize with current value
    priceController = TextEditingController(
      text: widget.viewmodel.editingPrice.value?.toString() ?? '',
    );
  }
  
  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price input with persisted controller
        TextField(
          decoration: const InputDecoration(
            labelText: 'Price',
            hintText: 'Enter price amount',
          ),
          keyboardType: TextInputType.number,
          controller: priceController,
          onChanged: (value) {
            widget.viewmodel.editingPrice.value = 
                value.isEmpty ? null : double.tryParse(value) ?? 0.0;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Currency dropdown
        Obx(() => DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Currency',
          ),
          value: widget.viewmodel.editingCurrency.value,
          items: ['ETB', 'USD'].map((currency) => 
            DropdownMenuItem(
              value: currency,
              child: Text(currency),
            )
          ).toList(),
          onChanged: (value) {
            if (value != null) {
              widget.viewmodel.editingCurrency.value = value;
            }
          },
        )),
        
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
                : const Text('Save'),
            )),
          ],
        ),
      ],
    );
  }
} 