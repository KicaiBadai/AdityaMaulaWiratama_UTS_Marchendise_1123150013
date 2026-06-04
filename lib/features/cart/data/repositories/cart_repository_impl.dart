// features/cart/data/repositories/cart_repository_impl.dart
import 'package:dio/dio.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/cart_model.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final Dio _dioClient = DioClient.instance; // ✅ Diperbaiki: tipe Dio

  @override
  Future<CartModel> getCart() async {
    try {
      final Response response = await _dioClient.get(ApiConstants.cart);
      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>;
      return CartModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch cart: $e');
    }
  }

  @override
  Future<void> addToCart(int productId, int quantity) async {
    try {
      await _dioClient.post(
        ApiConstants.cart,
        data: {'product_id': productId, 'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to add to cart: $e');
    }
  }

  @override
  Future<void> updateCartItem(int cartItemId, int quantity) async {
    try {
      await _dioClient.put(
        '${ApiConstants.cart}/$cartItemId',
        data: {'quantity': quantity},
      );
    } catch (e) {
      throw Exception('Failed to update cart item: $e');
    }
  }

  @override
  Future<void> removeCartItem(int cartItemId) async {
    try {
      await _dioClient.delete('${ApiConstants.cart}/$cartItemId');
    } catch (e) {
      throw Exception('Failed to remove cart item: $e');
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _dioClient.delete(ApiConstants.cart);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}
