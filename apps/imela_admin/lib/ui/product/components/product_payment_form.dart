import 'package:flutter/material.dart';
import 'package:imela_admin/app/app_viewmodel.dart';
import 'package:imela_admin/ui/product/components/product_options_form.dart';
import 'package:imela_admin/ui/product/product_price.viewmodel.dart';
import 'package:imela_core/branch/model/branch.model.dart';

class ProductPaymentForm extends StatefulWidget {
  static const String kBranches = 'branches';
  static const String kVariants = 'variants';
  final List<Branch> branches;
  final List<ProductVariant> variants;
  const ProductPaymentForm({super.key, required this.branches, required this.variants});

  @override
  State<ProductPaymentForm> createState() => _ProductPaymentFormState();
}

class _ProductPaymentFormState extends State<ProductPaymentForm> {
  var viewModel = ProductPriceViewmodel.getInstance();

  @override
  void initState() {
    super.initState();
    viewModel.initViewmodel(data: {ProductPaymentForm.kBranches: widget.branches, ProductPaymentForm.kVariants: widget.variants});
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        widgetFactory.createText(context, 'Payment', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  } 
}
