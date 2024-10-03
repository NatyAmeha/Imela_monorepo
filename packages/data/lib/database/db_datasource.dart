import 'package:imela_data/database/entity/pos_business.entity.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

abstract class IDBDataSource {
  Future<Isar> getDBInstance(String dbName);
}

@Injectable(as: IDBDataSource)
@Named(POSDBDataSource.injectName)
class POSDBDataSource implements IDBDataSource {
  static const injectName = 'ISarDBDataSource';
  static final List<CollectionSchema> schemas = [
    POSBusinessEntitySchema,
  ];

  static Isar? _dbInstance;

  @override
  Future<Isar> getDBInstance(String dbName) async {
    try {
      if (_dbInstance == null) {
        final dir = await getApplicationDocumentsDirectory();
        var existingInstance = Isar.getInstance(dbName);
        print("existingInstance ${existingInstance?.name}");
        if (existingInstance != null) {
          _dbInstance = existingInstance;
        } else {
          final isar = await Isar.open(schemas, directory: dir.path, name: dbName);
          _dbInstance = isar;
        }
      }
      return _dbInstance!;
    } catch (ex) {
      print("error opening db $ex");
      return Future.error('error opening db');
    }
  }
}
