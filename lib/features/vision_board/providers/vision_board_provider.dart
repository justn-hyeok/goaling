import 'package:flutter/foundation.dart';
import '../models/vision_board.dart';

class VisionBoardProvider extends ChangeNotifier {
  List<VisionBoardItem> _items = [];

  List<VisionBoardItem> get items => List.unmodifiable(_items);

  void addItem(VisionBoardItem item) {
    _items.add(item);
    notifyListeners();
  }

  void updateItem(VisionBoardItem item) {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _items[index] = item;
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }
}
