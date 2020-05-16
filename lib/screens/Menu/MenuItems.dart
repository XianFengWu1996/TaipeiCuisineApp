import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/screens/Cart/CartScreen.dart';
import 'package:food_ordering_app/screens/Menu/MenuData.dart';
import 'package:provider/provider.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/Model/Product.dart';

class MenuItems extends StatefulWidget {
  final int index;
  final String title;
  final bool displayChinese;

  MenuItems({@required this.index, @required this.title, this.displayChinese});

  @override
  _MenuItemsState createState() => _MenuItemsState();
}

class _MenuItemsState extends State<MenuItems> {
  List menuItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    var data = await MenuData().retrieveMenuData();
    for (var item in data[widget.index]['dishes']) {
      setState(() {
        menuItems.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<CartBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('${widget.title}')),
        actions: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: new Container(
                height: 150.0,
                width: 30.0,
                child: new GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                      builder: (BuildContext context) => CartScreen(),
                    ));
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
                              left: bloc.cartItemTotal < 10 ? 8.0 :3.0,
                              child: Center(
                                child: Text(
                                  bloc.cartItemTotal.toString(),
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
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  var item = menuItems[index];
                  return Card(
                    child: ListTile(
                      leading: Text('${item['food_id']}'),
                      title: Text(widget.displayChinese
                          ? '${item['food_name_chinese']}'
                          : '${item['food_name']}'),
                      subtitle: Text('\$ ${item['price']}'),
                      trailing: FlatButton(
                        child: Icon(
                          Icons.add,
                          size: 30,
                        ),
                        onPressed: () {
                          bloc.addToCart(
                            Product(
                              id: int.parse(item['id']),
                              foodId: item['food_id'],
                              foodName: item['food_name'],
                              foodChineseName: item['food_name_chinese'],
                              price: double.parse(item['price']),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
