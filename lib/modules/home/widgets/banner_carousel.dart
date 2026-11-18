import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_network_image.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key, required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    return CarouselSlider(
      options: CarouselOptions(
        aspectRatio: 16 / 8,
        viewportFraction: 0.92,
        enlargeCenterPage: true,
        autoPlay: urls.length > 1,
      ),
      items: urls
          .map(
            (url) => AppNetworkImage(
              url,
              width: double.infinity,
              borderRadius: BorderRadius.circular(16),
            ),
          )
          .toList(),
    );
  }
}
