import 'package:flutter/material.dart';
import 'package:catalog_app/services.dart';
import 'product_details_screen.dart';

class BarcodeSearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Search'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final barcode = await BarcodeService.scanBarcode();
            if (barcode != null) {
              final product =
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
          child: Text('Scan Barcode'),
        ),
      ),
    );
  }
}
