import 'package:flutter/material.dart';
import 'package:catalog_app/models.dart';
import 'package:catalog_app/services.dart';
import 'package:catalog_app/screens/products_screen.dart';
import 'package:catalog_app/screens/SubcategoryListScreen.dart'; // новый импорт

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = DatabaseService.getCategories();
    futureCategories.then((value) {
      print("Categories: $value");
      for (var category in value) {
        print(
            "Category ${category.name} has ${category.subcategories.length} subcategories.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data![index].name),
                onTap: () {
                  if (snapshot.data![index].subcategories.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubcategoriesScreen(
                          subcategories: snapshot.data![index].subcategories,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductsScreen(
                          category: snapshot.data![index],
                        ),
                      ),
                    );
                  }
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
    );
  }
}
