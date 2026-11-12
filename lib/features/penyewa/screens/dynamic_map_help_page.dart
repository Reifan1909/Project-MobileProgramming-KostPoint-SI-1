import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Halaman penjelasan langkah-langkah cara kerja pencarian peta dinamis.
class DynamicMapHelpPage extends StatelessWidget {
  const DynamicMapHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Cara Kerja Pencarian Peta Dinamis',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Halaman penjelasan fitur pencarian peta dinamis akan segera tersedia.',
          style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}