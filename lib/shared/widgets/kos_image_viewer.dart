import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Widget Universal untuk Menampilkan Foto Kos (Mendukung URL Online & File Lokal dari Galeri)
class KosImageViewer extends StatelessWidget {
  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  const KosImageViewer({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cleanPath = imagePath.trim();

    if (cleanPath.isEmpty) {
      return _buildPlaceholder();
    }

    // Jika berupa URL jaringan / web
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return Image.network(
        cleanPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.surfaceBorderSoft,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
      );
    }

    // Jika berupa file lokal perangkat (hasil upload galeri atau kamera)
    final file = File(cleanPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceBorderSoft,
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 40,
          color: AppColors.textSecondaryMuted,
        ),
      ),
    );
  }
}
