import 'package:flutter/foundation.dart';

class FavoritesController extends ChangeNotifier {
  final Set<int> _ids = {};

  bool contains(int id) => _ids.contains(id);
  int get count => _ids.length;

  void toggle(int id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
  }
}
