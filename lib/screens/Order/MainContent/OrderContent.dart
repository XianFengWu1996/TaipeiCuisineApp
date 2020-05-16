import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/OrderBloc.dart';
import 'package:food_ordering_app/screens/Order/MainContent/Pages/OrderCancelled.dart';
import 'package:food_ordering_app/screens/Order/MainContent/Pages/OrderCompleted.dart';
import 'package:food_ordering_app/screens/Order/MainContent/Pages/OrderInProgress.dart';
import 'package:food_ordering_app/screens/Order/components/ProgressChips.dart';
import 'package:provider/provider.dart';

class OrderContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    OrderBloc orderBloc = Provider.of<OrderBloc>(context);

    return ListView(
      children: <Widget>[
        //Order In Progress
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ProgressChipGroup(),

            orderBloc.orderStatus == 'inProgress' ? OrderInProgress(uid: authBloc.user.uid,) : Container(),
            orderBloc.orderStatus == 'completed' ? OrderCompleted(uid: authBloc.user.uid) : Container(),
            orderBloc.orderStatus == 'cancelled' ? OrderCanncelled(uid: authBloc.user.uid) : Container(),

          ],
        ),
      ],
    );
  }
}
