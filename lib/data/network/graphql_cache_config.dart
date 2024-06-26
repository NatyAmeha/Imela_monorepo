import 'package:ferry_cache/ferry_cache.dart';
import 'package:hive/hive.dart';

class ExpiringStore extends Store {
  final Box _box;
  final Duration cacheDuration;

  ExpiringStore(this._box, this.cacheDuration);

  @override
  Map<String, dynamic>? get(String key) {
    final data = _box.get(key);
    if (data == null) return null;

    final cacheTime = DateTime.parse(data['cacheTime'] as String);
    if (DateTime.now().difference(cacheTime) > cacheDuration) {
      _box.delete(key);
      return null;
    }

    return data['data'] as Map<String, dynamic>?;
  }

  @override
  void put(String key, Map<String, dynamic>? value) {
    if (value == null) {
      _box.delete(key);
    } else {
      final dataWithCacheTime = {
        'data': value,
        'cacheTime': DateTime.now().toIso8601String(),
      };
      _box.put(key, dataWithCacheTime);
    }
  }

  @override
  void delete(String key) {
    _box.delete(key);
  }

  @override
  void clear() {
    _box.clear();
  }

  @override
  void deleteAll(Iterable<String> dataIds) {
    for (final id in dataIds) {
      _box.delete(id);
    }
  }

  @override
  Iterable<String> get keys => _box.keys.cast<String>();

  @override
  void putAll(Map<String, Map<String, dynamic>?> data) {
    final batch = <String, Map<String, dynamic>>{};
    data.forEach((key, value) {
      if (value == null) {
        _box.delete(key);
      } else {
        batch[key] = {
          'data': value,
          'cacheTime': DateTime.now().toIso8601String(),
        };
      }
    });
    _box.putAll(batch);
  }

  @override
  Stream<Map<String, dynamic>?> watch(String key, {bool distinct = true}) {
    return _box.watch(key: key).map((event) {
      final data = event.value as Map<String, dynamic>?;
      if (data == null) return null;

      final cacheTime = DateTime.parse(data['cacheTime'] as String);
      if (DateTime.now().difference(cacheTime) > cacheDuration) {
        _box.delete(key);
        return null;
      }

      return data['data'] as Map<String, dynamic>?;
    });
  }
}
