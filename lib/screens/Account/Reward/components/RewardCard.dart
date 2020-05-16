import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/intl.dart';

class RewardCard extends StatelessWidget {
  final String action;
  final int amount;
  final int createdAt;
  final String method;
  final String orderId;

  RewardCard({this.action, this.amount, this.createdAt, this.method, this.orderId});

  @override
  Widget build(BuildContext context) {
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
              action == 'add' ? Text('Method: $method') : Container(),
              Text('Order #: $orderId'),
            ],
          ),
        ),
      ),
    );
  }
}
