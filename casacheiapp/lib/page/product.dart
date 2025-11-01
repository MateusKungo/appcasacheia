// lib/page/product.dart
class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final int stock;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.stock,
    required this.description,
  });
}