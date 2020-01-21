import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Dashboard/ScreenContents/AccountContent.dart';
import 'package:food_ordering_app/screens/Dashboard/ScreenContents/CartContent.dart';
import 'package:food_ordering_app/screens/Dashboard/ScreenContents/HomeContent.dart';
import 'package:food_ordering_app/screens/Dashboard/ScreenContents/MenuContent.dart';

class Home extends StatefulWidget {
  static const id = 'home_screen';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    HomeContent(),
    MenuContent(),
    CartContent(),
    AccountContent(),
  ];

  final List<String> _title = [
    'Home',
    'Menu',
    'Cart',
    'Account'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_title[_currentIndex]}'),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 35.0,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.redAccent[200],
        currentIndex: _currentIndex,
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            title: Text('Home'),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
              title: Text('Menu'),
              icon: Icon(Icons.fastfood),
          ),
          BottomNavigationBarItem(
            title: Text('Cart'),
            icon:Icon(Icons.shopping_cart),
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
