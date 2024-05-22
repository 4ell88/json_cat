import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'models.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'main.dart'; // Импорт для доступа к navigatorKey

class ApiService {
  static const String catalogUrl = 'http://85.215.167.91/public/catalog.json';

  static Future<void> syncDataWithDatabase() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return;
    }

    try {
      final response = await http.get(Uri.parse(catalogUrl));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        if (data['categories'] != null) {
          await DatabaseService.insertCategories(data['categories']);

          for (var category in data['categories']) {
            if (category['subcategories'] != null) {
              await DatabaseService.insertSubCategories(
                  category['subcategories']);
            }
          }
        }

        int added = await DatabaseService.updateProducts(data['products']);
        int deleted =
            await DatabaseService.deleteNonExistingProducts(data['products']);
        print(response.body);

        print("Added $added products");
        print("Deleted $deleted products");

        final products = (data['products'] as List)
            .map((p) => Product.fromJson(p as Map<String, dynamic>))
            .toList();
        await cacheAllImages(products);
      } else {
        throw Exception('Failed to load catalog data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  static Future<Map<String, dynamic>?> fetchCatalogData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return null;
    }

    try {
      final response = await http.get(Uri.parse(catalogUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load catalog data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  static Future<void> cacheAllImages(List<Product> products) async {
    for (var product in products) {
      await precacheImage(
        CachedNetworkImageProvider(product.imageUrl),
        navigatorKey.currentContext!,
      );
    }
  }
}

class DatabaseService {
  static Database? _database;

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'catalog.db');
    _database = await openDatabase(
      path,
      version: 6, // Увеличиваем версию
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY,
            name TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE subcategories (
            id INTEGER PRIMARY KEY,
            name TEXT,
            category_id INTEGER
          )
        ''');
        db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY,
            name TEXT,
            image_url TEXT,
            category_id INTEGER,
            subcategory_id INTEGER,
            barcode TEXT,
            article TEXT,
            desc TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (newVersion == 6) {
          db.execute('ALTER TABLE products ADD COLUMN subcategory_id INTEGER');
        }
      },
    );
  }

  static Future<bool> hasData() async {
    final categoriesCount = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM categories'));
    return categoriesCount! > 0;
  }

  static Future<void> insertCategories(List<dynamic> categoriesJson) async {
    final categories = categoriesJson.map((c) {
      final cat = Category.fromJson(c);
      return {'id': cat.id, 'name': cat.name};
    }).toList();
    final batch = _database!.batch();
    for (var category in categories) {
      batch.insert('categories', category,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  static Future<void> insertSubCategories(
      List<dynamic> subCategoriesJson) async {
    final subCategories = subCategoriesJson.map((sc) {
      final subCat = SubCategory.fromJson(sc);
      return {
        'id': subCat.id,
        'name': subCat.name,
        'category_id':
            subCat.categoryId // Используйте корректное имя поля здесь
      };
    }).toList();
    final batch = _database!.batch();
    for (var subCategory in subCategories) {
      batch.insert('subcategories', subCategory,
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit();
  }

  static Future<int> updateProducts(List<dynamic> productsJson) async {
    int addedProducts = 0;
    final batch = _database!.batch();
    for (var productJson in productsJson) {
      final product = Product.fromJson(productJson);
      final productMap = product.toJson();

      final existingProduct = await _database!
          .rawQuery('SELECT * FROM products WHERE id = ?', [productMap['id']]);
      if (existingProduct.isEmpty) {
        addedProducts++;
      }

      batch.rawInsert('''
      INSERT OR REPLACE INTO products
      (id, name, image_url, category_id, subcategory_id, barcode, article, desc)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
        productMap['id'],
        productMap['name'],
        productMap['image_url'],
        productMap['category_id'],
        productMap['subcategory_id'], // Добавьте подкатегорию
        productMap['barcode'],
        productMap['article'],
        productMap['desc'],
      ]);
    }

    await batch.commit();
    return addedProducts;
  }

  static Future<List<Category>> getCategories() async {
    final List<Map<String, dynamic>> maps =
        await _database!.query('categories');
    return List.generate(maps.length, (i) => Category.fromJson(maps[i]));
  }

  static Future<List<SubCategory>> getSubCategories() async {
    final List<Map<String, dynamic>> maps =
        await _database!.query('subcategories');
    return List.generate(maps.length, (i) => SubCategory.fromJson(maps[i]));
  }

  static Future<List<SubCategory>> getSubCategoriesByCategoryId(
      int categoryId) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
        'subcategories',
        where: 'category_id = ?',
        whereArgs: [categoryId]);
    return List.generate(maps.length, (i) => SubCategory.fromJson(maps[i]));
  }

  static Future<List<Product>> getProductsByCategoryId(int categoryId) async {
    final List<Map<String, dynamic>> maps = await _database!
        .query('products', where: 'category_id = ?', whereArgs: [categoryId]);
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  static Future<List<Product>> getProductsBySubCategoryId(
      int subCategoryId) async {
    final List<Map<String, dynamic>> maps = await _database!.query('products',
        where: 'subcategory_id = ?', whereArgs: [subCategoryId]);
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  static Future<int> deleteNonExistingProducts(
      List<dynamic> productsJson) async {
    final productIds = productsJson.map((p) => p['id']).toList();
    final deleted = await _database!
        .delete('products', where: 'id NOT IN (${productIds.join(",")})');
    return deleted;
  }

  static Future<Product?> getProductByBarcode(String barcode) async {
    if (_database == null) {
      return null; // или можно выбросить исключение, если это неожиданное состояние
    }

    final List<Map<String, dynamic>> maps = await _database!
        .query('products', where: 'barcode = ?', whereArgs: [barcode]);

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }

    return null;
  }
}

class BarcodeService {
  static Future<String?> scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      return result.rawContent;
    } catch (e) {
      print('Error scanning barcode: $e');
      return null;
    }
  }
}
