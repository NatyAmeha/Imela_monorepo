import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/currency_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/utils/filter_models.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_pos/injection.dart';
import 'package:imela_pos/ui/section/section.viewmodel.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';
import 'package:imela_ui_kit/widget_factory/widget.factory.dart';

class SectionPage extends StatefulWidget {
  static const routeName = '/section';

  final String businessId;
  final String sectionId;
  final String? sectionName;
  final bool showAppBar;

  const SectionPage({
    Key? key,
    required this.businessId,
    required this.sectionId,
    this.sectionName,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  State<SectionPage> createState() => _SectionPageState();

  static void navigate(BuildContext context, {required String businessId, required String sectionId, String? sectionName}) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName, extra: {
      'businessId': businessId,
      'sectionId': sectionId,
      'sectionName': sectionName,
    });
  }
}

class _SectionPageState extends State<SectionPage> {
  late SectionViewModel viewmodel;
  late WidgetFactory widgetFactory;

  @override
  void initState() {
    super.initState();
    widgetFactory = AppViewmodel.getWidgetFactory(context);
    viewmodel = getIt<SectionViewModel>();
    viewmodel.initViewmodel(data: {
      'businessId': widget.businessId,
      'sectionId': widget.sectionId,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(widget.sectionName ?? 'Section Details'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: viewmodel.refresh,
                ),
              ],
            )
          : null,
      body: Stack(
        children: [
          // Main content
          Obx(
            () => PageContentLoader(
              isLoading: viewmodel.isLoading.value,
              exception: viewmodel.exception.value,
              hasError: viewmodel.exception.value?.isMainError ?? false,
              onTryAgain: () => viewmodel.getBusinessSectionDetails(
                widget.businessId,
                widget.sectionId,
              ),
              content: _buildContent(),
            ),
          ),

          // Filter overlay
          Obx(() => viewmodel.showFilterOverlay.value ? _buildFilterOverlay() : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() {
            final sectionName = viewmodel.section.value?.name?.localize(viewmodel.selectedLanguage) ?? 'Products';
            return widgetFactory.createText(context, sectionName, style: Theme.of(context).textTheme.titleLarge).paddingOnly(bottom: 16);
          }),
          _buildSearchAndFilterBar(),
          // Applied filters row
          Obx(() => viewmodel.isFilterApplied ? _buildAppliedFilters() : const SizedBox.shrink()),
          Expanded(
            child: widgetFactory.createCard(
              child: Obx(() => _buildProductsTable()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
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
          // Filter button
          Obx(() => Material(
                color: viewmodel.isFilterApplied ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: viewmodel.toggleFilterOverlay,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: viewmodel.isFilterApplied ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: viewmodel.isFilterApplied ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAppliedFilters() {
    final List<Widget> chips = [];
    
    // Add sort filter chip if not default
    if (viewmodel.sortCategory.value?.selectedOptions.isNotEmpty == true) {
      final sortOpt = viewmodel.sortCategory.value!.selectedOptions.first;
      if (sortOpt.id != 'nameAsc') {
        chips.add(Chip(
          label: Text(sortOpt.name.localize(viewmodel.selectedLanguage)),
          onDeleted: () => viewmodel.toggleFilterOption(viewmodel.sortCategory.value!, sortOpt),
        ));
      }
    }
    
    // Add price range chip
    if (viewmodel.priceRangeCategory.value?.hasRangeFilter == true) {
      final range = viewmodel.priceRangeCategory.value!.currentRange!;
      chips.add(Chip(
        label: Text('${range.start.toInt()} - ${range.end.toInt()} ETB'),
        onDeleted: () => viewmodel.updatePriceRange(RangeValues(
          viewmodel.priceRangeCategory.value!.min,
          viewmodel.priceRangeCategory.value!.max,
        )),
      ));
    }
    
    // Add tag filter chips
    for (final category in viewmodel.filterCategories) {
      for (final option in category.selectedOptions) {
        chips.add(Chip(
          label: Text(option.name.localize(viewmodel.selectedLanguage)),
          onDeleted: () => viewmodel.toggleFilterOption(category, option),
        ));
      }
    }
    
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Applied Filters:', style: Theme.of(context).textTheme.titleSmall),
              TextButton(
                onPressed: viewmodel.clearAllFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }

  Widget _buildFilterOverlay() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: Colors.black54,
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: Theme.of(context).textTheme.titleLarge),
                      Row(
                        children: [
                          TextButton(
                            onPressed: viewmodel.clearAllFilters,
                            child: const Text('Clear All'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: viewmodel.toggleFilterOverlay,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Filter categories
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sort options
                        Obx(() {
                          if (viewmodel.sortCategory.value == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCategoryHeader(viewmodel.sortCategory.value!),
                              _buildRadioGroup(viewmodel.sortCategory.value!),
                              const Divider(),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                        
                        // Price range
                        Obx(() {
                          if (viewmodel.priceRangeCategory.value == null) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                viewmodel.priceRangeCategory.value!.name.localize(viewmodel.selectedLanguage),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              _buildPriceRangeSlider(),
                              const Divider(),
                              const SizedBox(height: 16),
                            ],
                          );
                        }),
                        
                        // Tag filter categories
                        Obx(() {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: viewmodel.filterCategories.map((category) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildCategoryHeader(category),
                                  category.selectionType == FilterSelectionType.single.name
                                      ? _buildRadioGroup(category)
                                      : _buildMultiSelectGroup(category),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                ],
                              );
                            }).toList(),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(FilterCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            category.name.localize(viewmodel.selectedLanguage),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup(FilterCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: category.options.map((option) {
        return RadioListTile<String>(
          title: Text(option.name.localize(viewmodel.selectedLanguage)),
          value: option.id,
          groupValue: category.selectedOptions.isNotEmpty ? category.selectedOptions.first.id : null,
          onChanged: (_) => viewmodel.toggleFilterOption(category, option),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectGroup(FilterCategory category) {
    return Wrap(
      spacing: 8.0,
      children: category.options.map((option) {
        return FilterChip(
          label: Text(option.name.localize(viewmodel.selectedLanguage)),
          selected: option.isSelected,
          onSelected: (_) => viewmodel.toggleFilterOption(category, option),
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    final category = viewmodel.priceRangeCategory.value!;
    final min = category.min;
    final max = category.max;
    final currentRangeValues = category.rangeValues ?? RangeValues(min, max);

    return Column(
      children: [
        RangeSlider(
          min: min,
          max: max,
          values: currentRangeValues,
          divisions: 20,
          labels: RangeLabels(
            '${currentRangeValues.start.toInt()} ETB',
            '${currentRangeValues.end.toInt()} ETB',
          ),
          onChanged: viewmodel.updatePriceRange,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${min.toInt()} ETB'),
              Text('${max.toInt()} ETB'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsTable() {
    if (viewmodel.products.isEmpty) {
      return const Center(
        child: Text('No products found in this section'),
      );
    }

    final filteredProducts = viewmodel.filteredProducts;

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text('No products match your search or filters', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (viewmodel.searchQuery.value.isNotEmpty)
                  TextButton(
                    onPressed: viewmodel.clearSearch,
                    child: const Text('Clear Search'),
                  ),
                if (viewmodel.isFilterApplied)
                  TextButton(
                    onPressed: viewmodel.clearAllFilters,
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
          ],
        ),
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
            headingRowColor: MaterialStateColor.resolveWith((states) => Theme.of(context).primaryColor.withOpacity(0.1)),
            columns: [
              const DataColumn(label: Text('Image')),
              const DataColumn(label: Text('Name')),
              const DataColumn(label: Text('Price')),
              const DataColumn(label: Text('Actions')),
            ],
            rows: filteredProducts.map((product) => _buildProductRow(product)).toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildProductRow(Product product) {
    return DataRow(
      cells: [
        DataCell(_buildProductImage(product)),
        DataCell(widgetFactory.createText(context, product.name?.localize(viewmodel.selectedLanguage) ?? '', style: Theme.of(context).textTheme.bodyMedium)),
        DataCell(widgetFactory.createText(context, product.getPrice()?.toSelectedPriceString('ETB') ?? '', style: Theme.of(context).textTheme.bodyMedium)),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widgetFactory.createIcon(
                materialIcon: Icons.visibility,
                onPressed: () => viewmodel.openProductDetails(context, product),
              ),
              const SizedBox(width: 8),
              widgetFactory.createIcon(
                materialIcon: Icons.add_shopping_cart,
                onPressed: () {
                  // Add to cart implementation
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product) {
    final imageUrl = product.getImageUrl();
    return AppImage(
      imageUrl: imageUrl,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
    );
  }
}
