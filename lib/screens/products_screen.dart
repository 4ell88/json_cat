import 'package:flutter/material.dart';
import 'package:catalog_app/models.dart';
import 'package:catalog_app/services.dart';
import 'package:catalog_app/screens/product_details_screen.dart';
import 'dart:convert';

class ProductsScreen extends StatefulWidget {
  final Category category;

  ProductsScreen({required this.category});

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late Future<List<Product>> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts =
        DatabaseService.getProductsByCategoryId(widget.category.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utf8Codec().decode(widget.category.name.runes.toList())),
      ),
      body: FutureBuilder<List<Product>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    Utf8Codec()
                        .decode(snapshot.data![index].name.runes.toList()),
                    style: TextStyle(fontFamily: 'Roboto'),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailsScreen(
                          product: snapshot.data![index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
