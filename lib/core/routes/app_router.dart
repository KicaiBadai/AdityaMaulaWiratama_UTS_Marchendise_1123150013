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
import 'package:uts_1123150013/features/order/data/presentation/pages/order_success_page.dart';
import 'package:uts_1123150013/features/order/data/presentation/pages/payment_pending_page.dart';
import 'package:uts_1123150013/features/order/data/models/order_model.dart';

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

  // Order Routes
  static const String myOrders = '/my-orders';

  // Order / Checkout
  static const String checkout = '/checkout';
  static const String paymentPending = '/payment-pending';
  static const String orderSuccess = '/order-success';

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
      case paymentPending:
        final order = settings.arguments as OrderModel?;
        if (order == null) {
          // Fallback ke dashboard jika tidak ada argumen
          return MaterialPageRoute(
            builder: (_) => const AuthGuard(child: DashboardPage()),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: PaymentPendingPage(order: order)),
        );
      case orderSuccess:
        final order = settings.arguments as OrderModel?;
        if (order == null) {
          return MaterialPageRoute(
            builder: (_) => const AuthGuard(child: DashboardPage()),
          );
        }
        return MaterialPageRoute(
          builder: (_) => AuthGuard(child: OrderSuccessPage(order: order)),
        );
      case products:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );
      case cart:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: CartPage()),
        );
      case checkout:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: CheckoutPage()),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
