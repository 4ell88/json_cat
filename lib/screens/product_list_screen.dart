import 'package:flutter/material.dart';
import 'package:catalog_app/services.dart';
import 'package:catalog_app/models.dart';
import 'package:catalog_app/catalog_app_scaffold.dart';
import 'package:catalog_app/screens/product_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListScreen extends StatelessWidget {
  final int categoryId;

  ProductListScreen({required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return CatalogAppScaffold(
      appBarTitle: 'Products',
      child: FutureBuilder<List<Product>>(
        future: DatabaseService.getProductsByCategoryId(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading products'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                print(
                    "Loading image for product: ${product.name}, url: ${product.imageUrl}");
                return Row(
                  children: [
                    Container(
                      width: 100, // Установите конкретный размер
                      height: 100, // Установите конкретный размер
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) {
                            print("Error loading image: $url, error: $error");
                            return Icon(Icons.error);
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 8), // Добавьте небольшой отступ
                    Expanded(
                      child: ListTile(
                        title: Text(
                          product.name,
                          style: TextStyle(fontFamily: 'Roboto'),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
