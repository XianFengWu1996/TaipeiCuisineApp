import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Order/components/OrderModalDetail.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final int itemCount;
  final int itemTotal;
  final int createdAt;
  final String status;
  final DocumentSnapshot data;

  OrderCard({this.orderId, this.itemCount, this.itemTotal, this.createdAt, this.status, this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('${DateFormat("yyyy-MM-dd HH:mm").
              format(DateTime.fromMillisecondsSinceEpoch(createdAt))}'),
            subtitle: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
                Text('Order #:$orderId'),
                Text('${data['delivery'] ? 'Delivery': 'Pickup'}'),
                Text('$itemCount items'),
                Text('\$${(itemTotal / 100).toStringAsFixed(2)}'),
                Text('Status: $status')
              ],
            ),
          ),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return OrderModalDetail(
                            data: data
                          );
                        });
                  },
                  child: Text('Details')),
            ],
          ),
        ],
      ),
    );
  }
}
