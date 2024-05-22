import 'package:flutter/material.dart';
import '../services.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    await DatabaseService.init();
    if (!await DatabaseService.hasData()) {
      await ApiService.syncDataWithDatabase();
    }
    fetchAndUpdateData().then((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/categories');
      }
    });
  }

  Future<void> fetchAndUpdateData() async {
    final catalogData = await ApiService.fetchCatalogData();
    if (catalogData != null) {
      final products = catalogData['products'] as List<dynamic>;

      final addedProducts = await DatabaseService.updateProducts(products);
      final deletedProducts =
          await DatabaseService.deleteNonExistingProducts(products);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Добавлено новых товаров: $addedProducts, удалено товаров: $deletedProducts'),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось обновить данные каталога'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
