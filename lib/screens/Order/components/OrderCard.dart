import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Order/components/OrderModalDetail.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderCard extends StatelessWidget {
  final String orderId;
  final int itemCount;
  final int itemTotal;
  final int createdAt;
  final DocumentSnapshot data;

  OrderCard({this.orderId, this.itemCount, this.itemTotal, this.createdAt, this.data});

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
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
                Text('${functionalBloc.selectedValue == 'english' ? 'Order #' : '订单号'}:$orderId'),
                Text('${data['delivery'] ?
                '${functionalBloc.selectedValue == 'english' ? 'Delivery' : '送餐'}':
                '${functionalBloc.selectedValue == 'english' ? 'Pickup' : '自取'}'}'),
                Text('$itemCount ${functionalBloc.selectedValue == 'english' ? 'items' : '道菜'}'),
                Text('\$${(itemTotal / 100).toStringAsFixed(2)}'),
              ],
            ),
          ),
          ButtonBar(
            children: <Widget>[
              RaisedButton(
                  onPressed: () {
                    showBottomSheet(
                        context: context,
                        builder: (context) {
                          return OrderModalDetail(
                            data: data
                          );
                        });
                  },
                  child: Text('${functionalBloc.selectedValue == 'english' ? 'Details' : '查看'}')),
            ],
          ),
        ],
      ),
    );
  }
}
