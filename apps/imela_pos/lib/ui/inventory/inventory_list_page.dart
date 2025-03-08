import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/inventory/model/inventory.model.dart';
import 'package:imela_core/inventory/model/inventory_location.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/inventory/inventory.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_ui_kit/components/modal/app_modal_sheet.dart';
import 'package:imela_utils/helpers/screen_size_utils.dart';
import 'package:imela_pos/ui/inventory/components/inventory_editor_dialog.dart';

class InventoryListPage extends StatefulWidget {
  static const routeName = '/inventory-list';
  
  const InventoryListPage({Key? key}) : super(key: key);

  @override
  State<InventoryListPage> createState() => _InventoryListPageState();
  
  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _InventoryListPageState extends State<InventoryListPage> {
  late InventoryViewModel viewmodel;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = getIt<InventoryViewModel>();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewmodel.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add inventory page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationSelector(),
            const SizedBox(height: 16),
            _buildSearchAndFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: widgetFactory.createCard(
                child: Obx(() => PageContentLoader(
                  isLoading: viewmodel.isLoading.value,
                  exception: viewmodel.exception.value,
                  hasError: viewmodel.exception.value?.isMainError ?? false,
                  onTryAgain: viewmodel.refresh,
                  content: _buildContentTabs(),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Obx(() {
      if (viewmodel.isLocationsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (viewmodel.locations.isEmpty) {
        return widgetFactory.createCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No locations found', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: viewmodel.getInventoryLocations,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
        );
      }
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Location', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<InventoryLocation>(
              value: viewmodel.selectedLocation.value,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: viewmodel.locations.map((location) {
                return DropdownMenuItem<InventoryLocation>(
                  value: location,
                  child: Text(location.name ?? ''),
                );
              }).toList(),
              onChanged: (location) {
                if (location != null) {
                  viewmodel.setSelectedLocation(location);
                }
              },
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        // Search field
        Expanded(
          child: TextField(
            controller: viewmodel.searchController,
            decoration: InputDecoration(
              hintText: 'Search inventory...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(() => viewmodel.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: viewmodel.clearSearch,
                    )
                  : const SizedBox.shrink()),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: viewmodel.updateSearchQuery,
          ),
        ),
        const SizedBox(width: 16),
        
        // Filter buttons
        Obx(() => IconButton(
          icon: const Icon(Icons.sort_by_alpha),
          color: viewmodel.sortByName.value ? Theme.of(context).colorScheme.primary : null,
          onPressed: viewmodel.toggleSortByName,
          tooltip: 'Sort by name',
        )),
        
        Obx(() => IconButton(
          icon: const Icon(Icons.sort),
          color: !viewmodel.sortByName.value ? Theme.of(context).colorScheme.primary : null,
          onPressed: viewmodel.toggleSortByQuantity,
          tooltip: 'Sort by quantity',
        )),
        
        Obx(() => IconButton(
          icon: Icon(viewmodel.sortAscending.value 
              ? Icons.arrow_upward 
              : Icons.arrow_downward),
          onPressed: viewmodel.toggleSortDirection,
          tooltip: viewmodel.sortAscending.value ? 'Ascending' : 'Descending',
        )),
        
        const SizedBox(width: 8),
        
        Obx(() => FilterChip(
          label: const Text('Show Out of Stock'),
          selected: viewmodel.showOutOfStock.value,
          onSelected: (_) => viewmodel.toggleShowOutOfStock(),
        )),
      ],
    );
  }

  Widget _buildContentTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: const [
              Tab(text: 'Inventory Items'),
              Tab(text: 'Products Without Inventory'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildInventoryTable(),
                _buildProductsWithoutInventoryTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTable() {
    final filteredInventory = viewmodel.filteredInventory;
    if (filteredInventory.isEmpty) {
      return const Center(
        child: Text('No inventory items found'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 12,
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor.withOpacity(0.1)),
            columns: const [
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Product Name')), 
              DataColumn(label: Text('Quantity')),
              DataColumn(label: Text('Unit')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Actions')),
            ],
            rows: filteredInventory.map((item) => _buildInventoryRow(item)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildInventoryRow(Inventory item) {
    // Find the associated product
    final product = AppViewmodel.getInstance().allProducts.firstWhereOrNull(
      (p) => p.id == item.productId
    );
    
    return DataRow(
      cells: [
        // SKU
        DataCell(Text(item.sku ?? '-')),
        
        // Product Name - use the product information if found
        DataCell(Text(product?.name?.localize(viewmodel.selectedLanguage) ?? 'Unknown Product')),
        
        // Quantity
        DataCell(Text('${item.qty ?? 0}')),
        
        // Unit
        DataCell(Text(item.unit ?? '-')),
        
        // Status
        DataCell(_buildStockStatus(item)),
        
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetFactory.createIcon(
                materialIcon: Icons.edit,
                onPressed: () {
                  if (product != null) {
                    viewmodel.startEditingInventory(context, product, item);
                  }
                },
              ),
              const SizedBox(width: 8),
              widgetFactory.createIcon(
                materialIcon: Icons.history,
                onPressed: () {
                  // View history
                },
              ),
              const SizedBox(width: 8),
              widgetFactory.createIcon(
                materialIcon: Icons.add_circle_outline,
                onPressed: () {
                  if (product != null) {
                    viewmodel.startEditingInventory(context, product, item);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockStatus(Inventory item) {
    final qty = item.qty ?? 0;
    final isOutOfStock = qty <= 0;
    final isLowStock = qty > 0 && qty < 10; // Example threshold
    
    Color statusColor;
    String statusText;
    
    if (isOutOfStock) {
      statusColor = Colors.red;
      statusText = 'Out of Stock';
    } else if (isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
    } else {
      statusColor = Colors.green;
      statusText = 'In Stock';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: statusColor),
      ),
    );
  }

  Widget _buildProductsWithoutInventoryTable() {
    final productsWithoutInventory = viewmodel.productsWithoutInventory;
    
    if (productsWithoutInventory.isEmpty) {
      return const Center(
        child: Text('All products have inventory information'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
          child: DataTable(
            columnSpacing: 16,
            horizontalMargin: 12,
            headingRowColor: MaterialStateColor.resolveWith(
                (states) => Theme.of(context).primaryColor.withOpacity(0.1)),
            columns: const [
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Actions')),
            ],
            rows: productsWithoutInventory.map((product) => _buildProductRow(product)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildProductRow(Product product) {
    return DataRow(
      cells: [
        // Product Name
        DataCell(Text(product.name?.localize(viewmodel.selectedLanguage) ?? 'Unnamed Product')),
        
        // SKU
        DataCell(Text(product.sku ?? '-')),
        
        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetFactory.createIcon(
                materialIcon: Icons.add_circle,
                color: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  viewmodel.startEditingInventory(context, product, null);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 