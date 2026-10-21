import 'package:flutter/material.dart';

import 'pages/store_page.dart';
import 'services/product_service.dart';

void main() => runApp(const UtsStoreApp());

class UtsStoreApp extends StatelessWidget {
  const UtsStoreApp({super.key, this.service});
  final ProductService? service;

  @override
  Widget build(BuildContext context) {
    const scheme = ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black,
      onSecondary: Colors.white,
      primaryContainer: Color(0xFFE8E8E8),
      onPrimaryContainer: Colors.black,
      secondaryContainer: Color(0xFFE8E8E8),
      onSecondaryContainer: Colors.black,
      tertiary: Colors.black,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE8E8E8),
      onTertiaryContainer: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Color(0xFF555555),
      outline: Color(0xFF888888),
      outlineVariant: Color(0xFFDDDDDD),
      surfaceContainerHighest: Color(0xFFEEEEEE),
      surfaceContainerHigh: Color(0xFFF2F2F2),
      surfaceContainer: Color(0xFFF5F5F5),
      surfaceContainerLow: Color(0xFFF8F8F8),
      surfaceContainerLowest: Colors.white,
      surfaceTint: Colors.transparent,
      error: Colors.black,
      onError: Colors.white,
      errorContainer: Color(0xFFEEEEEE),
      onErrorContainer: Colors.black,
      inverseSurface: Colors.black,
      onInverseSurface: Colors.white,
      inversePrimary: Colors.white,
    );
    return MaterialApp(
      title: 'MONO — UTS Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFE8E8E8),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
          ),
        ),
      ),
      home: StorePage(service: service),
    );
  }
}
