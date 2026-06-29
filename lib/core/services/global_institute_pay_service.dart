import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

class PaymentCallbackData {
  final String status; // 'success', 'failed', 'cancelled'
  final String? reference; // e.g. INV-123
  final String? transactionId; // ID dari dompet kampus

  const PaymentCallbackData({
    required this.status,
    this.reference,
    this.transactionId,
  });

  bool get isSuccess => status == 'success';
  bool get isCancelled => status == 'cancelled';
  bool get isFailed => status == 'failed';
}

class GlobalInstitutePayService {
  static final GlobalInstitutePayService _instance = GlobalInstitutePayService._();

  factory GlobalInstitutePayService() => _instance;

  GlobalInstitutePayService._();

  final _callbackController = StreamController<PaymentCallbackData>.broadcast();
  Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

  PaymentCallbackData? _pendingCallback;

  PaymentCallbackData? consumePendingCallback() {
    final data = _pendingCallback;
    _pendingCallback = null; // Consume once
    if (data != null) {
      debugPrint('[GlobalInstitutePayService] Pending callback consumed: status=${data.status}, ref=${data.reference}');
    }
    return data;
  }

  Future<void> init() async {
    debugPrint('[GlobalInstitutePayService] Initializing service...');
    final appLinks = AppLinks();

    // 1. Cold start check
    try {
      final uri = await appLinks.getInitialLink();
      if (uri != null) {
        debugPrint('[GlobalInstitutePayService] App launched via deep link: $uri');
        _handleUri(uri, isColdStart: true);
      }
    } catch (e) {
      debugPrint('[GlobalInstitutePayService] Error getting initial link: $e');
    }

    // 2. In-app hot start listener
    appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint('[GlobalInstitutePayService] Received deep link stream: $uri');
        _handleUri(uri);
      },
      onError: (err) {
        debugPrint('[GlobalInstitutePayService] Stream error: $err');
      },
    );
  }

  void _handleUri(Uri uri, {bool isColdStart = false}) {
    debugPrint('[GlobalInstitutePayService] Handling URI: scheme=${uri.scheme}, host=${uri.host}');
    debugPrint('[GlobalInstitutePayService] Cold start: $isColdStart');

    if (uri.scheme == 'pasarmalam' && uri.host == 'payment-callback') {
      final params = uri.queryParameters;
      debugPrint('[GlobalInstitutePayService] Callback params: $params');

      final data = PaymentCallbackData(
        status: params['status'] ?? 'unknown',
        reference: params['reference'],
        transactionId: params['transaction_id'],
      );

      if (isColdStart) {
        _pendingCallback = data;
      }

      _callbackController.add(data);
    } else {
      debugPrint('[GlobalInstitutePayService] Ignored non-callback URI');
    }
  }

  static String buildDeeplinkUrl({
    required int orderId,
    required double amount,
    String? description,
  }) {
    final uri = Uri(
      scheme: 'dompetkampus',
      host: 'pay',
      queryParameters: {
        'merchant_id': 'MCH_PASAR_MALAM',
        'merchant_name': 'Pasar Malam',
        'amount': amount.toInt().toString(),
        'description': (description != null && description.isNotEmpty)
            ? description
            : 'Order #$orderId',
        'reference': 'INV-$orderId',
        'callback': 'pasarmalam://payment-callback',
      },
    );
    final urlStr = uri.toString();
    debugPrint('[GlobalInstitutePayService] Generated outgoing deeplink: $urlStr');
    return urlStr;
  }
}
