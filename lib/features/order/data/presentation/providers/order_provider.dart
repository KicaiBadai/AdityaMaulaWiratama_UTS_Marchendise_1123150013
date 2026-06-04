import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uts_1123150013/features/order/data/models/order_model.dart';
import 'package:uts_1123150013/features/order/data/repositories/order_repository_impl.dart';
import 'package:uts_1123150013/features/order/domain/repositories/order_repository.dart';

enum OrderStatus { initial, loading, success, error }

// Enum untuk status pengecekan pembayaran
enum PaymentCheckStatus { idle, checking, paid }

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

  // State untuk polling pembayaran
  PaymentCheckStatus _paymentCheckStatus = PaymentCheckStatus.idle;
  Timer? _paymentPollingTimer;

  // Getters
  OrderStatus get checkoutStatus => _checkoutStatus;
  OrderModel? get lastOrder => _lastOrder;
  String? get error => _checkoutError;
  String? get checkoutError => _checkoutError;

  List<OrderModel> get orders => _orders;
  OrderStatus get ordersStatus => _ordersStatus;
  String? get ordersError => _ordersError;

  PaymentCheckStatus get paymentCheckStatus => _paymentCheckStatus;

  // ============= METHOD CHECKOUT =============
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

  // ============= METHOD DAFTAR PESANAN =============
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

  // ============= METHOD DETAIL ORDER =============
  Future<OrderModel?> getOrderDetail(int orderId) async {
    try {
      return await _repository.getOrderDetail(orderId);
    } catch (e) {
      _ordersError = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ============= METHOD POLLING PEMBAYARAN =============
  void startPaymentPolling(int orderId) {
    _paymentPollingTimer?.cancel();
    _paymentCheckStatus = PaymentCheckStatus.idle;
    notifyListeners();

    _paymentPollingTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      await checkPaymentStatus(orderId);
    });
  }

  void stopPaymentPolling() {
    _paymentPollingTimer?.cancel();
    _paymentPollingTimer = null;
    _paymentCheckStatus = PaymentCheckStatus.idle;
    notifyListeners();
  }

  Future<void> checkPaymentStatus(int orderId) async {
    if (_paymentCheckStatus == PaymentCheckStatus.paid) return;

    _paymentCheckStatus = PaymentCheckStatus.checking;
    notifyListeners();

    try {
      final updatedOrder = await _repository.getOrderDetail(orderId);
      // Sesuaikan kondisi status 'paid' atau 'delivered' dengan API Anda
      if (updatedOrder.status == 'paid' ||
          updatedOrder.status == 'delivered' ||
          updatedOrder.status == 'processing') {
        _paymentCheckStatus = PaymentCheckStatus.paid;
        _lastOrder = updatedOrder; // update order terakhir
        stopPaymentPolling(); // hentikan polling karena sudah sukses
      } else {
        _paymentCheckStatus = PaymentCheckStatus.idle;
      }
    } catch (e) {
      _paymentCheckStatus = PaymentCheckStatus.idle;
    }
    notifyListeners();
  }

  // ============= RESET CHECKOUT =============
  void resetCheckout() {
    _checkoutStatus = OrderStatus.initial;
    _lastOrder = null;
    _checkoutError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPaymentPolling();
    super.dispose();
  }
}
