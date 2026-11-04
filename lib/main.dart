import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/penyewa/providers/katalog_provider.dart';
import 'features/penyewa/screens/main_navigation_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KostPointApp());
}

/// Root Application Bootstrap untuk Kost Point Mobile.
/// Berjalan langsung ke Halaman Beranda Utama dengan Menu Bar Bawah (Mode Guest).
class KostPointApp extends StatelessWidget {
  const KostPointApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KatalogProvider()),
      ],
      child: MaterialApp(
        title: 'Kost Point',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
