import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/pricelist.model.dart';
import 'package:imela_core/product/model/product_price.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/product_price/product_price_list.viewmodel.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';
import 'package:imela_pos/ui/product_price/components/price_editor_dialog.dart';

class ProductPriceListPage extends StatefulWidget {
  static const routeName = '/product-price-list';

  const ProductPriceListPage({Key? key}) : super(key: key);

  @override
  State<ProductPriceListPage> createState() => _ProductPriceListPageState();

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }
}

class _ProductPriceListPageState extends State<ProductPriceListPage> {
  late ProductPriceListViewModel viewmodel;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = getIt<ProductPriceListViewModel>();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Prices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewmodel.refresh,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildPriceListActions(),
            Expanded(
              child: widgetFactory.createCard(
                child: Obx(() => PageContentLoader(
                      isLoading: viewmodel.isLoading.value,
                      exception: viewmodel.exception.value,
                      hasError: viewmodel.exception.value?.isMainError ?? false,
                      onTryAgain: viewmodel.refresh,
                      content: _buildPriceTable(),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
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
    );
  }

  Widget _buildPriceListActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Price Lists',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          widgetFactory.createButton(
            context: context,
            content: const Text('Add Price List'),
            onPressed: () => viewmodel.showPriceListEditor(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTable() {
    return Obx(() {
      final productItems = viewmodel.productsWithPrices;

      if (productItems.isEmpty) {
        return const Center(
          child: Text('No products found'),
        );
      }

      // Generate columns dynamically based on price lists
      return _buildDataTable(productItems);
    });
  }

  Widget _buildDataTable(List<ProductWithPrices> productItems) {
    return Obx(() {
      // Get all unique price lists

      // Build table columns
      final columns = <DataColumn>[
        const DataColumn(label: Text('Product')),
        const DataColumn(label: Text('Default Price')),
        ...viewmodel.priceLists.value.map(
          (priceList) => DataColumn(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(priceList.name?.localize(viewmodel.selectedLanguage) ?? ''),
                IconButton(
                  icon: const Icon(Icons.edit, size: 16),
                  onPressed: () => viewmodel.showPriceListEditor(context, priceList: priceList),
                  tooltip: 'Edit Price List',
                ),
              ],
            ),
          ),
        )
      ];

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 64),
            child: DataTable(
              columnSpacing: 16,
              horizontalMargin: 12,
              headingRowColor: MaterialStateColor.resolveWith((states) => Theme.of(context).primaryColor.withOpacity(0.1)),
              columns: columns,
              rows: productItems.map((item) => _buildProductRow(item, viewmodel.priceLists.value)).toList(),
            ),
          ),
        ),
      );
    });
  }

  DataRow _buildProductRow(ProductWithPrices item, List<PriceList> priceLists) {
    final product = item.product;

    // Create cells
    final cells = <DataCell>[
      // Product name cell
      DataCell(Text(product.name?.localize(viewmodel.selectedLanguage) ?? 'Unnamed Product')),

      // Default price cell
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(viewmodel.formatPrice(item.defaultPrice)),
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              onPressed: () {
                // Start editing default price
                viewmodel.startEditingPrice(context, product.id!, 'default', item.defaultPrice);
              },
            ),
          ],
        ),
      ),

      // Price list cells
      ...priceLists.map((priceList) {
        final price = item.getPriceForList(priceList.id!);
        final hasPrice = price != null;

        return DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(hasPrice ? viewmodel.formatPrice(price) : 'N/A'),
              IconButton(
                icon: Icon(hasPrice ? Icons.edit : Icons.add, size: 16),
                tooltip: hasPrice ? 'Edit Price' : 'Add Price',
                onPressed: () {
                  // Edit existing or create new price
                  viewmodel.startEditingPrice(context, product.id!, priceList.id!, price);
                },
              ),
            ],
          ),
        );
      }),
    ];

    return DataRow(cells: cells);
  }
}
