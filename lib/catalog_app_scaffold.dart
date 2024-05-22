import 'package:flutter/material.dart';
import 'package:catalog_app/services.dart';
import 'package:catalog_app/models.dart';
import 'screens/product_details_screen.dart';

class CatalogAppScaffold extends StatelessWidget {
  final Widget child;
  final String appBarTitle;

  CatalogAppScaffold({required this.child, required this.appBarTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner),
            onPressed: () async {
              String? barcode = await BarcodeService.scanBarcode();
              if (barcode != null) {
                Product? product =
                    await DatabaseService.getProductByBarcode(barcode);
                if (product != null) {
                  Navigator.push(
                    context,
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
