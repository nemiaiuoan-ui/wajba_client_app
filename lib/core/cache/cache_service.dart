import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../error/failures.dart';

// ═══════════════════════════════════════════════
// HIVE CACHE SERVICE — handles offline Algeria
// ═══════════════════════════════════════════════
class CacheService {
  static const _restaurantBox = 'restaurants';
  static const _categoriesBox = 'categories';
  static const _userBox = 'user';
  static const _ordersBox = 'orders';
  static const _ttlBox = 'ttl';

  // TTL durations
  static const restaurantTtl = Duration(minutes: 30);
  static const categoriesTtl = Duration(hours: 6);
  static const ordersTtl = Duration(minutes: 5);

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(_restaurantBox),
      Hive.openBox(_categoriesBox),
      Hive.openBox<Map>(_userBox),
      Hive.openBox(_ordersBox),
      Hive.openBox<int>(_ttlBox),
    ]);
  }

  static Future<void> clearAll() async {
    final boxes = [_restaurantBox, _categoriesBox, _userBox, _ordersBox, _ttlBox];
    for (final name in boxes) {
      if (Hive.isBoxOpen(name)) await Hive.box(name).clear();
    }
  }

  // ── Generic cache write ────────────────────────
  static Future<void> write<T>(String box, String key, T value, {Duration? ttl}) async {
    final b = Hive.box(box);
    if (value is List || value is Map) {
      await b.put(key, jsonEncode(value));
    } else {
      await b.put(key, value);
    }
    // Store TTL timestamp
    if (ttl != null) {
      final ttlBox = Hive.box<int>(_ttlBox);
      await ttlBox.put('${box}_$key', DateTime.now().add(ttl).millisecondsSinceEpoch);
    }
  }

  // ── Generic cache read ─────────────────────────
  static T? read<T>(String box, String key, {bool checkTtl = true}) {
    if (checkTtl && _isExpired(box, key)) return null;
    final b = Hive.box(box);
    final val = b.get(key);
    if (val == null) return null;
    if (T == String) return val as T?;
    if (val is String) {
      try {
        final decoded = jsonDecode(val);
        return decoded as T?;
      } catch (_) {
        return val as T?;
      }
    }
    return val as T?;
  }

  static bool _isExpired(String box, String key) {
    final ttlBox = Hive.box<int>(_ttlBox);
    final expiry = ttlBox.get('${box}_$key');
    if (expiry == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiry;
  }

  // ── Specific helpers ─────────────────────────
  static Future<void> cacheRestaurants(List<Map<String, dynamic>> data) =>
      write(_restaurantBox, 'list', data, ttl: restaurantTtl);

  static List<Map<String, dynamic>>? getCachedRestaurants() {
    final raw = read<List>(_restaurantBox, 'list');
    return raw?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> cacheCategories(List<Map<String, dynamic>> data) =>
      write(_categoriesBox, 'list', data, ttl: categoriesTtl);

  static List<Map<String, dynamic>>? getCachedCategories() {
    final raw = read<List>(_categoriesBox, 'list');
    return raw?.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static Future<void> cacheRestaurantDetail(String id, Map<String, dynamic> data) =>
      write(_restaurantBox, 'detail_$id', data, ttl: restaurantTtl);

  static Map<String, dynamic>? getCachedRestaurantDetail(String id) {
    final raw = read<Map>(_restaurantBox, 'detail_$id');
    return raw != null ? Map<String, dynamic>.from(raw) : null;
  }

  static Future<void> cacheUser(Map<String, dynamic> user) =>
      write(_userBox, 'current', user);

  static Map<String, dynamic>? getCachedUser() {
    final raw = read<Map>(_userBox, 'current', checkTtl: false);
    return raw != null ? Map<String, dynamic>.from(raw) : null;
  }

  static Future<void> invalidateRestaurants() async {
    final b = Hive.box(_restaurantBox);
    await b.clear();
  }
}
