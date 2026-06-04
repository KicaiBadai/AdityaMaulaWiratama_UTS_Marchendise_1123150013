// features/order/presentation/providers/order_provider.dart
import 'package:flutter/material.dart';
import '../../../data/repositories/order_repository_impl.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../models/order_model.dart';

enum OrderStatus { initial, loading, success, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepositoryImpl();

  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderModel? _lastOrder;
  List<OrderModel> _orders = [];
  String? _error;

  // Getters
  OrderStatus get checkoutStatus => _checkoutStatus;
  OrderModel? get lastOrder => _lastOrder;
  List<OrderModel> get orders => _orders;
  String? get error => _error;

  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _checkoutStatus = OrderStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _lastOrder = await _repository.checkout(
        shippingAddress: shippingAddress,
        notes: notes,
        paymentMethod: paymentMethod,
      );
      _checkoutStatus = OrderStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _checkoutStatus = OrderStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadMyOrders({int page = 1, int limit = 10}) async {
    try {
      _orders = await _repository.getMyOrders(page: page, limit: limit);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<OrderModel?> loadOrderDetail(int orderId) async {
    try {
      final order = await _repository.getOrderDetail(orderId);
      return order;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void resetCheckout() {
    _checkoutStatus = OrderStatus.initial;
    _lastOrder = null;
    _error = null;
    notifyListeners();
  }
}
