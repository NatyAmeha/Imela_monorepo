import 'package:flutter/material.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductTableRow {
  final Product product;
  final String selectedLanguage;
  final Function(Product) onViewDetails;
  final Function(Product) onEdit;
  final Function(Product) onUpdateAvailability;
  final WidgetFactory widgetFactory;

  const ProductTableRow({
    required this.product,
    required this.selectedLanguage,
    required this.onViewDetails,
    required this.onEdit,
    required this.onUpdateAvailability,
    required this.widgetFactory,
  });

  DataRow buildRow(BuildContext context) {
    return DataRow(
      cells: [
        // Image cell
        DataCell(_buildProductImage()),
        
        // Name cell
        DataCell(
          widgetFactory.createText(
            context, 
            product.name?.localize(selectedLanguage) ?? 'Unnamed Product',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        
        // Price cell
        DataCell(
          widgetFactory.createText(
            context, 
            product.getPrice()?.toSelectedPriceString('ETB') ?? 'N/A',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        
        // Available in Store
        DataCell(
          _buildAvailabilityIndicator(product.showOnStore ?? false),
        ),
        
        // Available in POS
        DataCell(
          _buildAvailabilityIndicator(product.availableInPOS),
        ),
        
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetFactory.createIcon(
                materialIcon: Icons.visibility,
                onPressed: () => onViewDetails(product),
              ),
              const SizedBox(width: 8),
              widgetFactory.createIcon(
                materialIcon: Icons.edit,
                onPressed: () => onEdit(product),
              ),
              const SizedBox(width: 8),
              widgetFactory.createIcon(
                materialIcon: product.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: product.isActive ? Colors.green : Colors.grey,
                onPressed: () => onUpdateAvailability(product),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    final imageUrl = product.getImageUrl();
    return AppImage(
      imageUrl: imageUrl,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );
  }

  Widget _buildAvailabilityIndicator(bool isAvailable) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isAvailable ? Colors.green : Colors.grey.shade300,
      ),
      child: Icon(
        isAvailable ? Icons.check : Icons.close,
        size: 16,
        color: Colors.white,
      ),
    );
  }
} 