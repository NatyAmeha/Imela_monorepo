import 'package:injectable/injectable.dart';
import 'package:melegna_customer/data/network/product_response.dart';
import 'package:melegna_customer/domain/product/repo/product.repository.dart';
import 'package:melegna_customer/services/logger/logger.service.dart';

@injectable
class ProductUsecase {
  final IProductRepository _productRepository;


  const ProductUsecase(@Named(ProductRepository.injectName) this._productRepository);

  Future<ProductResponse?> getProductDetails(String productId) async {
    final result = await _productRepository.getProductDetails(productId);
    return result;
  }
}
