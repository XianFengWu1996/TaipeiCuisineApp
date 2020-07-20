import 'package:TaipeiCuisine/screens/Account/Screen/Reward/Rewards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/screens/Account/AccountItem.dart';
import 'package:TaipeiCuisine/screens/Account/Screen/Address.dart';
import 'package:TaipeiCuisine/screens/Account/Screen/Setting.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class AccountContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.count(
        primary: false,
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: <Widget>[
          AccountItem(
            icon: FontAwesome.home,
            title: functionalBloc.selectedLanguage == 'english' ? 'Address' : '送餐地址',
            onTap: () {
              Get.to(Address());
            },
          ),
          AccountItem(
            icon: Icons.attach_money,
            title: functionalBloc.selectedLanguage == 'english' ? 'Reward' : '积分回馈',
            onTap: () {
              Get.to(Reward());
            },
          ),
          AccountItem(
            icon: FontAwesome.gear,
            title: functionalBloc.selectedLanguage == 'english' ? 'Setting' : '设置',
            onTap: () {
              Get.to(Setting());
            },
          ),
        ],
      ),
    );
  }
}
