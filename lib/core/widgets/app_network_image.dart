import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Cached network image with consistent placeholder and error states.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage(
    this.url, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final String? url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    Widget box({Widget? child}) => Container(
      width: width,
      height: height,
      color: palette.imageBackground,
      alignment: Alignment.center,
      child: child,
    );
    final fallback = box(
      child: Icon(Icons.image_outlined, color: palette.mutedText, size: 28),
    );
    final imageUrl = url;
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl == null || imageUrl.isEmpty
          ? fallback
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              width: width,
              height: height,
              fadeInDuration: const Duration(milliseconds: 200),
              placeholder: (_, _) => box(),
              errorWidget: (_, _, _) => fallback,
            ),
    );
  }
}
