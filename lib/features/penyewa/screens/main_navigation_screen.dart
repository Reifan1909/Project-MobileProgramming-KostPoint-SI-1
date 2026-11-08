import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pemilik/screens/dashboard_pemilik_screen.dart';
import '../providers/katalog_provider.dart';
import 'favorit_screen.dart';
import 'katalog_screen.dart';
import 'map_search_screen.dart';
import 'profil_screen.dart';

/// Layar Utama dengan Menu Bar Bawah (Bottom Navigation Bar).
/// Secara dinamis menyesuaikan menu: Penyewa memiliki 'Favorit', Pemilik memiliki 'Kos Saya'.
class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KatalogProvider>();
    final auth = context.watch<AuthProvider>();
    final currentIndex = provider.selectedNavIndex;
    final isOwner = auth.isPemilik;

    final screens = [
      const KatalogScreen(),
      const MapSearchScreen(),
      isOwner ? const DashboardPemilikScreen() : const FavoritScreen(),
      const ProfilScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
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
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppColors.textSecondaryMuted),
              selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primaryAccent),
              label: 'Katalog',
            ),
            const NavigationDestination(
              icon: Icon(Icons.map_outlined, color: AppColors.textSecondaryMuted),
              selectedIcon: Icon(Icons.map_rounded, color: AppColors.primaryAccent),
              label: 'Peta Lokasi',
            ),
            isOwner
                ? const NavigationDestination(
                    icon: Icon(Icons.storefront_outlined, color: AppColors.textSecondaryMuted),
                    selectedIcon: Icon(Icons.storefront_rounded, color: AppColors.primaryAccent),
                    label: 'Kos Saya',
                  )
                : const NavigationDestination(
                    icon: Icon(Icons.bookmark_outline_rounded, color: AppColors.textSecondaryMuted),
                    selectedIcon: Icon(Icons.bookmark_rounded, color: AppColors.primaryAccent),
                    label: 'Favorit',
                  ),
            const NavigationDestination(
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

