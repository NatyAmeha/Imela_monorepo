import 'package:imela_data/database/entity/locationentity.dart';
import 'package:imela_data/database/entity/pos_business.entity.dart';
import 'package:imela_data/database/entity/pos_customer_entity.dart';
import 'package:imela_data/database/entity/pos_order_entity.dart';
import 'package:imela_data/database/entity/pos_product_entity.dart';
import 'package:imela_utils/exception/app_exception.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

abstract class IDBDataSource {
  Future<Isar> getDBInstance(String dbName);

  Future<List<T>> getAllData<T>(String dbName, IsarCollection<T> collection);
  Future<bool> isDataExist<T>(String dbName, IsarCollection<T> collection, QueryBuilder<T, T, QAfterWhereClause> Function(QueryBuilder<T, T, QWhereClause>) queryBuilder);
  Future<T?> getDataById<T>(IsarCollection<T> collection, int id);
  Future<List<T>> getByIds<T>(IsarCollection<T> collection, List<int> ids);

  Future<List<int>> saveMultiple<T>(String dbName, {required IsarCollection<T> collection, required List<T> data});
  Future<int> save<T>(String dbName, IsarCollection<T> collection, T data);
  Future<List<T>> query<T>(String dbName, IsarCollection<T> collection, QueryBuilder<T, T, QAfterFilterCondition> Function(QueryBuilder<T, T, QWhere>) queryBuilder);
  // Future<bool> deleteData<T>(IsarCollection<T> collection, List<int> ids);
}

@Injectable(as: IDBDataSource)
@Named(POSDBDataSource.injectName)
class POSDBDataSource implements IDBDataSource {
  static const injectName = 'ISarDBDataSource';
  static final List<CollectionSchema> schemas = [
    POSBusinessEntitySchema,
    LocationEntitySchema,
    PosCustomerEntitySchema,
    POSProductEntitySchema,
    OrderEntitySchema,
  ];

  static Isar? _dbInstance;

  static Future<Isar> initDB(String dbName) async {
    try {
      if (_dbInstance == null) {
        final dir = await getApplicationDocumentsDirectory();
        var existingInstance = Isar.getInstance(dbName);
        print("existingInstance ${existingInstance?.name}");
        if (existingInstance != null) {
          _dbInstance = existingInstance;
        } else {
          var isar = await Isar.open(schemas, directory: dir.path, name: dbName);
          _dbInstance = isar;
        }
      }
      return _dbInstance!;
    } catch (ex) {
      print("error opening db $ex");
      return Future.error('error opening db');
    }
  }

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
          var isar = await Isar.open(schemas, directory: dir.path, name: dbName);
          _dbInstance = isar;
        }
      }
      return _dbInstance!;
    } catch (ex) {
      print("error opening db $ex");
      return Future.error('error opening db');
    }
  }

  Future<bool> isDataExist<T>(String dbName, IsarCollection<T> collection, QueryBuilder<T, T, QAfterWhereClause> Function(QueryBuilder<T, T, QWhereClause>) queryBuilder) async {
    // Create a query using the provided query builder
    await getDBInstance(dbName);
    final query = queryBuilder(collection.where()).build();
    // Check if there is at least one result
    return await query.count() > 0;
  }

  @override
  Future<List<T>> getAllData<T>(String dbName, IsarCollection<T> collection) async {
    final dbInstance = await getDBInstance(dbName);
    return await dbInstance.txn(() async {
      return await collection.where().findAll();
    });
  }

  @override
  Future<T?> getDataById<T>(IsarCollection<T> collection, int id) async {
    return await collection.get(id);
  }

  @override
  Future<List<T>> getByIds<T>(IsarCollection<T> collection, List<int> ids) async {
    final result = await collection.getAll(ids);
    return result.where((element) => element != null).cast<T>().toList();
  }

  Future<List<T>> query<T>(
    String dbName,
    IsarCollection<T> collection,
    QueryBuilder<T, T, QAfterFilterCondition> Function(QueryBuilder<T, T, QWhere>) queryBuilder,
  ) async {
    // Create a query using the provided query builder
    final query = queryBuilder(collection.where()).build();
    return await query.findAll();
  }

  @override
  Future<List<int>> saveMultiple<T>(String dbName, {required IsarCollection<T> collection, required List<T> data}) async {
    var db = await getDBInstance(dbName);
    return await db.writeTxn(() async {
      return await collection.putAll(data);
    });
  }

  @override
  Future<int> save<T>(String dbName, IsarCollection<T> collection, T data) async {
    try {
      var db = await getDBInstance(dbName);

      return await db.writeTxn(() async {
        return await collection.put(data);
      });
    } catch (ex) {
      print("error saving data $ex");
      return Future.error(AppException(message: 'error saving data'));
    }
  }
}
