import 'package:imela_core/product/model/product.model.dart';

extension ProductListExtension on List<Product> {
  List<Product> getProductsHavingCalendarInfo() {
    return where((product) => product.calendars?.isNotEmpty == true).toList();
  }
}
