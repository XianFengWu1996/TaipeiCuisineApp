import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Account/AccountItem.dart';
import 'package:food_ordering_app/screens/Account/Reward/Rewards.dart';
import 'package:food_ordering_app/screens/Account/Screen/Address.dart';
import 'package:food_ordering_app/screens/Account/Screen/Setting.dart';
import 'package:food_ordering_app/screens/Account/Screen/User.dart';
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
            icon: FontAwesome.user,
            title: functionalBloc.selectedValue == 'english' ? 'User' : '用户信息',
            onTap: () {
              Get.to(User());
            },
          ),
          AccountItem(
            icon: FontAwesome.home,
            title: functionalBloc.selectedValue == 'english' ? 'Address' : '送餐地址',
            onTap: () async {
              await functionalBloc.retrieveAddress();

              Get.to(Address());
            },
          ),
          AccountItem(
            icon: Icons.attach_money,
            title: functionalBloc.selectedValue == 'english' ? 'Reward' : '积分回馈',
            onTap: () {
              Get.to(Reward());
            },
          ),
          AccountItem(
            icon: FontAwesome.gear,
            title: functionalBloc.selectedValue == 'english' ? 'Setting' : '设置',
            onTap: () {
              Get.to(Setting());
            },
          ),
        ],
      ),
    );
  }
}
