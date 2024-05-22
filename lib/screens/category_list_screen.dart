import 'package:flutter/material.dart';
import 'package:catalog_app/services.dart';
import 'package:catalog_app/models.dart';
import '../catalog_app_scaffold.dart';
import 'product_list_screen.dart';

class CategoryListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CatalogAppScaffold(
      appBarTitle: 'Categories',
      child: FutureBuilder<List<Category>>(
        future: DatabaseService.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error loading categories'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, categoryIndex) {
                final category = snapshot.data![categoryIndex];
                return ExpansionTile(
                  title: Text(category.name),
                  children: category.subcategories.map((subCategory) {
                    return ListTile(
                      title: Text(subCategory.name),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductListScreen(categoryId: subCategory.id),
                          ),
                        );
                      },
                    );
                  }).toList(),
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
