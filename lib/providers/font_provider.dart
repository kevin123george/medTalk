import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class FontProvider with ChangeNotifier {
  double _font_size = GetStorage().read('font_size') != null
      ? GetStorage().read('font_size') : 1.0;

  double get font_size => _font_size;

  void change_font_size(font_size) => {
    this._font_size = font_size,
    GetStorage().write('font_size', font_size),
    notifyListeners()
  };
}