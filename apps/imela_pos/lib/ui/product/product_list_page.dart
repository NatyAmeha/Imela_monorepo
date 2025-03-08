import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/product/components/product_table_row.dart';
import 'package:imela_pos/ui/product/viewmodel.product_list.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class ProductListPage extends StatefulWidget {
  static const routeName = '/product-list';
  
  const ProductListPage({Key? key}) : super(key: key);

  @override
  State<ProductListPage> createState() => _ProductListPageState();
  
  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _ProductListPageState extends State<ProductListPage> {
  late ProductListViewModel viewmodel;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = getIt<ProductListViewModel>();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewmodel.refreshProducts,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add product page
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilterBar(),
            const SizedBox(height: 16),
            Expanded(
              child: widgetFactory.createCard(
                child: Obx(() => _buildProductsTable()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        // Search field
        Expanded(
          child: TextField(
            controller: viewmodel.searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
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
        
        // Sort dropdown
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<ProductSortOption>(
                value: viewmodel.sortBy.value,
                items: ProductSortOption.values
                    .map((option) => DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ))
                    .toList(),
                onChanged: (option) {
                  if (option != null) {
                    viewmodel.setSortOption(option);
                  }
                },
                hint: const Text('Sort by'),
                icon: const Icon(Icons.sort),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTable() {
    final filteredProducts = viewmodel.filteredProducts;
    
    if (filteredProducts.isEmpty) {
      return const Center(
        child: Text('No products found'),
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
              DataColumn(label: Text('Image')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Price')),
              DataColumn(label: Text('In Store')),
              DataColumn(label: Text('In POS')),
              DataColumn(label: Text('Actions')),
            ],
            rows: filteredProducts.map((product) {
              return ProductTableRow(
                product: product,
                selectedLanguage: viewmodel.selectedLanguage,
                onViewDetails: _viewProductDetails,
                onEdit: _editProduct,
                onUpdateAvailability: _toggleProductAvailability,
                widgetFactory: widgetFactory,
              ).buildRow(context);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _viewProductDetails(Product product) {
    // Navigate to product details
  }

  void _editProduct(Product product) {
    // Navigate to edit product
  }

  void _toggleProductAvailability(Product product) {
    // Toggle product availability
  }
}
