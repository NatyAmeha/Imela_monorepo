import 'package:injectable/injectable.dart';
import 'package:imela/domain/order/repo/order.repository.dart';

@injectable
class OrderUsecase {
  OrderRepository _orderRepository;
  OrderUsecase(@Named(OrderRepository.injectName) this._orderRepository);
}
