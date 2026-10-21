import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/product_image.dart';

enum ProductSort { recommended, priceLow, priceHigh, rating }

class StorePage extends StatefulWidget {
  const StorePage({super.key, this.service});
  final ProductService? service;

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  late final ProductService _service;
  late Future<List<Product>> _productsFuture;
  final _search = TextEditingController();
  List<Product> _products = [];
  final Set<int> _favorites = {};
  final Map<int, int> _cart = {};
  bool _requestInFlight = false;
  String? _category;
  ProductSort _sort = ProductSort.recommended;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ProductService();
    // Future dibuat sekali, bukan di build(), agar mengetik atau pindah tab
    // tidak mengirim permintaan API baru.
    _productsFuture = _fetchProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    if (widget.service == null) _service.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchProducts() async {
    _requestInFlight = true;
    try {
      final products = await _service.fetchProducts();
      if (mounted) {
        _products = products;
        if (!products.any((p) => p.category == _category)) _category = null;
        final ids = products.map((p) => p.id).toSet();
        _favorites.removeWhere((id) => !ids.contains(id));
        _cart.removeWhere((id, _) => !ids.contains(id));
        for (final p in products) {
          final quantity = _cart[p.id];
          if (quantity != null && quantity > p.stock) {
            if (p.stock > 0) {
              _cart[p.id] = p.stock;
            } else {
              _cart.remove(p.id);
            }
          }
        }
      }
      return products;
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> _load() async {
    if (_requestInFlight) return;
    final request = _fetchProducts();
    setState(() {
      _productsFuture = request;
    });
    try {
      await request;
    } catch (error) {
      // FutureBuilder menampilkan error awal. Saat refresh gagal, katalog
      // terakhir tetap tersedia dan pengguna menerima pesan kegagalan.
      if (mounted && _products.isNotEmpty) _notify(_errorMessage(error));
    }
  }

  String _errorMessage(Object? error) => error is ProductApiException
      ? error.message
      : 'Produk belum bisa dimuat. Silakan coba lagi.';

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _favorite(Product product) => setState(() {
        if (!_favorites.add(product.id)) _favorites.remove(product.id);
      });

  void _addToCart(Product product) {
    final quantity = _cart[product.id] ?? 0;
    if (quantity >= product.stock) {
      _notify('Jumlah sudah mencapai stok yang tersedia.');
      return;
    }
    setState(() => _cart[product.id] = quantity + 1);
    _notify('${product.title} ditambahkan ke keranjang.');
  }

  List<Product> get _visibleProducts {
    final query = _search.text.trim().toLowerCase();
    final result = _products.where((p) {
      return (_tab != 1 || _favorites.contains(p.id)) &&
          (_category == null || p.category == _category) &&
          '${p.title} ${p.brand} ${p.description}'.toLowerCase().contains(
                query,
              );
    }).toList();
    switch (_sort) {
      case ProductSort.recommended:
        result.sort((a, b) => a.id.compareTo(b.id));
      case ProductSort.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) => _scaffold(snapshot),
    );
  }

  Widget _scaffold(AsyncSnapshot<List<Product>> snapshot) {
    final cartCount = _cart.values.fold(0, (a, b) => a + b);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            // Logo diimpor dari Material Icons bawaan Flutter.
            Icon(Icons.shopping_bag_outlined, size: 30),
            SizedBox(width: 10),
            Text(
              'MONO',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat ulang produk',
            onPressed: snapshot.connectionState == ConnectionState.waiting
                ? null
                : _load,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _body(snapshot),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (value) => setState(() {
          _tab = value;
          _category = null;
          _search.clear();
        }),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            label: 'Katalog',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favorit',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              backgroundColor: Colors.black,
              textColor: Colors.white,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: 'Keranjang',
          ),
        ],
      ),
    );
  }

  Widget _body(AsyncSnapshot<List<Product>> snapshot) {
    final loading = snapshot.connectionState == ConnectionState.waiting;
    if (loading && _products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 18),
            Text('Mengambil produk…'),
          ],
        ),
      );
    }
    if (snapshot.hasError && _products.isEmpty) {
      return _message(
        Icons.wifi_off_outlined,
        'Produk belum bisa dimuat',
        _errorMessage(snapshot.error),
        action: FilledButton.icon(
          onPressed: _load,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      );
    }
    if (_tab == 2) return _cartView();
    final products = _visibleProducts;
    final categories = _products.map((p) => p.category).toSet().toList()
      ..sort();
    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList.list(
              children: [
                Text(
                  _tab == 1 ? 'Pilihan favoritmu.' : 'Temukan yang kamu suka.',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _tab == 1
                      ? 'Koleksi produk yang kamu simpan.'
                      : 'Katalog DummyJSON • Harga dalam USD',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari produk atau merek…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Hapus pencarian',
                            onPressed: () => setState(_search.clear),
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category ?? '',
                            isExpanded: true,
                            isDense: true,
                            items: [
                              const DropdownMenuItem(
                                value: '',
                                child: Text('Semua kategori'),
                              ),
                              ...categories.map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(
                                    c.replaceAll('-', ' '),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) => setState(
                              () => _category = value == '' ? null : value,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<ProductSort>(
                      tooltip: 'Urutkan produk',
                      initialValue: _sort,
                      onSelected: (value) => setState(() => _sort = value),
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: ProductSort.recommended,
                          child: Text('Rekomendasi'),
                        ),
                        PopupMenuItem(
                          value: ProductSort.priceLow,
                          child: Text('Harga terendah'),
                        ),
                        PopupMenuItem(
                          value: ProductSort.priceHigh,
                          child: Text('Harga tertinggi'),
                        ),
                        PopupMenuItem(
                          value: ProductSort.rating,
                          child: Text('Rating tertinggi'),
                        ),
                      ],
                      icon: const Icon(Icons.sort),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '${products.length} produk',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                if (loading) const LinearProgressIndicator(minHeight: 2),
              ],
            ),
          ),
          if (products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _message(
                _tab == 1 ? Icons.favorite_border : Icons.search_off,
                _tab == 1 && _favorites.isEmpty
                    ? 'Belum ada favorit'
                    : 'Produk tidak ditemukan',
                _tab == 1 && _favorites.isEmpty
                    ? 'Ketuk ikon hati pada produk untuk menyimpannya.'
                    : 'Coba kata kunci atau kategori lain.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final scale = MediaQuery.textScalerOf(context).scale(1);
                  final columns =
                      (width / (scale > 1.3 ? 260 : 170)).floor().clamp(1, 5);
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: 285 + 75 * scale,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _productCard(products[index]),
                      childCount: products.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _productCard(Product product) {
    final favorite = _favorites.contains(product.id);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E5E5)),
      ),
      child: InkWell(
        onTap: () => _showDetail(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(url: product.thumbnail),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: IconButton.filledTonal(
                      tooltip: favorite ? 'Hapus favorit' : 'Tambah favorit',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () => _favorite(product),
                      icon: Icon(
                        favorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.categoryLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed:
                          product.stock > 0 ? () => _addToCart(product) : null,
                      child: Text(product.stock > 0 ? 'Tambah' : 'Stok habis'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (context) => FractionallySizedBox(
        heightFactor: .9,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: 'Tutup detail',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              SizedBox(
                height: 250,
                child: PageView(
                  children: (product.images.isEmpty
                          ? [product.thumbnail]
                          : product.images)
                      .map((url) => ProductImage(url: url))
                      .toList(),
                ),
              ),
              if (product.images.length > 1)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Geser untuk melihat foto lainnya ↔',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                product.categoryLabel.toUpperCase(),
                style: const TextStyle(letterSpacing: 2, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Text(
                product.title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (product.brand.isNotEmpty)
                Text(
                  product.brand,
                  style: const TextStyle(color: Colors.black54),
                ),
              const SizedBox(height: 16),
              Text(
                product.formattedPrice,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Harga dalam USD',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  Text('★ ${product.rating.toStringAsFixed(1)} / 5'),
                  Text('Stok: ${product.stock}'),
                ],
              ),
              const Divider(height: 32),
              const Text(
                'Tentang produk',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              const SizedBox(height: 8),
              Text(product.description, style: const TextStyle(height: 1.6)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: product.stock > 0
                      ? () {
                          Navigator.pop(context);
                          _addToCart(product);
                        }
                      : null,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(
                    product.stock > 0 ? 'Tambah ke keranjang' : 'Stok habis',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartView() {
    final products = _products.where((p) => _cart.containsKey(p.id)).toList();
    if (products.isEmpty) {
      return _message(
        Icons.shopping_bag_outlined,
        'Keranjang masih kosong',
        'Tambahkan produk pilihanmu dari katalog.',
      );
    }
    final total = products.fold<double>(
      0,
      (sum, p) => sum + p.price * _cart[p.id]!,
    );
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Keranjangmu.',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Simulasi belanja • Tidak ada transaksi pembayaran',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        ...products.map(
          (p) => Card(
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: ProductImage(url: p.thumbnail),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(p.formattedPrice),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        tooltip: 'Kurangi ${p.title}',
                        onPressed: () => setState(() {
                          final count = _cart[p.id]!;
                          if (count <= 1) {
                            _cart.remove(p.id);
                          } else {
                            _cart[p.id] = count - 1;
                          }
                        }),
                        icon: Icon(
                          _cart[p.id] == 1
                              ? Icons.delete_outline
                              : Icons.remove,
                        ),
                      ),
                      Text('${_cart[p.id]}'),
                      IconButton(
                        tooltip: 'Tambah ${p.title}',
                        onPressed:
                            _cart[p.id]! < p.stock ? () => _addToCart(p) : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const Divider(height: 32),
        const Text(
          'Total (USD)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          '\$${total.toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        const Text(
          'Favorit dan keranjang disimpan selama aplikasi terbuka. Data akan direset saat aplikasi ditutup.',
          style: TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _message(
    IconData icon,
    String title,
    String description, {
    Widget? action,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.black45),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            if (action != null) ...[const SizedBox(height: 20), action],
          ],
        ),
      ),
    );
  }
}
