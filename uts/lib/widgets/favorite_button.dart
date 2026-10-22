import 'package:flutter/material.dart';
import '../state/favorites_controller.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.id, required this.favorites});
  final int id;
  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: favorites,
    builder: (context, child) => IconButton.filledTonal(
      tooltip: favorites.contains(id) ? 'Hapus dari favorit' : 'Simpan favorit',
      onPressed: () => favorites.toggle(id),
      icon: Icon(
        favorites.contains(id) ? Icons.favorite : Icons.favorite_border,
      ),
    ),
  );
}
