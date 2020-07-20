import 'package:TaipeiCuisine/StoreDashboard/Report.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders.dart';
import 'package:TaipeiCuisine/components/Divider/Divider.dart';
import 'package:TaipeiCuisine/screens/Auth/Login.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MenuBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);

    TextStyle _menuTitle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600
    );

    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
              child: Image.asset('images/blacklogo.png'),
              decoration: BoxDecoration(color:Colors.white10)),
          ListTile(
            title: Text('New Orders', style: _menuTitle,),
            onTap: (){
              Get.off(Orders(
                status: 'Placed',
              ));
            },
          ),
          LineDivider(),
          ListTile(
            title: Text('Complete Orders',style: _menuTitle),
            onTap: (){
              Get.off(Orders(status: 'Completed',));
            },
          ),
          LineDivider(),
          ListTile(
            title: Text('Reports',style: _menuTitle),
            onTap: () async {
              await storeBloc.getTotalReports();
              Get.off(Report());
            },
          ),
          LineDivider(),


          ListTile(
            title: Text('Logout', style: _menuTitle),
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
