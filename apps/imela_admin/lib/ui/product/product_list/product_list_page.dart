import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_list_item.dart';
import 'package:imela_admin/ui/product/product_list/product_list.viewmodel.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';
import 'package:imela_ui_kit/components/page_loading_utils/page_content_loader.dart';

class ProductListPage extends StatefulWidget {
  static const routeName = '/products';
  ProductListPage({super.key});

  static void navigate(BuildContext context) {
    final router = AppViewmodel.getInstance().appRouter;
    router.navigateTo(context, routeName);
  }

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> with TickerProviderStateMixin {
  final viewmodel = ProductListViewModel.getInstance();

  @override
  void initState() {
    super.initState();
    viewmodel.initViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context); 
    return Scaffold(
      body: Obx(
        () => PageContentLoader(
          showContent:  true, //viewmodel.products.value.isNotEmpty && viewmodel.exception.value == null,
          isLoading: viewmodel.isLoading.value,
          hasError: viewmodel.exception.value?.isMainError ?? false,
          exception: viewmodel.exception.value,
          onTryAgain: () {
            viewmodel.fetchProducts();
          },
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widgetFactory.createText(context, 'Product List', style: Theme.of(context).textTheme.headlineMedium),
                  widgetFactory.createButton(
                      context: context,
                      content: Text('Add new product'),
                      onPressed: () {
                        viewmodel.navigateToCreateProductPage(context);
                      }),
                ],
              ),
              const SizedBox(height: 24),
              _buildTabBar(),
              _buildSearchAndFilter(),
              AppListView<Product>(
                items: viewmodel.products.value,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                height: 600,
                itemBuilder: (context, product, index) {
                  return ProductListItem(product: product, onTap: () {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TabBar for selecting between All, Featured, and Active products
  Widget _buildTabBar() {
    return Obx(() {
      return TabBar(
        onTap: (index) {
          viewmodel.updateTabIndex(index);
        },
        tabs: [
          const Tab(text: 'All'),
          const Tab(text: 'Featured'),
          const Tab(text: 'Active'),
        ],
        // labelColor: Colors.blue,
        // unselectedLabelColor: Colors.grey,
        // indicatorColor: Colors.blue,
        controller: TabController(
          length: 3,
          vsync: this,
          initialIndex: viewmodel.selectedTabIndex.value,
        ),
      );
    });
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: TextField(
              onChanged: (value) {
                viewmodel.updateSearchQuery(value);
              },
              decoration: const InputDecoration(
                hintText: 'Search products',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Filter icon
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality here
            },
          ),
        ],
      ),
    );
  }
}
