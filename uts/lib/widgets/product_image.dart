import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    const placeholder = Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Colors.black38,
      ),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) => placeholder,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
    );
  }
}
