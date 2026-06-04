// features/cart/domain/repositories/cart_repository.dart
import '../../data/models/cart_model.dart';

abstract class CartRepository {
  Future<CartModel> getCart();
  Future<void> addToCart(int productId, int quantity);
  Future<void> updateCartItem(int cartItemId, int quantity);
  Future<void> removeCartItem(int cartItemId);
  Future<void> clearCart();
}
