class Category {
  final int id;
  final String name;
  final List<SubCategory> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.subcategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    print(
        'Deserializing Category with id: ${json['id']} and name: ${json['name']}');
    var subcatList = json['subcategories'] as List? ?? [];
    var parsedSubcategories = subcatList
        .map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
        .toList();

    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      subcategories: parsedSubcategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subcategories': subcategories.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'Category: {id: $id, name: $name, subcategories: $subcategories}';
  }
}

class SubCategory {
  final int id;
  final String name;
  final int categoryId;

  SubCategory({required this.id, required this.name, required this.categoryId});

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'], // Используйте правильный ключ здесь
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId, // При сериализации используйте snake_case
    };
  }

  @override
  String toString() {
    return 'SubCategory: {id: $id, name: $name, categoryId: $categoryId}';
  }
}

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final int categoryId;
  final String barcode;
  final String article;
  final String desc;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.categoryId,
    required this.barcode,
    required this.article,
    required this.desc,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['image_url'] != null
          ? json['image_url'] as String
          : 'default_image_url',
      categoryId: json['category_id'] != null ? json['category_id'] as int : 0,
      barcode: json['barcode'] as String,
      article: json['article'] as String,
      desc: json['desc'] != null ? json['desc'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'barcode': barcode,
      'article': article,
      'desc': desc,
    };
  }

  @override
  String toString() {
    return 'Product: {id: $id, name: $name, imageUrl: $imageUrl, categoryId: $categoryId, barcode: $barcode, article: $article, desc: $desc}';
  }
}
