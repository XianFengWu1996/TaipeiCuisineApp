import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/screens/Cart/CartScreen.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/Model/Product.dart';

class MenuItems extends StatelessWidget {
  final int count;
  final String title;
  final bool lunch;

  MenuItems({@required this.count, @required this.title, this.lunch});

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    TextStyle _spicyItem = TextStyle(
      color: Colors.red,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('$title'),
        actions: <Widget>[
          CartButton(itemCount: cartBloc.cartItemTotal),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: lunch ? functionalBloc.lunchMenu[count]['dishes'].length :functionalBloc.fullDayMenu[count]['dishes'].length,
                itemBuilder: (context, index) {
                  var currentDish = lunch ? functionalBloc.lunchMenu[count]['dishes'] : functionalBloc.fullDayMenu[count]['dishes'];
                  return currentDish[index]['active'] ? Card(
                    child: ListTile(
                      leading: Text('${currentDish[index]['food_id']}', style: currentDish[index]['spicy'] ? _spicyItem : TextStyle(),),
                      title: functionalBloc.selectedValue == 'english'
                          ? Text('${currentDish[index]['food_name']}',style: currentDish[index]['spicy'] ? _spicyItem : TextStyle(),)
                          : Text('${currentDish[index]['food_name_chinese']}', style: currentDish[index]['spicy'] ? _spicyItem : TextStyle(),),
                      subtitle: Text('\$${(currentDish[index]['price']).toStringAsFixed(2)}'),
                      trailing: IconButton(icon: Icon(Icons.add), iconSize: 30,
                        onPressed: (){
                          cartBloc.addToCart(
                            Product(
                              foodId: currentDish[index]['food_id'],
                              foodName: currentDish[index]['food_name'],
                              foodChineseName: currentDish[index]['food_name_chinese'],
                              price: currentDish[index]['price'],
                              lunch: currentDish[index]['lunch'],
                            ),
                          );
                        }, ),
                    ),
                  ) : Container();
                }),
          ),
        ],
      ),
    );
  }
}

class CartButton extends StatelessWidget {
  final int itemCount;
  CartButton({this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 35),
      child: Container(
          height: 150.0,
          width: 30.0,
          child: GestureDetector(
            onTap: () {
              Get.to(CartScreen());
            },
            child: Stack(
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    FontAwesome.shopping_cart,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: null,
                ),
                Positioned(
                    child: Stack(
                      children: <Widget>[
                        Icon(Icons.brightness_1,
                            size: 25.0, color: Colors.white),
                        Positioned(
                            top: 4.0,
                            left: itemCount < 10 ? 8.0 :3.0,
                            child: Center(
                              child: Text(
                                itemCount.toString(),
                                style: TextStyle(
                                    color: Colors.red[400],
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500),
                              ),
                            )),
                      ],
                    )),
              ],
            ),
          )),
    );
  }
}
