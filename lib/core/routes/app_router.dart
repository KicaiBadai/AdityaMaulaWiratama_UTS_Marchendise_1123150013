// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:backend_firebase/core/guards/auth_guard.dart';
import 'package:backend_firebase/features/auth/data/presentation/pages/login_page.dart';
import 'package:backend_firebase/features/auth/data/presentation/pages/register_page.dart';
import 'package:backend_firebase/features/auth/data/presentation/pages/verify_email_page.dart';
import 'package:backend_firebase/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:backend_firebase/core/pages/splash_page.dart';

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
      case products:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: DashboardPage()),
        );
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
