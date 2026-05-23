import 'package:flutter/material.dart';
import '../core/models/design_model.dart';
import '../core/services/firestore_service.dart';

class DesignProvider extends ChangeNotifier {
  final _service = FirestoreService();

  List<DesignModel> _designs = kSampleDesigns;
  String? _selectedCategory;
  bool _loaded = false;

  List<DesignModel> get all => _designs;
  String? get selectedCategory => _selectedCategory;

  List<DesignModel> get filtered => _selectedCategory == null
      ? _designs
      : _designs.where((d) => d.category == _selectedCategory).toList();

  List<DesignModel> get popular =>
      _designs.where((d) => d.tag == 'Popular' || d.tag == 'Trending').toList();

  void init() {
    if (_loaded) return;
    _loaded = true;
    _service.designs().listen((list) {
      if (list.isNotEmpty) _designs = list;
      notifyListeners();
    });
  }

  void setCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }
}
