import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Account/AccountItem.dart';
import 'package:food_ordering_app/screens/Account/Reward/Rewards.dart';
import 'package:food_ordering_app/screens/Account/Screen/Address.dart';
import 'package:food_ordering_app/screens/Account/Screen/User.dart';
import 'package:provider/provider.dart';

class AccountContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
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
            title: 'User',
            onTap: () {
              print('User');
              Navigator.pushNamed(context, User.id);
            },
          ),
          AccountItem(
            icon: FontAwesome.home,
            title: 'Address',
            onTap: () async {
              await functionalBloc.retrieveAddress(authBloc.user.uid);

              Navigator.pushNamed(context, Address.id);
            },
          ),
          AccountItem(
            icon: Icons.attach_money,
            title: 'Rewards',
            onTap: () {
              Navigator.pushNamed(context, Reward.id);
            },
          ),
          AccountItem(
            icon: FontAwesome.gear,
            title: 'Setting',
            onTap: () {
              print('User');
            },
          ),
        ],
      ),
    );
  }
}
