import 'package:flutter/material.dart';
import 'package:uts_1123150013/features/order/data/models/order_model.dart';
import 'package:uts_1123150013/features/order/data/repositories/order_repository_impl.dart';
import 'package:uts_1123150013/features/order/domain/repositories/order_repository.dart';

enum OrderStatus { initial, loading, success, error }

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository = OrderRepositoryImpl();

  // State untuk checkout
  OrderStatus _checkoutStatus = OrderStatus.initial;
  OrderModel? _lastOrder;
  String? _checkoutError;

  // State untuk daftar pesanan
  List<OrderModel> _orders = [];
  OrderStatus _ordersStatus = OrderStatus.initial;
  String? _ordersError;

  // Getters
  OrderStatus get checkoutStatus => _checkoutStatus;
  OrderModel? get lastOrder => _lastOrder;

  /// Getter error untuk kompatibilitas dengan kode dosen
  String? get error => _checkoutError; // ← tambahkan ini!

  String? get checkoutError => _checkoutError;

  List<OrderModel> get orders => _orders;
  OrderStatus get ordersStatus => _ordersStatus;
  String? get ordersError => _ordersError;

  // Method checkout (sudah ada)
  Future<bool> checkout({
    required String shippingAddress,
    String? notes,
    required String paymentMethod,
  }) async {
    _checkoutStatus = OrderStatus.loading;
    _checkoutError = null;
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
      _checkoutError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Method untuk mengambil daftar pesanan (dipanggil dari MyOrdersPage)
  Future<void> fetchMyOrders({int page = 1, int limit = 10}) async {
    _ordersStatus = OrderStatus.loading;
    _ordersError = null;
    notifyListeners();

    try {
      _orders = await _repository.getMyOrders(page: page, limit: limit);
      _ordersStatus = OrderStatus.success;
    } catch (e) {
      _ordersStatus = OrderStatus.error;
      _ordersError = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Method untuk detail order (opsional)
  Future<OrderModel?> getOrderDetail(int orderId) async {
    try {
      return await _repository.getOrderDetail(orderId);
    } catch (e) {
      _ordersError = e.toString();
      notifyListeners();
      return null;
    }
  }

  void resetCheckout() {
    _checkoutStatus = OrderStatus.initial;
    _lastOrder = null;
    _checkoutError = null;
    notifyListeners();
  }
}
