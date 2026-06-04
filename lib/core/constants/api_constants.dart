class ApiConstants {
  // 🔥 Kalau backend dan Flutter SAMA-SAMA di Windows:
  static const String baseUrl = 'http://localhost:8080'; // ← Ganti ke localhost

  // ATAU kalau memang mau pakai IP (untuk testing dari HP):
  // static const String baseUrl = 'http://192.168.0.28:8080';

  // Auth endpoints (tanpa /v1 karena sudah tidak perlu)
  static const String verifyToken = '/v1/auth/verify-token';

  // Product endpoints
  static const String products = '/v1/products';

  // Timeout (naikkan sedikit)
  static const int connectTimeout = 30000; // 30 detik
  static const int receiveTimeout = 30000; // 30 detik
  static const String cart = '/v1/cart';
  static const String checkout = '/v1/orders/checkout';
  static const String orders = '/v1/orders';
}

