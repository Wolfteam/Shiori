import 'package:flutter/material.dart';

class ImageWidgetPlaceholder extends StatelessWidget {
  final ImageProvider image;
  final Widget? placeholder;

  const ImageWidgetPlaceholder({
    super.key,
    required this.image,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        } else {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: frame != null ? child : placeholder,
          );
        }
      },
    );
  }
}
