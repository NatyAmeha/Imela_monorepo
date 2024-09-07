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

  void setItems(List<T> newItems) {
    items.value= newItems;
  }

  // Method to update an item
  void updateItem(int index, T newItem) {
    items.value = List<T>.from(items.value)..[index] = newItem;
  }

  void removeItems(List<int> indexs ){
    items.value = List<T>.from(items.value)..removeWhere((element) => indexs.contains(items.value.indexOf(element)));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    items.clear();
    
    super.dispose();
  }

  // Add methods to add, remove or initialize items as needed
}
