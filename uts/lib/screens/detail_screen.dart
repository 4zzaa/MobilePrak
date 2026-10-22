import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../state/favorites_controller.dart';
import '../utils/product_filter.dart';
import '../widgets/async_states.dart';
import '../widgets/favorite_button.dart';
import '../widgets/product_image.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.id,
    required this.service,
    required this.favorites,
  });
  final int id;
  final ProductService service;
  final FavoritesController favorites;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Product> _product;
  @override
  void initState() {
    super.initState();
    _product = widget.service.fetchProduct(widget.id);
  }

  void _retry() {
    final next = widget.service.fetchProduct(widget.id);
    setState(() {
      _product = next;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Detail produk'),
      leading: IconButton(
        tooltip: 'Kembali',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        FavoriteButton(id: widget.id, favorites: widget.favorites),
        const SizedBox(width: 12),
      ],
    ),
    body: SafeArea(
      top: false,
      child: FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView();
          }
          if (snapshot.hasError) {
            return MessageView(
              title: 'Detail gagal dimuat',
              message: snapshot.error.toString(),
              icon: Icons.cloud_off,
              action: _retry,
            );
          }
          final p = snapshot.data!;
          final images = p.images.isNotEmpty ? p.images : [p.thumbnail];
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _Gallery(images: images),
                  const SizedBox(height: 22),
                  Text(
                    categoryLabel(p.category).toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (p.brand.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Merek: ${p.brand}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  const SizedBox(height: 18),
                  Text(
                    priceLabel(p.price),
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Chip(
                        avatar: const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: Color(0xFF222222),
                        ),
                        label: Text('${p.rating.toStringAsFixed(1)} / 5'),
                      ),
                      Chip(
                        label: Text(
                          p.stock > 0 ? 'Stok: ${p.stock}' : 'Stok habis',
                        ),
                      ),
                      if (p.discountPercentage > 0)
                        Chip(
                          label: Text(
                            'Diskon API: ${p.discountPercentage.toStringAsFixed(1)}%',
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _Section(
                    title: 'Deskripsi',
                    child: Text(
                      p.description.isEmpty
                          ? 'Deskripsi belum tersedia.'
                          : p.description,
                      style: const TextStyle(height: 1.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Informasi produk',
                    child: Column(
                      children: [
                        _Info(
                          icon: Icons.verified_user_outlined,
                          label: 'Garansi',
                          value: p.warranty,
                        ),
                        _Info(
                          icon: Icons.local_shipping_outlined,
                          label: 'Pengiriman',
                          value: p.shipping,
                        ),
                        _Info(
                          icon: Icons.assignment_return_outlined,
                          label: 'Pengembalian',
                          value: p.returnPolicy,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: 'Ulasan (${p.reviews.length})',
                    child: p.reviews.isEmpty
                        ? const Text('Belum ada ulasan.')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final review in p.reviews)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '★ ${review.rating.toStringAsFixed(1)} / 5',
                                        style: const TextStyle(
                                          color: Color(0xFF444444),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        review.comment,
                                        style: const TextStyle(height: 1.5),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Data contoh dari DummyJSON • Bukan layanan belanja',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.images});
  final List<String> images;
  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _page = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: const Color(0xFFEEEEEE),
          child: SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _page = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.all(24),
                child: ProductImage(url: widget.images[index]),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text(
        '${_page + 1} / ${widget.images.length}${widget.images.length > 1 ? ' • Geser untuk foto lainnya' : ''}',
        style: const TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ],
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Text(value.isEmpty ? 'Tidak tersedia' : value),
            ],
          ),
        ),
      ],
    ),
  );
}
