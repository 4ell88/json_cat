import 'package:flutter/material.dart';
import 'package:catalog_app/models.dart';
import 'package:catalog_app/services.dart'; // Добавьте этот импорт

class SubcategoriesScreen extends StatelessWidget {
  final List<SubCategory> subcategories;

  SubcategoriesScreen({required this.subcategories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subcategories'),
      ),
      body: ListView.builder(
        itemCount: subcategories.length,
        itemBuilder: (context, index) {
          final subcategory = subcategories[index];
          return ListTile(
            title: Text(subcategory.name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      SubcategoryListScreen(subcategoryId: subcategory.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class SubcategoryListScreen extends StatelessWidget {
  final int subcategoryId;

  SubcategoryListScreen({required this.subcategoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products for Subcategory $subcategoryId'),
      ),
      body: FutureBuilder<List<Product>>(
        future: DatabaseService.getProductsBySubCategoryId(subcategoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading products'));
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final product = snapshot.data![index];
                return ListTile(
                  title: Text(product.name),
                  // Добавьте сюда дополнительную логику для навигации или отображения деталей продукта
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
