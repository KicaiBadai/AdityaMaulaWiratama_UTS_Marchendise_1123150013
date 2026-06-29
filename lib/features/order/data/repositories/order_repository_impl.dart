// features/order/data/repositories/order_repository_impl.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/order_model.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dioClient = DioClient.instance; // ✅ Perbaikan: tipe Dio

  @override
  Future<OrderModel> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    try {
      debugPrint('[OrderRepositoryImpl] POST request to ${ApiConstants.checkout} with body: '
          '{ shipping_address: $shippingAddress, notes: ${notes ?? ""}, payment_method: $paymentMethod }');
      final Response response = await _dioClient.post(
        ApiConstants.checkout,
        data: {
          'shipping_address': shippingAddress,
          'notes': notes ?? '',
          'payment_method': paymentMethod,
        },
      );
      debugPrint('[OrderRepositoryImpl] POST response from ${ApiConstants.checkout}: ${response.data}');
      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } catch (e) {
      debugPrint('[OrderRepositoryImpl] Checkout error: $e');
      throw Exception('Checkout failed: $e');
    }
  }

  @override
  Future<List<OrderModel>> getMyOrders({int page = 1, int limit = 10}) async {
    try {
      debugPrint('[OrderRepositoryImpl] GET request to ${ApiConstants.orders} with query: { page: $page, limit: $limit }');
      final Response response = await _dioClient.get(
        ApiConstants.orders,
        queryParameters: {'page': page, 'limit': limit},
      );
      debugPrint('[OrderRepositoryImpl] GET response from ${ApiConstants.orders}: ${response.data}');
      final List<dynamic> data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('[OrderRepositoryImpl] Failed to load orders error: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderDetail(int orderId) async {
    try {
      final url = '${ApiConstants.orders}/$orderId';
      debugPrint('[OrderRepositoryImpl] GET request to $url');
      final Response response = await _dioClient.get(url);
      debugPrint('[OrderRepositoryImpl] GET response from $url: ${response.data}');
      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>;
      return OrderModel.fromJson(data);
    } catch (e) {
      debugPrint('[OrderRepositoryImpl] Failed to load order detail error: $e');
      throw Exception('Failed to load order detail: $e');
    }
  }
}
