import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/screens/Account/AccountContent.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/components/CartContent.dart';
import 'package:TaipeiCuisine/screens/Order/MainContent/OrderContent.dart';
import 'package:TaipeiCuisine/screens/Menu/MenuContent.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {

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

  final List<String> _titleChinese = [
    '菜单',
    '购物车',
    '订单',
    '账号'
  ];

  @override
  Widget build(BuildContext context) {
    FunctionalBloc funcBloc = Provider.of<FunctionalBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('${funcBloc.selectedValue == 'english' ?
            _title[funcBloc.homePageIndex] :
            _titleChinese[funcBloc.homePageIndex]
            }'),
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
              title: Text('${funcBloc.selectedValue == 'english' ? 'Menu': '菜单'}'),
              icon: Icon(Icons.fastfood),
          ),
          BottomNavigationBarItem(
            title: Text('${funcBloc.selectedValue == 'english' ? 'Cart': '购物车'}'),
            icon:Icon(Icons.shopping_cart),
          ),
          BottomNavigationBarItem(
            title: Text('${funcBloc.selectedValue == 'english' ? 'Order': '订单'}'),
            icon: Icon(Icons.receipt),
          ),
          BottomNavigationBarItem(
            title: Text('${funcBloc.selectedValue == 'english' ? 'Account': '账号'}'),
            icon: Icon(Icons.person)
          ),
        ],
      ),
    );
  }
}
