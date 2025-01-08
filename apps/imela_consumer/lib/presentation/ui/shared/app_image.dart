import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../resources/asset_manager.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Gradient? gradient;
  final String? heroTag;
  final String placeholderImageUrl;

  const AppImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.gradient,
    this.heroTag,
    this.placeholderImageUrl = AssetManager.productPlaceholderImage,
  });

  String _getProxiedUrl(String url) {
    if (!kIsWeb) return url;
    // Use a CORS proxy service for web platform
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
  }

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: _getProxiedUrl(imageUrl ?? ''),
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => Image.asset(placeholderImageUrl, fit: BoxFit.cover),
      errorWidget: (context, url, error) {
        print('Error loading image: $error');
        return Image.asset(placeholderImageUrl, fit: BoxFit.cover);
      },
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    if (gradient != null) {
      image = Stack(
        children: [
          Positioned.fill(child: image),
          Container(decoration: BoxDecoration(gradient: gradient, borderRadius: borderRadius)),
        ],
      );
    }

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return image;
  }
}
