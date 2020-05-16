import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:intl/intl.dart';

class OrderModalDetail extends StatelessWidget {
  final DocumentSnapshot data;

  OrderModalDetail({this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
            color: Colors.grey[200],
            child: Center(child: Text('Order Detail',style: TextStyle(fontSize: 18),),),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 400,
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Text('Date: ${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(data['createdAt']))}'),
                      Text('Order #: ${data['orderId']}'),
                      Text('Status: ${data['status'].toUpperCase()}'),
                      LineDivider(),
                      Text('Method: ${data['delivery'] ? 'Delivery' : 'Pickup'}'),
                      data['delivery'] ? Text('${data['deliveryAddress']}') : Container(),
                      Text('Payment Method: ${data['method']}'),
                      Text('Number of Items: ${data['totalCount']}'),
                      Text('Reward Point Earned: ${data['pointEarned']}'),
                      LineDivider(),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: data['items'].length,
                        itemBuilder: (context, index){
                          return Row(
                            children: <Widget>[
                              Text('${data['items'][index]['foodId']}. '),
                              Expanded(
                                child: Text('${data['items'][index]['foodName']} ',
                                ),
                              ),
                              Text('     '),
                              Text('x${data['items'][index]['count']}'),
                              Text('     '),
                              Text('\$${(data['items'][index]['price'] * data['items'][index]['count']).toStringAsFixed(2)}')
                            ],
                          );
                        },
                      ),
                      LineDivider(),
                      CheckoutSummaryItems(title: 'Subtotal', details: '\$${data['subtotal']}',),
                      CheckoutSummaryItems(title: 'Tax (7%)', details: '\$${data['tax']}',),
                      CheckoutSummaryItems(title: 'Tip', details: '\$${data['tip']}',),
                      CheckoutSummaryItems(title: 'Discount', details: '(\$${(data['pointUsed']/100)})'),
                      CheckoutSummaryItems(title: 'Total', details: '\$${(data['total']/100).toStringAsFixed(2)}',),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
