import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:catalog_app/models.dart';
import 'dart:convert';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  ProductDetailsScreen({required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Utf8Codec().decode(product.name.runes.toList())),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: product.imageUrl.isEmpty
                ? Icon(Icons
                    .error) // Добавьте иконку или виджет по умолчанию, если URL пуст
                : CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.error),
                        SizedBox(height: 10),
                        Text('Failed to load image'),
                      ],
                    ),
                  ),
          ),
          Text(
            Utf8Codec().decode(product.name.runes.toList()),
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
