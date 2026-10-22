import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/product_service.dart';
import 'state/favorites_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KatalogKuApp());
}

class KatalogKuApp extends StatefulWidget {
  const KatalogKuApp({super.key, this.service, this.favorites});
  final ProductService? service;
  final FavoritesController? favorites;

  @override
  State<KatalogKuApp> createState() => _KatalogKuAppState();
}

class _KatalogKuAppState extends State<KatalogKuApp> {
  late final ProductService _service;
  late final FavoritesController _favorites;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ProductService();
    _favorites = widget.favorites ?? FavoritesController();
  }

  @override
  void dispose() {
    if (widget.service == null) _service.dispose();
    if (widget.favorites == null) _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE0E0E0),
      onPrimaryContainer: Colors.black,
      secondary: Colors.black,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFE8E8E8),
      onSecondaryContainer: Colors.black,
      tertiary: Colors.black,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE0E0E0),
      onTertiaryContainer: Colors.black,
      surface: Colors.white,
      onSurface: Colors.black,
      onSurfaceVariant: Color(0xFF444444),
      surfaceContainerHighest: Color(0xFFEEEEEE),
      outline: Color(0xFF777777),
      outlineVariant: Color(0xFFDDDDDD),
      error: Colors.black,
      onError: Colors.white,
      errorContainer: Color(0xFFEEEEEE),
      onErrorContainer: Colors.black,
      inverseSurface: Color(0xFF222222),
      onInverseSurface: Colors.white,
      inversePrimary: Colors.white,
      surfaceTint: Colors.transparent,
    );
    return MaterialApp(
      title: 'KatalogKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFE0E0E0),
          surfaceTintColor: Colors.transparent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F5F5),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: HomeScreen(service: _service, favorites: _favorites),
    );
  }
}
