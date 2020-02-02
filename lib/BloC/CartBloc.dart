import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/Model/CartItem.dart';
import 'package:food_ordering_app/Model/Product.dart';

class CartBloc with ChangeNotifier {
  List<CartItem> _items = [];

  int _cartItemTotal = 0;

  int get cartItemTotal => _cartItemTotal;

  UnmodifiableListView<CartItem> get items => UnmodifiableListView(_items);

  void addToCart(Product product, [int count = 1]) {

    for (CartItem item in _items) {
      if (product.foodId == item.product.foodId) {
        _cartItemTotal+=1;
        notifyListeners();
      }

      if (product.foodId == item.product.foodId) {
       item.count += 1;
       return;
      }
    }
    _items.add(CartItem(product: product, count: count));
    _cartItemTotal+=1;
    notifyListeners();
  }

  void deleteItem(){
    print('deleted');
  }

  void updateQuantity(action, foodId){
    for(CartItem item in _items){
      if(item.product.foodId == foodId){
        if(action == 'add'){
            item.count += 1;
            _cartItemTotal += 1;
        }

        if(action == 'remove'){
          if(item.count > 1) {
            item.count -= 1;
            _cartItemTotal -= 1;
          } else {
            deleteItem();
          }
        }
      }
    }
    notifyListeners();
  }

  void clearCart() {
    _items = [];
    notifyListeners();
  }
}
