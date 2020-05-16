import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Account/AccountContent.dart';
import 'package:food_ordering_app/screens/Cart/Content/CartContent.dart';
import 'package:food_ordering_app/screens/Order/MainContent/OrderContent.dart';
import 'package:food_ordering_app/screens/Dashboard/ScreenContents/MenuContent.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  static const id = 'home_screen';

  final List<Widget> _tab= [
    MenuContent(),
    CartContent(),
    OrderContent(),
    AccountContent(),
  ];

  final List<String> _title = [
    'Menu',
    'Cart',
    'Order',
    'Account'
  ];

  @override
  Widget build(BuildContext context) {
    FunctionalBloc funcBloc = Provider.of<FunctionalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${_title[funcBloc.homePageIndex]}'),
        leading: Text(''),
      ),
      body: _tab[funcBloc.homePageIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 35.0,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.redAccent[200],
        currentIndex: funcBloc.homePageIndex,
        onTap: funcBloc.changeTab,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              title: Text('Menu'),
              icon: Icon(Icons.fastfood),
          ),
          BottomNavigationBarItem(
            title: Text('Cart'),
            icon:Icon(Icons.shopping_cart),
          ),
          BottomNavigationBarItem(
            title: Text('Order'),
            icon: Icon(Icons.receipt),
          ),
          BottomNavigationBarItem(
            title: Text('Account'),
            icon: Icon(Icons.person)
          ),
        ],
      ),
    );
  }
}
