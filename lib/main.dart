import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import file lokal (sesuaikan path jika berbeda)
import 'firebase_options.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/presentation/providers/auth_provider.dart';
import 'features/dashboard/domain/repositories/product_provider.dart';
import 'core/providers/theme_provider.dart'; // Pastikan path ini benar
import 'features/order/data/presentation/providers/order_provider.dart';
import 'features/cart/data/presentation/providers/cart_provider.dart';

import 'core/services/global_institute_pay_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Deep Link Service
  await GlobalInstitutePayService().init();

  // Inisialisasi Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch ThemeProvider agar widget build ulang saat tema berubah
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Pasar Malam',
      debugShowCheckedModeBanner: false,

      // Pengaturan Tema
      theme: AppTheme.light, // Tema Terang
      darkTheme: AppTheme.dark, // Tema Gelap
      themeMode: themeProvider.themeMode, // Mode aktif (Light/Dark)
      // Pengaturan Navigasi
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
