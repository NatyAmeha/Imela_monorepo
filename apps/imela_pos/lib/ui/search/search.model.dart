import 'package:collection/collection.dart';
import 'package:imela_core/product/model/product.model.dart';

enum SearchType {
  product,
  order,
  customer,
  employee,
  supplier,
  stock,
  report,
}

enum SearchFilterType {
  CATEGORY,
  STATUS,
}

class SearchModel {
  final SearchType type;
  final String id;
  final String name;
  final List<String>? category;
  final String? status;
  final String? image;
  final double? price;
  final DateTime? date;

  SearchModel({required this.type, required this.id, required this.name, this.category, this.status, this.image, this.price, this.date});

  Product? getProductInfo({required List<Product> products}) {
    return products.firstWhereOrNull((product) => product.id == id);
  }
}
