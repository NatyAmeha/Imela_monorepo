import 'package:imela_core/business/model/payment_option.model.dart';
import 'package:imela_core/shared/address.model.dart';
import 'package:imela_core/shared/gallery.model.dart';
import 'package:imela_core/shared/graphql_input_utils.dart';
import 'package:imela_core/shared/localized_field.model.dart';

class CreateBusinessInput {
  List<LocalizedField> name;
  List<LocalizedField> description;
  List<String> categories;
  String creator;
  Address mainAddress;
  String phoneNumber;
  String? email;
  Gallery? gallery;
  List<PaymentOption>? paymentOptions;

  CreateBusinessInput({
    required this.name,
    required this.description,
    required this.categories,
    required this.creator,
    required this.mainAddress,
    required this.phoneNumber,
    this.email,
    this.gallery,
    this.paymentOptions,
  });

  Function toGraphQLInput() {
    return (b) => b
      ..name.addAll(name.toLocalizedFieldInput())
      ..description.addAll(description.toLocalizedFieldInput())
      ..categories.addAll(categories)
      ..phoneNumber = phoneNumber
      ..creator = creator
      ..email = email
      ..mainAddress.update((b) => mainAddress.toGraphQLInput())
      ..gallery.update((b) => gallery?.toGraphQLInput())
      ..paymentOptions.addAll(paymentOptions?.map((e) => e.toGraphQLInput()));
  }
}
