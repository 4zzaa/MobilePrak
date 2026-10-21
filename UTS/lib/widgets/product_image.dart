import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    const placeholder = Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 36,
      ),
    );
    return ColoredBox(
      color: const Color(0xFFF2F2F2),
      child: url.isEmpty
          ? placeholder
          : Image.network(
              url,
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (_, __, ___) => placeholder,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(
                  child: SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
            ),
    );
  }
}
