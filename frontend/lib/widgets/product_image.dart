import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/api_constants.dart'; // Ensure this is imported

class ProductImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath.isEmpty) {
      return _buildPlaceholder();
    }

    // Normalize path to use forward slashes (fix for Windows backend paths)
    String normalizedPath = imagePath.replaceAll(r'\', '/');
    String finalUrl = normalizedPath;
    bool isNetwork = false;

    if (normalizedPath.startsWith('http')) {
      isNetwork = true;
    } else if (normalizedPath.startsWith('uploads/')) {
       // It's a relative path from backend
       finalUrl = "${ApiConstants.uploadsUrl}/${normalizedPath.replaceAll('uploads/', '')}";
       isNetwork = true;
    } else if (kIsWeb && !normalizedPath.startsWith('assets')) {
       // Web fallback for other paths
       isNetwork = true;
    }

    if (isNetwork) {
      return Image.network(
        finalUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
              // Hacky way to log success once loaded? 
              // Actually loadingBuilder is called constantly. 
              // FrameBuilder is better for "loaded".
              return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primaryPeach,
            ),
          );
        },
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (frame != null) {
                // Image successfully rendered
            }
            return child;
        },
      );
    }

    // Asset
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
         return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded, 
          color: Colors.grey[400], 
          size: (width ?? 50) * 0.4
        ),
      ),
    );
  }
}
