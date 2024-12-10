import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:imela_core/customer/model/customer.model.dart';

part 'customer.response.freezed.dart';
part 'customer.response.g.dart';

@freezed
class CustomerResponse with _$CustomerResponse {
  const CustomerResponse._();
  const factory CustomerResponse({
    bool? success,
    String? message,
    Customer? customer,
    List<Customer>? customers,
  }) = _CustomerResponse;

  factory CustomerResponse.fromJson(Map<String, dynamic> json) => _$CustomerResponseFromJson(json);

  bool isCustomerCreateSuccess(){
    if((success ?? false) && (customers?.isNotEmpty ?? false)){
      return true;
    }
    return false;
  }
}
