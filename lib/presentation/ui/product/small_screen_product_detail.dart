import 'package:flutter/material.dart';
import 'package:melegna_customer/domain/shared/localized_field.model.dart';
import 'package:melegna_customer/presentation/ui/product/product_details.viewmodel.dart';
import 'package:melegna_customer/presentation/utils/localization_utils.dart';

class SmallScreenProductDetail extends StatelessWidget {
  final ProductDetailsViewmodel productDetailViewmodel;

  const SmallScreenProductDetail({super.key, required this.productDetailViewmodel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(productDetailViewmodel.productDetails.value!.product?.name?.getLocalizedValue(AppLanguage.ENGLISH.name) ?? "No data"),
    );
  }
}
