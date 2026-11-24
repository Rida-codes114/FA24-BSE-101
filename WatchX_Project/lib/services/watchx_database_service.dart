
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef UserProfile = Map<String, dynamic>;
typedef WatchItem = Map<String, dynamic>;
typedef OrderItem = Map<String, dynamic>;

class WatchXDatabaseService {
  static const String dbName = 'watchx.db';
  static const int dbVersion = 3;

  static Database? _db;

  static final List<UserProfile> _webUsers = [];
  static final Set<String> _webFavorites = {};
  static final Map<String, int> _webCart = {};
  static final List<OrderItem> _webOrders = [];
  static final List<OrderItem> _webOrderItems = [];

  static String? _webActiveUserEmail;

  static bool _webDataLoaded = false;
  static const String _webStorageKey = 'watchx_web_data';

  // ---------------- WEB STORAGE ----------------

  static Future<void> _ensureWebDataLoaded() async {
    if (_webDataLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_webStorageKey);

    if (savedData != null) {
      try {
        final data = jsonDecode(savedData) as Map<String, dynamic>;

        _webUsers
          ..clear()
          ..addAll(
            (data['users'] as List? ?? []).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );

        _webFavorites
          ..clear()
          ..addAll(
            (data['favorites'] as List? ?? [])
                .map((item) => item.toString()),
          );

        _webCart
          ..clear()
          ..addAll(
            (data['cart'] as Map? ?? {}).map(
              (key, value) => MapEntry(
                key.toString(),
                (value as num).toInt(),
              ),
            ),
          );

        _webOrders
          ..clear()
          ..addAll(
            (data['orders'] as List? ?? []).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );

        _webOrderItems
          ..clear()
          ..addAll(
            (data['orderItems'] as List? ?? []).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );

        _webActiveUserEmail =
            data['activeUserEmail']?.toString();
      } catch (e) {
        debugPrint('Could not load WatchX web data: $e');
      }
    }

    _webDataLoaded = true;
  }

  static Future<void> _saveWebData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = {
      'users': _webUsers,
      'favorites': _webFavorites.toList(),
      'cart': _webCart,
      'orders': _webOrders,
      'orderItems': _webOrderItems,
      'activeUserEmail': _webActiveUserEmail,
    };

    await prefs.setString(
      _webStorageKey,
      jsonEncode(data),
    );
  }

  // ---------------- WATCH DATA ----------------

  static final List<WatchItem> _seedWatches = [
    {
      'id': 'wx_01',
      'brand': 'GENEVA ATELIER',
      'name': 'Montreux Grand Sport',
      'short_name': 'Montreux Grand Sport',
      'category': 'SPORTS CHRONO',
      'collection_tag': "MEN'S WATCHES",
      'price': 32000,
      'spec_tag': 'AUTOMATIC',
      'badge': 'BEST SELLER',
      'rating': 4.9,
      'reviews': 42,
      'stock_text': 'In Stock (5 Left)',
      'reference_code': 'REF. 4901-GS',
      'edition_banner': 'GENEVA CHRONOGRAPH SERIES',
      'synopsis':
          'Precision automatic chronograph with emerald dial and sapphire exhibition caseback.',
      'case_finish': 'ROSE GOLD',
      'strap_name': 'Hand-stitched Black Alligator Leather',
      'strap_extra': 0,
      'calibre': 'WX-940 Automatic',
      'reserve': '72 Hours',
      'frequency': '28,800 vph (4 Hz)',
      'diameter': '41.0 mm',
      'thickness': '12.4 mm',
      'water_resistance': '100 Metres (10 ATM)',
      'image_url':
          'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=900&q=80',
    },
    {
      'id': 'wx_02',
      'brand': 'AETHELGARD ROYAL',
      'name': 'Tourbillon Skeleton Calibre X',
      'short_name': 'Tourbillon Skeleton C...',
      'category': 'TOURBILLON',
      'collection_tag': "MEN'S WATCHES",
      'price': 42500,
      'spec_tag': 'ROSE GOLD',
      'badge': 'LIMITED 25',
      'rating': 5.0,
      'reviews': 28,
      'stock_text': 'In Stock (Only 2 Left)',
      'reference_code': 'REF. 7708-RG',
      'edition_banner': 'LIMITED EDITION',
      'synopsis':
          'Hand-finished rose gold skeletonized movement with flying tourbillon.',
      'case_finish': 'ROSE GOLD',
      'strap_name': 'Hand-stitched Black Alligator Leather',
      'strap_extra': 0,
      'calibre': 'AX-04 Manual Wind Skeleton',
      'reserve': '72 Hours Twin Barrel',
      'frequency': '28,800 vph (4 Hz)',
      'diameter': '43.0 mm',
      'thickness': '11.8 mm',
      'water_resistance': '50 Metres (5 ATM)',
      'image_url':
          'https://images.unsplash.com/photo-1547996160-81dfa63595aa?auto=format&fit=crop&w=900&q=80',
    },
    {
      'id': 'wx_03',
      'brand': 'GENEVA ATELIER',
      'name': 'Patrimony Classic',
      'short_name': 'Patrimony Classic',
      'category': 'DRESS & CLASSIC',
      'collection_tag': "WOMEN'S WATCHES",
      'price': 28400,
      'spec_tag': 'AUTOMATIC',
      'badge': 'ATELIER PICK',
      'rating': 4.8,
      'reviews': 19,
      'stock_text': 'In Stock (4 Left)',
      'reference_code': 'REF. 3120-PC',
      'edition_banner': 'GENEVA HERITAGE ARCHIVE',
      'synopsis':
          'Ultra-thin dress timepiece with refined baton indices and leather strap.',
      'case_finish': 'ROSE GOLD',
      'strap_name': 'Saddle Brown Alligator Leather',
      'strap_extra': 450,
      'calibre': 'GA-210 Ultra-Thin',
      'reserve': '65 Hours',
      'frequency': '21,600 vph (3 Hz)',
      'diameter': '39.0 mm',
      'thickness': '8.2 mm',
      'water_resistance': '30 Metres (3 ATM)',
      'image_url':
          'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&w=900&q=80',
    },
    {
      'id': 'wx_04',
      'brand': 'HORLOGERIE NORD',
      'name': 'Nautilus Black Ceramic',
      'short_name': 'Nautilus Black Cera...',
      'category': 'SPORTS CHRONO',
      'collection_tag': "MEN'S WATCHES",
      'price': 36200,
      'spec_tag': '42MM CERAMIC',
      'badge': 'IN VAULT',
      'rating': 4.9,
      'reviews': 35,
      'stock_text': 'In Stock (Only 2 Left)',
      'reference_code': 'REF. 8842-NC',
      'edition_banner': 'HIGH-TECH CERAMIC SERIES',
      'synopsis':
          'Stealth matte ceramic case paired with integrated link bracelet.',
      'case_finish': 'DLC BLACK',
      'strap_name': 'Vulcanized High-Grip Rubber',
      'strap_extra': 0,
      'calibre': 'HN-700 High-Beat',
      'reserve': '70 Hours',
      'frequency': '28,800 vph (4 Hz)',
      'diameter': '42.0 mm',
      'thickness': '10.6 mm',
      'water_resistance': '120 Metres (12 ATM)',
      'image_url':
          'https://images.unsplash.com/photo-1614164185128-e4aa99c436b7?auto=format&fit=crop&w=900&q=80',
    },
    {
      'id': 'wx_05',
      'brand': 'LE BRASSUS ATELIER',
      'name': 'Concept Titanium',
      'short_name': 'Concept Titanium',
      'category': 'TOURBILLON',
      'collection_tag': "MEN'S WATCHES",
      'price': 58000,
      'spec_tag': 'GRADE 5 TI',
      'badge': 'RARE PIECE',
      'rating': 4.8,
      'reviews': 31,
      'stock_text': 'Vault Allocation Only',
      'reference_code': 'REF. 9901-TI',
      'edition_banner': 'LE BRASSUS COMPLICATION',
      'synopsis':
          'Architectural open-dial complication housed in Grade 5 titanium.',
      'case_finish': 'TITANIUM',
      'strap_name': 'Vulcanized High-Grip Rubber',
      'strap_extra': 0,
      'calibre': 'LB-99 Tourbillon',
      'reserve': '72 Hours',
      'frequency': '21,600 vph (3 Hz)',
      'diameter': '42.5 mm',
      'thickness': '11.5 mm',
      'water_resistance': '100 Metres (10 ATM)',
      'image_url':
          'https://images.unsplash.com/photo-1508685096489-7aacd43bd3b1?auto=format&fit=crop&w=900&q=80',
    },
    {
      'id': 'wx_06',
      'brand': 'SCHAFFHAUSEN',
      'name': 'Perpetual Moonphase',
      'short_name': 'Perpetual Moonphase',
      'category': 'TOURBILLON',
      'collection_tag': "WOMEN'S WATCHES",
      'price': 39500,
      'spec_tag': 'MOONPHASE',
      'badge': 'COMPLICATION',
      'rating': 5.0,
      'reviews': 27,
      'stock_text': 'In Stock (1 Left)',
      'reference_code': 'REF. 6045-MP',
      'edition_banner': 'ASTRONOMICAL MOONPHASE',
      'synopsis':
          'Celestial midnight-blue dial with high-precision moonphase indicator.',
      'case_finish': 'TITANIUM',
      'strap_name': 'Hand-stitched Black Alligator Leather',
      'strap_extra': 0,
      'calibre': 'SH-512 Astronomical',
      'reserve': '72 Hours',
      'frequency': '28,800 vph (4 Hz)',
      'diameter': '40.5 mm',
      'thickness': '11.2 mm',
      'water_resistance': '50 Metres (5 ATM)',
      'image_url':
          'https://images.unsplash.com/photo-1522312346375-d1a52e2b99b3?auto=format&fit=crop&w=900&q=80',
    },
  ];

  // ---------------- DATABASE CONNECTION ----------------

  static Future<String> getDatabaseFilePath() async {
    final dbPath = await getDatabasesPath();
    return p.join(dbPath, dbName);
  }

  static Future<Database?> _openSqlDatabase() async {
    if (kIsWeb) {
      await _ensureWebDataLoaded();
      return null;
    }

    if (_db != null && _db!.isOpen) {
      return _db;
    }

    final path = await getDatabaseFilePath();

    _db = await openDatabase(
      path,
      version: dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);

        for (final watch in _seedWatches) {
          await db.insert(
            'watches',
            watch,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.delete(
            'cart_items',
            where: 'watch_id IN (?, ?)',
            whereArgs: ['wx_01', 'wx_02'],
          );
        }

        if (oldVersion < 3) {
          await _createOrderTables(db);
        }
      },
    );

    return _db;
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE watches (
        id TEXT PRIMARY KEY,
        brand TEXT NOT NULL,
        name TEXT NOT NULL,
        short_name TEXT NOT NULL,
        category TEXT NOT NULL,
        collection_tag TEXT NOT NULL,
        price INTEGER NOT NULL,
        spec_tag TEXT NOT NULL,
        badge TEXT NOT NULL,
        rating REAL NOT NULL,
        reviews INTEGER NOT NULL,
        stock_text TEXT NOT NULL,
        reference_code TEXT NOT NULL,
        edition_banner TEXT NOT NULL,
        synopsis TEXT NOT NULL,
        case_finish TEXT NOT NULL,
        strap_name TEXT NOT NULL,
        strap_extra INTEGER NOT NULL,
        calibre TEXT NOT NULL,
        reserve TEXT NOT NULL,
        frequency TEXT NOT NULL,
        diameter TEXT NOT NULL,
        thickness TEXT NOT NULL,
        water_resistance TEXT NOT NULL,
        image_url TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        watch_id TEXT PRIMARY KEY
      )
    ''');

    await db.execute('''
      CREATE TABLE cart_items (
        watch_id TEXT PRIMARY KEY,
        quantity INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await _createOrderTables(db);
  }

  static Future<void> _createOrderTables(Database db) async {
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        user_email TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        status TEXT NOT NULL,
        subtotal INTEGER NOT NULL,
        delivery_fee INTEGER NOT NULL,
        total INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        watch_id TEXT NOT NULL,
        watch_name TEXT NOT NULL,
        brand TEXT NOT NULL,
        image_url TEXT NOT NULL,
        unit_price INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        line_total INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id)
          ON DELETE CASCADE
      )
    ''');
  }

  // ---------------- BACKUP AND RESTORE SUPPORT ----------------

  static Future<void> prepareDatabaseForBackup() async {
    if (kIsWeb) return;

    final db = await _openSqlDatabase();

    if (db != null && db.isOpen) {
      await db.rawQuery('PRAGMA wal_checkpoint(FULL)');
      await db.close();
      _db = null;
    }
  }

  static Future<void> closeDatabaseForRestore() async {
    if (kIsWeb) return;

    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }

  static Future<void> reopenDatabaseAfterRestore() async {
    if (kIsWeb) return;

    await closeDatabaseForRestore();
    await _openSqlDatabase();
  }

  // ---------------- USERS ----------------

  static Future<String?> registerUser({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _openSqlDatabase();

    if (db == null) {
      final exists = _webUsers.any(
        (user) => user['email'] == normalizedEmail,
      );

      if (exists) {
        return 'An account with this email already exists.';
      }

      _webUsers.add({
        'full_name': fullName.trim(),
        'email': normalizedEmail,
        'password': password,
        'is_active': 1,
      });

      _webActiveUserEmail = normalizedEmail;

      await _saveWebData();
      return null;
    }

    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [normalizedEmail],
    );

    if (existing.isNotEmpty) {
      return 'An account with this email already exists.';
    }

    await db.transaction((txn) async {
      await txn.update('users', {'is_active': 0});

      await txn.insert('users', {
        'full_name': fullName.trim(),
        'email': normalizedEmail,
        'password': password,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    return null;
  }

  static Future<UserProfile?> loginUser({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final db = await _openSqlDatabase();

    if (db == null) {
      for (final user in _webUsers) {
        if (user['email'] == normalizedEmail &&
            user['password'] == password) {
          _webActiveUserEmail = normalizedEmail;

          await _saveWebData();

          return Map<String, dynamic>.from(user);
        }
      }

      return null;
    }

    final rows = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [normalizedEmail, password],
    );

    if (rows.isEmpty) return null;

    await db.transaction((txn) async {
      await txn.update('users', {'is_active': 0});

      await txn.update(
        'users',
        {'is_active': 1},
        where: 'id = ?',
        whereArgs: [rows.first['id']],
      );
    });

    final updatedRows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [rows.first['id']],
      limit: 1,
    );

    return updatedRows.isEmpty
        ? null
        : Map<String, dynamic>.from(updatedRows.first);
  }

  static Future<UserProfile?> getActiveUser() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      if (_webActiveUserEmail == null) return null;

      for (final user in _webUsers) {
        if (user['email'] == _webActiveUserEmail) {
          return Map<String, dynamic>.from(user);
        }
      }

      return null;
    }

    final rows = await db.query(
      'users',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return Map<String, dynamic>.from(rows.first);
  }

  static Future<void> logoutUser() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      _webActiveUserEmail = null;
      await _saveWebData();
      return;
    }

    await db.update('users', {'is_active': 0});
  }

  // ---------------- WATCHES ----------------

  static Future<List<WatchItem>> getWatches({
    String searchQuery = '',
    String categoryFilter = 'ALL',
    String sortBy = 'FEATURED',
  }) async {
    final db = await _openSqlDatabase();

    List<WatchItem> items;

    if (db == null) {
      items = _seedWatches
          .map((watch) => Map<String, dynamic>.from(watch))
          .toList();
    } else {
      final rows = await db.query('watches');

      items = rows
          .map((watch) => Map<String, dynamic>.from(watch))
          .toList();

      if (items.isEmpty) {
        for (final watch in _seedWatches) {
          await db.insert(
            'watches',
            watch,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }

        items = _seedWatches
            .map((watch) => Map<String, dynamic>.from(watch))
            .toList();
      }
    }

    final query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      items = items.where((watch) {
        final name = (watch['name'] ?? '').toString().toLowerCase();
        final brand = (watch['brand'] ?? '').toString().toLowerCase();
        final category =
            (watch['category'] ?? '').toString().toLowerCase();
        final reference = (watch['reference_code'] ?? '')
            .toString()
            .toLowerCase();

        return name.contains(query) ||
            brand.contains(query) ||
            category.contains(query) ||
            reference.contains(query);
      }).toList();
    }

    if (categoryFilter == "MEN'S WATCHES" ||
        categoryFilter == "WOMEN'S WATCHES") {
      items = items.where((watch) {
        return (watch['collection_tag'] ?? '')
                .toString()
                .toUpperCase() ==
            categoryFilter;
      }).toList();
    } else if (categoryFilter == 'TOURBILLON' ||
        categoryFilter == 'SPORTS CHRONO') {
      items = items.where((watch) {
        return (watch['category'] ?? '')
                .toString()
                .toUpperCase() ==
            categoryFilter;
      }).toList();
    }

    if (sortBy == 'PRICE_LOW') {
      items.sort(
        (a, b) => (a['price'] as int).compareTo(b['price'] as int),
      );
    } else if (sortBy == 'PRICE_HIGH') {
      items.sort(
        (a, b) => (b['price'] as int).compareTo(a['price'] as int),
      );
    } else if (sortBy == 'RATING') {
      items.sort(
        (a, b) =>
            (b['rating'] as num).compareTo(a['rating'] as num),
      );
    }

    return items;
  }

  // ---------------- FAVORITES ----------------

  static Future<Set<String>> getFavoriteIds() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      return Set<String>.from(_webFavorites);
    }

    final rows = await db.query('favorites');

    return rows.map((row) => row['watch_id'].toString()).toSet();
  }

  static Future<bool> toggleFavorite(String watchId) async {
    final db = await _openSqlDatabase();

    if (db == null) {
      if (_webFavorites.contains(watchId)) {
        _webFavorites.remove(watchId);
        await _saveWebData();
        return false;
      }

      _webFavorites.add(watchId);
      await _saveWebData();
      return true;
    }

    final existing = await db.query(
      'favorites',
      where: 'watch_id = ?',
      whereArgs: [watchId],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'watch_id = ?',
        whereArgs: [watchId],
      );
      return false;
    }

    await db.insert(
      'favorites',
      {'watch_id': watchId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return true;
  }

  // ---------------- CART ----------------

  static Future<int> getCartCount() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      return _webCart.values.fold<int>(
        0,
        (total, quantity) => total + quantity,
      );
    }

    final rows = await db.rawQuery(
      'SELECT COALESCE(SUM(quantity), 0) AS total FROM cart_items',
    );

    return (rows.first['total'] as num?)?.toInt() ?? 0;
  }

  static Future<Map<String, int>> getCartItemsMap() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      return Map<String, int>.from(_webCart);
    }

    final rows = await db.query('cart_items');
    final result = <String, int>{};

    for (final row in rows) {
      result[row['watch_id'].toString()] =
          (row['quantity'] as int?) ?? 1;
    }

    return result;
  }

  static Future<void> addToCart(
    String watchId,
    int qtyToAdd,
  ) async {
    if (qtyToAdd <= 0) return;

    final db = await _openSqlDatabase();

    if (db == null) {
      _webCart[watchId] =
          (_webCart[watchId] ?? 0) + qtyToAdd;

      await _saveWebData();
      return;
    }

    final rows = await db.query(
      'cart_items',
      where: 'watch_id = ?',
      whereArgs: [watchId],
    );

    if (rows.isEmpty) {
      await db.insert('cart_items', {
        'watch_id': watchId,
        'quantity': qtyToAdd,
      });
    } else {
      final currentQuantity =
          (rows.first['quantity'] as int?) ?? 1;

      await db.update(
        'cart_items',
        {'quantity': currentQuantity + qtyToAdd},
        where: 'watch_id = ?',
        whereArgs: [watchId],
      );
    }
  }

  static Future<List<WatchItem>> getCartItems() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      final result = <WatchItem>[];

      for (final entry in _webCart.entries) {
        final watch = _seedWatches.firstWhere(
          (item) => item['id'] == entry.key,
          orElse: () => <String, dynamic>{},
        );

        if (watch.isNotEmpty) {
          result.add({
            ...watch,
            'quantity': entry.value,
          });
        }
      }

      return result;
    }

    final rows = await db.rawQuery('''
      SELECT watches.*, cart_items.quantity
      FROM cart_items
      INNER JOIN watches ON watches.id = cart_items.watch_id
    ''');

    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  static Future<void> updateCartQuantity(
    String watchId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeFromCart(watchId);
      return;
    }

    final db = await _openSqlDatabase();

    if (db == null) {
      if (_webCart.containsKey(watchId)) {
        _webCart[watchId] = quantity;
        await _saveWebData();
      }
      return;
    }

    await db.update(
      'cart_items',
      {'quantity': quantity},
      where: 'watch_id = ?',
      whereArgs: [watchId],
    );
  }

  static Future<void> removeFromCart(String watchId) async {
    final db = await _openSqlDatabase();

    if (db == null) {
      _webCart.remove(watchId);
      await _saveWebData();
      return;
    }

    await db.delete(
      'cart_items',
      where: 'watch_id = ?',
      whereArgs: [watchId],
    );
  }

  static Future<void> clearCart() async {
    final db = await _openSqlDatabase();

    if (db == null) {
      _webCart.clear();
      await _saveWebData();
      return;
    }

    await db.delete('cart_items');
  }

  // ---------------- ORDERS ----------------

  static Future<String> placeOrder({
    required String customerName,
    required String phone,
    required String address,
    required String city,
    required String paymentMethod,
    int deliveryFee = 0,
  }) async {
    final cartItems = await getCartItems();

    if (cartItems.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final user = await getActiveUser();
    final userEmail = user?['email']?.toString() ?? '';

    final orderId =
        'WX${DateTime.now().millisecondsSinceEpoch}';

    int subtotal = 0;
    final itemsToSave = <OrderItem>[];

    for (final item in cartItems) {
      final price = (item['price'] as num?)?.toInt() ?? 0;
      final quantity =
          (item['quantity'] as num?)?.toInt() ?? 1;
      final lineTotal = price * quantity;

      subtotal += lineTotal;

      itemsToSave.add({
        'watch_id': item['id'].toString(),
        'watch_name': item['name']?.toString() ?? 'Watch',
        'brand': item['brand']?.toString() ?? '',
        'image_url': item['image_url']?.toString() ?? '',
        'unit_price': price,
        'quantity': quantity,
        'line_total': lineTotal,
      });
    }

    final total = subtotal + deliveryFee;
    final createdAt = DateTime.now().toIso8601String();

    final order = <String, dynamic>{
      'id': orderId,
      'user_email': userEmail,
      'customer_name': customerName.trim(),
      'phone': phone.trim(),
      'address': address.trim(),
      'city': city.trim(),
      'payment_method': paymentMethod,
      'status': 'Pending',
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'created_at': createdAt,
    };

    final db = await _openSqlDatabase();

    if (db == null) {
      _webOrders.add(order);

      for (final item in itemsToSave) {
        _webOrderItems.add({
          ...item,
          'order_id': orderId,
        });
      }

      _webCart.clear();

      await _saveWebData();
      return orderId;
    }

    await db.transaction((txn) async {
      await txn.insert('orders', order);

      for (final item in itemsToSave) {
        await txn.insert(
          'order_items',
          {
            ...item,
            'order_id': orderId,
          },
        );
      }

      await txn.delete('cart_items');
    });

    return orderId;
  }

  static Future<List<OrderItem>> getOrders({
    String? userEmail,
  }) async {
    final db = await _openSqlDatabase();

    if (db == null) {
      return _webOrders
          .where(
            (order) =>
                userEmail == null ||
                order['user_email'] == userEmail,
          )
          .map((order) => Map<String, dynamic>.from(order))
          .toList()
          .reversed
          .toList();
    }

    final rows = userEmail == null
        ? await db.query(
            'orders',
            orderBy: 'created_at DESC',
          )
        : await db.query(
            'orders',
            where: 'user_email = ?',
            whereArgs: [userEmail],
            orderBy: 'created_at DESC',
          );

    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  static Future<OrderItem?> getOrderById(
    String orderId,
  ) async {
    final db = await _openSqlDatabase();

    if (db == null) {
      for (final order in _webOrders) {
        if (order['id'] == orderId) {
          return Map<String, dynamic>.from(order);
        }
      }

      return null;
    }

    final rows = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return Map<String, dynamic>.from(rows.first);
  }

  static Future<List<OrderItem>> getOrderItems(
    String orderId,
  ) async {
    final db = await _openSqlDatabase();

    if (db == null) {
      return _webOrderItems
          .where((item) => item['order_id'] == orderId)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    final rows = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );

    return rows
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }
}
