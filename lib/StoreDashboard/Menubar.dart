import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/StoreBloc.dart';
import 'package:food_ordering_app/StoreDashboard/Orders.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Auth/Login/Login.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Image.asset('images/blacklogo.png'),
              decoration: BoxDecoration(color:Colors.white10)),
          ListTile(
            title: Text('New Orders'),
            onTap: (){
              Get.off(Orders(
                status: 'Placed',
              ));
            },
          ),
          LineDivider(),
          ListTile(
            title: Text('Complete Orders'),
            onTap: (){
              Get.off(Orders(status: 'Completed',));
            },
          ),
          LineDivider(),
          ListTile(
            title: Text('Logout'),
            onTap: () async{
              await storeBloc.logout();
              Get.offAll(Login());
            },
          ),
          LineDivider(),
        ],
      ),
    );
  }
}
