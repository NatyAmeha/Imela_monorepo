import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:imela_ui_kit/helpers/constants/constant.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final Gradient? gradient;
  final String? heroTag;
  final File? file;
  final bool isSvg;
  final bool isNetworkSvg;
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
    this.placeholderImageUrl = Constatnts.productPlaceholderImage,
    this.file,
    this.isSvg = false,
    this.isNetworkSvg = false,
  });

  String _getProxiedUrl(String url) {
    if (!kIsWeb) return url;
    // Use a CORS proxy service for web platform
    return 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(url)}';
  }

  @override
  Widget build(BuildContext context) {
    Widget image = isSvg
        ? isNetworkSvg
            ? SvgPicture.network(
                _getProxiedUrl(imageUrl ?? ''),
                width: width,
                height: height,
                placeholderBuilder: (BuildContext context) => Container(
                  padding: const EdgeInsets.all(30.0),
                  child: const CircularProgressIndicator(),
                ),
              )
            : SvgPicture.asset(imageUrl ?? '')
        : file != null
            ? Image.file(
                file!,
                fit: fit,
                width: width,
                height: height,
                errorBuilder: (context, url, error) => Image.asset(placeholderImageUrl, fit: BoxFit.cover),
              )
            : CachedNetworkImage(
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
