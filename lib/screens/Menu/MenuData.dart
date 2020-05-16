import 'dart:convert';
import 'package:flutter/services.dart';

class MenuData {

  List _categoryData = [];

  List _menuData = [];

  List _chineseCategory = [];

  Future<List> retrieveMenuData () async {
    var data = await rootBundle.loadString('assets/menu_data.json');
    var result = jsonDecode(data);

    for(int i = 2; i < result.length; i++){
      _menuData.add(result[i]);
    }

    return _menuData;
  }

  Future<List<dynamic>>retrieveCategory() async {
    var data = await rootBundle.loadString('assets/menu_data.json');
    var result = jsonDecode(data);
    _categoryData.add(result[0]);

    return _categoryData;
  }

  Future<List<dynamic>>retrieveChineseCategory() async {
    var data = await rootBundle.loadString('assets/menu_data.json');
    var result = jsonDecode(data);
    _chineseCategory.add(result[1]);

    return _chineseCategory;
  }

}
