import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:melegna_customer/injection.dart';
import 'package:melegna_customer/presentation/ui/product/product_details.viewmodel.dart';
import 'package:melegna_customer/presentation/ui/product/small_screen_product_detail.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/page_content_loader.dart';
import 'package:melegna_customer/presentation/ui/shared/page_loading_utils/responsive_wrapper.dart';

class ProductDetailPage extends StatefulWidget {
  static const routeName = '/product/:id';

  ProductDetailsViewmodel? productDetailViewmodel;
  String productId;
  final String? productName;
  ProductDetailPage({super.key, this.productDetailViewmodel, required this.productId, this.productName}) {
    productDetailViewmodel ??= Get.put(getIt<ProductDetailsViewmodel>());
  }

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  void initializeViewmodel() {
    Future.delayed(Duration.zero, () {
      widget.productDetailViewmodel!.initViewmodel(data: {'id': widget.productId});
    });
  }

  @override
  void initState() {
    super.initState();
    initializeViewmodel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.productName}"),
      ),
      body: Obx(
        () => PageContentLoader(
            isLoading: widget.productDetailViewmodel!.isLoading.value,
            hasError: widget.productDetailViewmodel!.exception.value?.isMainError ?? false,
            showContent: widget.productDetailViewmodel!.productDetails.value != null,
            content: ResponsiveWrapper(
              smallScreen: SmallScreenProductDetail(productDetailViewmodel: widget.productDetailViewmodel!),
            )),
      ),
    );
  }
}
