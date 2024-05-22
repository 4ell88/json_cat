import 'package:flutter/material.dart';
import 'package:catalog_app/screens/splash_screen.dart';
import 'package:catalog_app/screens/categories_screen.dart';
import 'package:catalog_app/screens/products_screen.dart';
import 'package:catalog_app/services.dart';
import 'package:catalog_app/models.dart';
import 'package:catalog_app/screens/product_details_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity/connectivity.dart';

void main() {
  initServices();
  runApp(CatalogApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initServices() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();

  var connectivityResult = await Connectivity().checkConnectivity();

  if (!await DatabaseService.hasData() &&
      connectivityResult == ConnectivityResult.none) {
    throw Exception('No internet connection and no data in the database');
  }

  try {
    await ApiService.syncDataWithDatabase();
    var catalogData = await ApiService.fetchCatalogData();
    if (catalogData != null &&
        catalogData.containsKey('categories') &&
        catalogData.containsKey('products')) {
      for (var category in (catalogData['categories'] as List)
          .whereType<Map<String, dynamic>>()) {
        String? imageUrl = category['image_url'] as String?;
        if (imageUrl != null) {
          precacheImage(CachedNetworkImageProvider(imageUrl),
              navigatorKey.currentContext!);
        }
      }
      for (var product in (catalogData['products'] as List)
          .whereType<Map<String, dynamic>>()) {
        String? imageUrl = product['image_url'] as String?;
        if (imageUrl != null) {
          precacheImage(CachedNetworkImageProvider(imageUrl),
              navigatorKey.currentContext!);
        }
      }
    }
  } catch (e) {
    print("Unable to fetch data: $e");
    if (!(await DatabaseService.hasData())) {
      throw Exception('No internet connection and no data in the database');
    }
  }
}

class CatalogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Dovgan Catalog',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 207, 6, 6),
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CatalogAppScaffold(child: SplashScreen()),
      routes: {
        '/categories': (context) => CatalogAppScaffold(
              child: CategoriesScreen(),
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/products' && settings.arguments is Category) {
          final Category category = settings.arguments as Category;
          return MaterialPageRoute(
            builder: (context) => CatalogAppScaffold(
              child: ProductsScreen(category: category),
            ),
          );
        }
        return null;
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''), // English, no country code
        const Locale('de', ''), // German, no country code
      ],
    );
  }
}

class CatalogAppScaffold extends StatelessWidget {
  final Widget child;

  CatalogAppScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Image.asset(
            'lib/assets/images/logo.png',
            fit: BoxFit.contain,
            height: 32,
          ),
        ),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              String? barcode = await BarcodeService.scanBarcode();
              if (barcode != null) {
                Product? product =
                    await DatabaseService.getProductByBarcode(barcode);
                if (product != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          ProductDetailsScreen(product: product),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Product not found')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: child,
    );
  }
}
