import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_network_image.dart';
import '../view_models/product_detail_view_model.dart';

/// Full-screen product photos: swipe between images, pinch or double-tap
/// to zoom. Pure UI state (page and zoom), so no view model of its own.
class ProductGalleryView extends StatefulWidget {
  const ProductGalleryView({super.key});

  @override
  State<ProductGalleryView> createState() => _ProductGalleryViewState();
}

class _ProductGalleryViewState extends State<ProductGalleryView> {
  late final GalleryArgs _args = Get.arguments as GalleryArgs;
  late final PageController _pages = PageController(
    initialPage: _args.initialIndex,
  );
  late int _index = _args.initialIndex;
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = _args.images;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            // Panning a zoomed image must not flip the page.
            physics: _zoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) => _ZoomableImage(
              url: images[i],
              onZoomChanged: (z) {
                if (z != _zoomed) setState(() => _zoomed = z);
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close',
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back<void>(),
                  ),
                  const Spacer(),
                  if (images.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        '${_index + 1} / ${images.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({required this.url, required this.onZoomChanged});

  final String url;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final _transform = TransformationController();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _tween;
  TapDownDetails? _doubleTap;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() => _transform.value = _tween!.value);
    _transform.addListener(
      () => widget.onZoomChanged(_transform.value.getMaxScaleOnAxis() > 1.01),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    _transform.dispose();
    super.dispose();
  }

  void _toggleZoom() {
    final zoomedIn = _transform.value.getMaxScaleOnAxis() > 1.01;
    final Matrix4 end;
    if (zoomedIn) {
      end = Matrix4.identity();
    } else {
      final p = _doubleTap?.localPosition ?? Offset.zero;
      const scale = 2.5;
      end = Matrix4.identity()
        ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    }
    _tween = Matrix4Tween(
      begin: _transform.value,
      end: end,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onDoubleTapDown: (d) => _doubleTap = d,
    onDoubleTap: _toggleZoom,
    child: InteractiveViewer(
      transformationController: _transform,
      maxScale: 4,
      child: SizedBox.expand(
        child: AppNetworkImage(widget.url, fit: BoxFit.contain),
      ),
    ),
  );
}
