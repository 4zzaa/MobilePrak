import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../state/favorites_controller.dart';
import '../utils/product_filter.dart';
import '../widgets/async_states.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.service, required this.favorites});
  final ProductService service;
  final FavoritesController favorites;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _products;
  final _search = TextEditingController();
  String? _category;
  ProductSort _sort = ProductSort.recommended;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _products = widget.service.fetchProducts();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final next = widget.service.fetchProducts();
    setState(() {
      _products = next;
    });
    try {
      await next;
    } catch (_) {
    }
  }

  void _resetFilters() => setState(() {
    _search.clear();
    _category = null;
    _sort = ProductSort.recommended;
  });

  void _open(Product product) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => DetailScreen(
        id: product.id,
        service: widget.service,
        favorites: widget.favorites,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_outlined, size: 28, color: Colors.black),
          SizedBox(width: 10),
          Text('KatalogKu', style: TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
      actions: [
        if (_tab != 2)
          IconButton(
            onPressed: _refresh,
            tooltip: 'Muat ulang produk',
            icon: const Icon(Icons.refresh_rounded),
          ),
        const SizedBox(width: 8),
      ],
    ),
    body: SafeArea(
      top: false,
      child: _tab == 2
          ? const AboutScreen()
          : ListenableBuilder(
              listenable: widget.favorites,
              builder: (context, _) => FutureBuilder<List<Product>>(
                future: _products,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const LoadingView();
                  }
                  if (snapshot.hasError) {
                    return MessageView(
                      title: 'Produk belum bisa dimuat',
                      message: snapshot.error.toString(),
                      icon: Icons.wifi_off_rounded,
                      action: _refresh,
                    );
                  }
                  return _catalog(snapshot.data ?? []);
                },
              ),
            ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      onDestinationSelected: (index) => setState(() => _tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: 'Katalog',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favorit',
        ),
        NavigationDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: 'Tentang',
        ),
      ],
    ),
  );

  Widget _catalog(List<Product> all) {
    final isFavorite = _tab == 1;
    final categories =
        all.map((p) => p.category).where((c) => c.isNotEmpty).toSet().toList()
          ..sort();
    final visible = isFavorite
        ? all.where((p) => widget.favorites.contains(p.id)).toList()
        : filterProducts(
            all,
            query: _search.text,
            category: _category,
            sort: _sort,
          );
    final textScale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        key: PageStorageKey(isFavorite ? 'favorit' : 'katalog'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isFavorite)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PILIHAN SETIAP HARI',
                            style: TextStyle(
                              color: Color(0xFFDDDDDD),
                              fontSize: 11,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Temukan produk.\nSimpan yang kamu suka.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${all.length} produk • ${categories.length} kategori',
                            style: const TextStyle(color: Color(0xFFDDDDDD)),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Text(
                      'Pilihan kamu',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text('Favorit tersimpan selama aplikasi dibuka.'),
                  ],
                  if (!isFavorite) ...[
                    const SizedBox(height: 20),
                    TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Cari produk atau merek…',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus pencarian',
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(_search.clear),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: const Text('Semua'),
                              selected: _category == null,
                              onSelected: (_) =>
                                  setState(() => _category = null),
                            ),
                          ),
                          for (final category in categories)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(categoryLabel(category)),
                                selected: _category == category,
                                onSelected: (_) =>
                                    setState(() => _category = category),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${visible.length} produk${isFavorite ? ' favorit' : ' ditemukan'}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (!isFavorite)
                        PopupMenuButton<ProductSort>(
                          tooltip: 'Urutkan produk',
                          initialValue: _sort,
                          onSelected: (sort) => setState(() => _sort = sort),
                          itemBuilder: (_) => ProductSort.values
                              .map(
                                (sort) => CheckedPopupMenuItem(
                                  value: sort,
                                  checked: _sort == sort,
                                  child: Text(sort.label),
                                ),
                              )
                              .toList(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.sort, size: 18),
                                const SizedBox(width: 5),
                                Text(
                                  _sort.label,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (visible.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: MessageView(
                title: isFavorite
                    ? 'Belum ada favorit'
                    : 'Produk tidak ditemukan',
                message: isFavorite
                    ? 'Ketuk ikon hati pada produk untuk menyimpannya.'
                    : 'Coba kata kunci lain atau hapus filter yang dipilih.',
                icon: isFavorite ? Icons.favorite_border : Icons.search_off,
                action: isFavorite
                    ? () => setState(() => _tab = 0)
                    : _resetFilters,
                actionLabel: isFavorite ? 'Jelajahi katalog' : 'Reset filter',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width < 320
                      ? 1
                      : width < 600
                      ? 2
                      : width < 900
                      ? 3
                      : 4;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent:
                          320 + (textScale > 1 ? (textScale - 1) * 170 : 0),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
                        product: visible[index],
                        favorites: widget.favorites,
                        onTap: () => _open(visible[index]),
                      ),
                      childCount: visible.length,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
