// features/cart/presentation/providers/cart_provider.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/cart_repository_impl.dart';
import '../../../domain/repositories/cart_repository.dart';
import '../../models/cart_model.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepository _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;
  bool _isAdding = false;

  // Getters
  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get error => _error;
  bool get isAdding => _isAdding;
  int get itemCount => _cart?.itemCount ?? 0;

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    notifyListeners();

    try {
      _cart = await _repository.getCart();
      _status = CartStatus.loaded;
      _error = null;
    } catch (e) {
      _status = CartStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    notifyListeners();

    try {
      await _repository.addToCart(productId, quantity);
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isAdding = false;
      notifyListeners();
    }
  }

  Future<bool> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);
      await fetchCart();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> clearCart() async {
    await _repository.clearCart();
    // Langsung set ke kosong tanpa fetch ulang
    _cart = CartModel(items: [], total: 0, itemCount: 0);
    _status = CartStatus.loaded;
    _error = null;
    notifyListeners();
  }
}
