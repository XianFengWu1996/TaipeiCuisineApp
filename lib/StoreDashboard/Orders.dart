import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/StoreBloc.dart';
import 'package:food_ordering_app/StoreDashboard/Menubar.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Orders extends StatelessWidget {
  Orders({this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            status == 'Placed' ? Text('New Orders') : Text('Completed Orders'),
      ),
      drawer: MenuBar(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('order')
              .where('status', isEqualTo: status)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<DocumentSnapshot> ds = snapshot.data.documents;
              ds.sort((a, b) {
                return b['createdAt'].compareTo(a['createdAt']);
              });

              return Container(
                child: ListView.builder(
                    itemCount: ds.length,
                    itemBuilder: (context, index) {
                      return OrderCard(index: index, ds: ds, status: status);
                    }),
              );
            } else {
              return Text('NO DATA');
            }
          }),
    );
  }
}

class OrderCard extends StatelessWidget {
  OrderCard({this.index, this.ds, this.status});

  final int index;
  final List<DocumentSnapshot> ds;
  final String status;

  @override
  Widget build(BuildContext context) {
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);

    var foodItems = ds[index]['items'];

    TextStyle _heading = TextStyle(
      fontSize: 35,
      fontWeight: FontWeight.w800,
    );

    TextStyle _subtitle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: Colors.red,
    );
    TextStyle _info = TextStyle(fontSize: 15, fontWeight: FontWeight.w400);

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: FlatButton(
        onPressed: () {
          showBottomSheet(
              context: context,
              builder: (context) {
                return Container(
                  color: Colors.white,
                  child: ListView(
                    children: <Widget>[
                      // customer information
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: ds[index]['delivery']
                            ? ListTile(
                                title: Text(
                                  'Delivery',
                                  style: _heading,
                                ),
                                subtitle: Text('${ds[index]['method'] == 'Card' ? 'Prepaid with Credit Card' : 'Cash'}', style: _subtitle),
                                leading: Icon(FontAwesome.car),
                                trailing: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Get.back();
                                    }),
                              )
                            : ListTile(
                                title: Text(
                                  'Pickup',
                                  style: _heading,
                                ),
                                subtitle: Text('${ds[index]['method'] == 'Card' ? 'Prepaid with Credit Card' : 'Cash'}', style: _subtitle),
                                leading: Icon(FontAwesome.shopping_bag),
                                trailing: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Get.back();
                                    }),
                              ),
                      ),
                      LineDivider(),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 10, bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '${ds[index]['customerName']}',
                              style: _info,
                            ),
                            ds[index]['delivery']
                                ? Text(
                                    '${ds[index]['deliveryAddress']}',
                                    style: _info,
                                  )
                                : Container(),
                            Text(
                              '${ds[index]['customerPhone']}',
                              style: _info,
                            ),
                          ],
                        ),
                      ),

                      //List of the order food
                      Container(
                        height: foodItems.length > 4
                            ? MediaQuery.of(context).size.height - 120
                            : 220,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: foodItems.length,
                            itemBuilder: (context, i) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]),
                                ),
                                child: ListTile(
                                  leading: Text('x${foodItems[i]['count']}'),
                                  title: Text(
                                      '${foodItems[i]['foodId']} . ${foodItems[i]['foodChineseName']}'),
                                  subtitle:  Text(
                                      '${foodItems[i]['foodName']}'),
                                  trailing: Text('\$${foodItems[i]['price']}'),
                                ),
                              );
                            }),
                      ),
                      LineDivider(),
                      // Summary of the price
                      ds[index]['customerComments'] != ''
                          ? Text(
                              'Customer Comments: ${ds[index]['customerComments']}')
                          : Text('No Comments'),
                      LineDivider(),

                      Column(
                        children: <Widget>[
                          CheckoutSummaryItems(
                            title: 'Subtotal',
                            details: '\$${ds[index]['subtotal']}',
                          ),
                          CheckoutSummaryItems(
                            title: 'Tax',
                            details: '\$${ds[index]['tax']}',
                          ),
                          ds[index]['delivery']
                              ? CheckoutSummaryItems(
                                  title: 'Delivery Fee',
                                  details:
                                      '\$${(ds[index]['deliveryFee']).toStringAsFixed(2)}',
                                )
                              : Container(),
                          CheckoutSummaryItems(
                            title: 'Tip',
                            details: '\$${ds[index]['tip']}',
                          ),
                          CheckoutSummaryItems(
                            title: 'Discount',
                            details:
                                '\$(${(ds[index]['pointUsed'] / 100).toStringAsFixed(2)})',
                          ),
                          CheckoutSummaryItems(
                            title: 'Total',
                            details:
                                '\$${(ds[index]['total'] / 100).toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                      LineDivider(),
                      status == 'Placed'
                          ? RaisedButton(
                              onPressed: () async {
                                await storeBloc.orderConfirmed(ds[index]['orderId']);
                                Get.back();
                              },
                              child: Text('Confirm', style: TextStyle(color: Colors.white),),
                              color: Colors.red[400],
                            )
                          : Column(
                             children: <Widget>[
                             RaisedButton(onPressed: (){}, child: Text('Partial Refund'),),
                             RaisedButton(onPressed: (){}, child: Text('Cancel Order'),)
                           ],
                      ),
                    ],
                  ),
                );
              });
        },
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(color: Colors.grey[400])),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.grey[300],
                child: ListTile(
                  dense: true,
                  title:
                      ds[index]['delivery'] ? Text('Delivery') : Text('Pickup'),
                  trailing: Text(
                      '${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(ds[index]['createdAt']))}'),
                ),
              ),
              ListTile(
                title: Text('${ds[index]['customerName']}'),
                subtitle: Text('${ds[index]['customerPhone']}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//refund
//RaisedButton(onPressed: ()async{
//await storeBloc.requestRefund(
//idKey: ds[index]['idempodency_key'],
//amount: {"amount": 100, "currency": "USD"},
//paymentId: ds[index]['paymentId'],
//);
//},child: Text('Refund'),)
