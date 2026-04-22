import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    // Simulate fetching products
    await Future.delayed(const Duration(seconds: 2));

    _products = [
      Product(
        id: '1',
        name: 'Product 1',
        description: 'Description 1',
        price: 10.0,
        imageUrl: 'https://via.placeholder.com/150',
      ),
      Product(
        id: '2',
        name: 'Product 2',
        description: 'Description 2',
        price: 20.0,
        imageUrl: 'https://via.placeholder.com/150',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }
}
