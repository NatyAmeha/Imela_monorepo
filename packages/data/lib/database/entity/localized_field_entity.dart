import 'package:isar/isar.dart';

part 'localized_field_entity.g.dart';

@embedded
class LocalizedFieldEntity {
  String? key;
  String? value;

  LocalizedFieldEntity({
    this.key,
    this.value,
  });
}
