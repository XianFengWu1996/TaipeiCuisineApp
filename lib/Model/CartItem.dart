import 'package:food_ordering_app/Model/Product.dart';


class CartItem {
  final Product product;
  int count;

  CartItem({this.product, this.count});
}