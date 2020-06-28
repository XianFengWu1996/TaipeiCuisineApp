import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RewardCard extends StatelessWidget {
  final String action;
  final int amount;
  final int createdAt;
  final String method;
  final String orderId;

  RewardCard({this.action, this.amount, this.createdAt, this.method, this.orderId});

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        color: action == 'add' ? Colors.green[200] :Colors.red[200],
        child: ListTile(
          title: Text('${DateFormat('MM/dd/yyyy').format(DateTime.fromMillisecondsSinceEpoch(createdAt))}'),
          leading: Icon(
              action == 'add' ? FontAwesome.plus : FontAwesome.minus
          ),
          trailing: Text('$amount pt'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              action == 'add' ?
              Text('${functionalBloc.selectedValue == 'english' ? 'Method' : '付款方式'} $method') :
              Container(),

              Text('${functionalBloc.selectedValue == 'english' ? 'Order #' : '订单号'}: $orderId'),
            ],
          ),
        ),
      ),
    );
  }
}
