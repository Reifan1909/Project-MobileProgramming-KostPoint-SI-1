import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/katalog_provider.dart';
import 'favorit_screen.dart';
import 'katalog_screen.dart';
import 'map_search_screen.dart';
import 'profil_screen.dart';

/// Layar Utama dengan Menu Bar Bawah (Bottom Navigation Bar).
/// Memisahkan menu Katalog, Peta Lokasi, Favorit, dan Profil secara modular.
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _screens = [
    KatalogScreen(),
    MapSearchScreen(),
    FavoritScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final currentIndex = provider.selectedNavIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.cardSurface,
          border: Border(
            top: BorderSide(color: AppColors.surfaceBorderSoft, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            provider.setNavIndex(index);
          },
          backgroundColor: AppColors.cardSurface,
          indicatorColor: AppColors.primaryAccent.withValues(alpha: 0.18),
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppColors.textSecondaryMuted),
              selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primaryAccent),
              label: 'Katalog',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppColors.textSecondaryMuted),
              selectedIcon: Icon(Icons.map_rounded, color: AppColors.primaryAccent),
              label: 'Peta Lokasi',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded, color: AppColors.textSecondaryMuted),
              selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primaryAccent),
              label: 'Favorit',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondaryMuted),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryAccent),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

