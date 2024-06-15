import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class CustomListController<T> extends GetxController {
  var items = <T>[].obs;

  // Method to add an item
  void addItems(List<T>? newITems) {
    if(newITems?.isNotEmpty ?? false){
      items.addAll(newITems!);
    }
  }

  // Method to update an item
  void updateItem(int index, T newItem) {
    items[index] = newItem;
  }

  // Add methods to add, remove or initialize items as needed
}
