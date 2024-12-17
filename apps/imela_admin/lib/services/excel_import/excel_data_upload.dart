import 'package:collection/collection.dart';
import 'package:imela_core/branch/model/inventory.model.dart';
import 'package:imela_core/product/model/product.model.dart';
import 'package:excel/excel.dart';
import 'package:imela_core/product/model/product_addon.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'dart:io';

import 'package:imela_core/shared/localized_field.model.dart';
import 'package:imela_core/shared/price.model.dart';
import 'package:imela_utils/helpers/localization_utils.dart';
import 'package:imela_utils/storage/storage_reponse.dart';
import 'package:imela_utils/storage/storage_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;

abstract class IExcelUpload {
  Future<List<Product>> importProductData(String filePath);
  Future<void> mapImagesWithProducts(List<Product> products, String imageFolderPath);
  Future<void> importProductAddonData(String filePath, List<Product> products);
}

@Injectable(as: IExcelUpload)
@Named(ExcelUpload.injectableName)
class ExcelUpload implements IExcelUpload {
  static const injectableName = 'ExcelUpload';
  final IStorageService storageService;

  ExcelUpload({@Named(StorageService.injectableName) required this.storageService});
  @override
  Future<List<Product>> importProductData(String filePath) async {
    List<Product> productList = [];

    // Read Excel file
    var file = File(filePath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Assuming the first sheet contains product data
    var sheet = excel.tables[excel.tables.keys.first];

    if (sheet != null) {
      for (var row in sheet.rows.skip(1)) {
        // Parse row data into a Product model
        Product product = _parseRowToProduct(row);
        productList.add(product);
      }
    }

    return productList;
  }

  @override
  Future<void> importProductAddonData(String filePath, List<Product> products) async {
    // Read the Excel file
    var file = File(filePath);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Assuming the first sheet contains addon data
    var sheet = excel.tables[excel.tables.keys.first];

    if (sheet != null) {
      for (var row in sheet.rows.skip(1)) {
        // Parse row data to get Addon info
        String? parentProductId = row[0]?.value?.toString();

        // Localized fields for name and description
        List<LocalizedField> addonName = [LocalizedField(key: 'en', value: row[1]?.value.toString()), LocalizedField(key: 'fr', value: row[2]?.value.toString())];
        List<LocalizedField> addonDescription = [LocalizedField(key: 'en', value: row[3]?.value.toString()), LocalizedField(key: 'fr', value: row[4]?.value.toString())];

        // Input type
        String inputType = row[5]?.value.toString() ?? '';

        // Addon options (comma-separated)
        List<ProductAddonOption> addonOptions = _parseAddonOptions(row[6]?.value.toString());

        // Additional prices (comma-separated, formatted as Currency-Amount)
        List<Price> additionalPrice = _parseAdditionalPrice(row[7]?.value.toString());

        // Min and Max amounts
        double minAmount = double.tryParse(row[8]?.value.toString() ?? '0') ?? 0;
        double maxAmount = double.tryParse(row[9]?.value.toString() ?? '0') ?? 0;

        // Find the parent product in the list
        Product? parentProduct = _findProductById(parentProductId, products);

        // If parent product exists, add the addon to it
        if (parentProduct != null) {
          ProductAddon addon = ProductAddon(
            name: addonName,
            // description: addonDescription,
            inputType: inputType,
            options: addonOptions,
            additionalPrice: additionalPrice,
            minAmount: minAmount,
            maxAmount: maxAmount,
          );

          parentProduct = parentProduct.copyWith(addons: [...(parentProduct.addons ?? []), addon]);
          // parentProduct?.addons?.add(addon);
        }
      }
    }
  }

  // Helper method to find a product by ID in the list
  Product? _findProductById(String? productId, List<Product> products) {
    if (productId == null) return null;
    return products.firstWhereOrNull(
      (product) => product.businessId == productId,
    );
  }

  // Helper method to parse addon options
  List<ProductAddonOption> _parseAddonOptions(String? optionsString) {
    if (optionsString == null || optionsString.isEmpty) return [];
    return optionsString.split(',').map((option) => ProductAddonOption(name: [LocalizedField(key: AppLanguage.ENGLISH.name, value: option)])).toList();
  }

  // Helper method to parse additional prices
  List<Price> _parseAdditionalPrice(String? priceString) {
    if (priceString == null || priceString.isEmpty) return [];

    return priceString.split(',').map((pricePart) {
      List<String> parts = pricePart.split('-');
      String currency = parts[0].trim();
      double amount = double.tryParse(parts[1].trim()) ?? 0;
      return Price(amount: amount, currency: currency);
    }).toList();
  }

  Product _parseRowToProduct(List<Data?> row) {
    // Map row data to Product model
    List<LocalizedField> name = [
      LocalizedField(key: AppLanguage.ENGLISH.name, value: row[0]?.value.toString()), // Assuming first column is product name in English
    ];

    List<LocalizedField> description = [
      LocalizedField(key: AppLanguage.ENGLISH.name, value: row[1]?.value.toString()), // Assuming second column is product description in English
    ];

    // Other fields mapping
    String? productImageName = row[2]?.value.toString(); // Assuming 3rd column is product image name
    List<String> branchIds = row[3]?.value.toString().split(',') ?? []; // Branch IDs as comma-separated

    // Assuming inventory, variants, and other product fields are handled similarly
    // Example inventory parsing (expand as necessary):
    Inventory inventory = Inventory(
      qty: double.tryParse(row[4]?.value.toString() ?? '0'),
      unit: row[5]?.value.toString(),
      inventoryLocationId: row[6]?.value.toString(),
    );

    return Product(
      name: name,
      description: description,
      featured: row[7]?.value == 'true', // Assuming boolean for 'featured'
      // gallery: Gallery(images: [productImageName]),
      branchIds: branchIds,
      inventory: [inventory],
      // Additional parsing logic for other fields
    );
  }

  @override
  Future<void> mapImagesWithProducts(List<Product> products, String imageFolderPath) async {
    // Step 1: Initialize a list of images in the directory
    final directory = Directory(imageFolderPath);
    final imageFiles = directory.listSync().whereType<File>().toList();

    // Prepare imagePaths to send for upload
    List<String> imagePaths = [];

    // Map through products
    for (Product product in products) {
      String productId = _getProductImageName(product); // e.g., product_1
      List<String> productImagePaths = _getImagePathsForProduct(productId, imageFiles);

      // Upload images for the product
      if (productImagePaths.isNotEmpty) {
        imagePaths.addAll(productImagePaths);
      }

      // Handle variants if they exist
      if (product.variants != null && product.variants!.isNotEmpty) {
        for (int i = 0; i < product.variants!.length; i++) {
          Product variant = product.variants![i];
          String variantId = _getVariantImageName(productId, i); // e.g., product_1_variant_1
          List<String> variantImagePaths = _getImagePathsForProduct(variantId, imageFiles);

          // Upload images for the variant
          if (variantImagePaths.isNotEmpty) {
            imagePaths.addAll(variantImagePaths);
          }
        }
      }
    }

    // Step 3: Upload the images to Firebase Storage
    if (imagePaths.isNotEmpty) {
      String directoryName = path.basename(imageFolderPath); // Use the folder name as directory name for storage
      StorageResponse response = await storageService.uploadImages(directoryName, imagePaths);
      if (response.success) {
        // Step 4: Map the downloaded URLs to each product's gallery
        _mapUrlsToProducts(products, response.downloadUrls ?? [], imageFiles);
      } else {
        throw Exception("Failed to upload images");
      }
    }
  }

  // Step 2: Helper method to get the image paths for a product or variant
  List<String> _getImagePathsForProduct(String productId, List<File> imageFiles) {
    return imageFiles.where((file) => path.basenameWithoutExtension(file.path).startsWith(productId)).map((file) => file.path).toList();
  }

  // Generate the product image name convention (e.g., product_1)
  String _getProductImageName(Product product) {
    return "product_${product.businessId}";
  }

  // Generate the variant image name convention (e.g., product_1_variant_1)
  String _getVariantImageName(String productId, int index) {
    return "${productId}_variant_$index";
  }

  // Step 4: Map the URLs to products based on their images
  void _mapUrlsToProducts(List<Product> products, List<String> downloadUrls, List<File> imageFiles) {
    int urlIndex = 0;

    for (Product product in products) {
      String productId = _getProductImageName(product);
      List<String> productImageUrls = [];

      // Map product images
      for (File imageFile in imageFiles) {
        if (path.basenameWithoutExtension(imageFile.path).startsWith(productId) && urlIndex < downloadUrls.length) {
          productImageUrls.add(downloadUrls[urlIndex]);
          urlIndex++;
        }
      }

      // Assign product gallery
      if (productImageUrls.isNotEmpty) {
        product = product.copyWith(gallery: Gallery(images: productImageUrls.map((url) => GalleryData(url: url)).toList()));
      }

      // Map variant images, if any
      if (product.variants != null && product.variants!.isNotEmpty) {
        for (int i = 0; i < product.variants!.length; i++) {
          Product variant = product.variants![i];
          String variantId = _getVariantImageName(productId, i);
          List<String> variantImageUrls = [];

          for (File imageFile in imageFiles) {
            if (path.basenameWithoutExtension(imageFile.path).startsWith(variantId) && urlIndex < downloadUrls.length) {
              variantImageUrls.add(downloadUrls[urlIndex]);
              urlIndex++;
            }
          }

          // Assign variant gallery
          if (variantImageUrls.isNotEmpty) {
            variant = variant.copyWith(gallery: Gallery(images: variantImageUrls.map((url) => GalleryData(url: url)).toList()));
          }
        }
      }
    }
  }
}
