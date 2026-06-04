// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:uts_1123150013/core/guards/auth_guard.dart';
import 'package:uts_1123150013/features/auth/data/presentation/pages/login_page.dart';
import 'package:uts_1123150013/features/auth/data/presentation/pages/register_page.dart';
import 'package:uts_1123150013/features/auth/data/presentation/pages/verify_email_page.dart';
import 'package:uts_1123150013/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:uts_1123150013/core/pages/splash_page.dart';
import 'package:uts_1123150013/features/cart/data/presentation/pages/cart_pages.dart';
import 'package:uts_1123150013/features/order/data/presentation/pages/checkout_page.dart';

class AppRouter {
  // Auth Routes
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';

  // Main Routes
  static const String splash = '/splash';
  static const String dashboard = '/dashboard';
  static const String home = '/home';
  static const String products = '/products';
  static const String productDetail = '/product-detail';

  // Bottom Navigation Routes
  static const String cart = '/cart';
  static const String favorite = '/favorite';
  static const String account = '/account';
  static const String profile = '/profile';

  // Order / Checkout
  static const String checkout = '/checkout'; // ✅ Tambahkan ini

   // Order / Checkout
  static const String paymentPending = '/payment-pending'; // ✅ tambah
  static const String orderSuccess = '/order-success'; // ✅ tambah

  // Settings
  static const String settings = '/settings';
  static const String about = '/about';

  // Helper method untuk route dengan parameter
  static String productDetailWithId(int id) => '$productDetail?id=$id';

  // onGenerateRoute untuk handling navigasi
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );
      case paymentPending: // ✅ tambah
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: PaymentPendingPage()),
        );  
      case orderSuccess: // ✅ tambah
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: OrderSuccessPage()),
        );
      case products:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );
      case checkout: // ✅ Tambahkan handling rute checkout
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(
            child: CheckoutPage(),
          ), // Ganti dengan widget halaman checkout Anda
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
