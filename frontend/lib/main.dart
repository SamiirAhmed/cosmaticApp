import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samiir/screens/auth/splash_screen.dart';
import 'core/constants/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'providers/product_provider.dart';
import 'providers/user_provider.dart';
import 'providers/order_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProductProvider()..fetchProducts(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const SamiirApp(),
    ),
  );
}


class SamiirApp extends StatelessWidget {
  const SamiirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Samiir',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
