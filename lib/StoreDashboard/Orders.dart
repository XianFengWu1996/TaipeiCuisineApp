import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Menubar.dart';
import 'package:TaipeiCuisine/components/Divider.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
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
          title: Text(
        '${status == 'Placed' ? 'New Orders' : 'Completed Orders'}',
        style: TextStyle(fontSize: 30),
      )),
      drawer: MenuBar(),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('order/${DateTime.now().year}/${DateTime.now().month}')
              .where('status', isEqualTo: status)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              List<DocumentSnapshot> ds = snapshot.data.documents;
              ds.sort((a, b) {
                return b['createdAt'].compareTo(a['createdAt']);
              });

              if (status == 'Placed') {
                Firestore.instance
                    .collection('order/${DateTime.now().year}/${DateTime.now().month}')
                    .where('status', isEqualTo: status)
                    .snapshots()
                    .listen((event) {
                  event.documentChanges.forEach((element) {
                    if (element.type == DocumentChangeType.added) {
                      FlutterRingtonePlayer.playAlarm();
                    }
                  });
                });
              }

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

    TextStyle _heading = TextStyle(fontSize: 55, fontWeight: FontWeight.w800,);

    TextStyle _subtitle = TextStyle(fontSize: 23, fontWeight: FontWeight.w500, color: Colors.red,);

    TextStyle _cardHeader = TextStyle(fontSize: 40, fontWeight: FontWeight.w700);

    TextStyle _cardBody = TextStyle(fontSize: 25, fontWeight: FontWeight.w500);

    TextStyle _dishMain = TextStyle(fontSize: 25, fontWeight: FontWeight.w600);

    TextStyle _dishSub = TextStyle(fontSize: 18, fontWeight: FontWeight.w500);

    TextStyle _info = TextStyle(fontSize: 25, fontWeight: FontWeight.w400);

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
      child: FlatButton(
        onPressed: () {
          FlutterRingtonePlayer.stop();
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
                                subtitle: Text(
                                    '${ds[index]['method'] == 'Card' ? 'Prepaid with Credit Card' : 'Cash'}', style: _subtitle),
                                    leading: Icon(FontAwesome.car, size: 40,),
                                    trailing: IconButton(icon: Icon(Icons.close, size: 40,),
                                    onPressed: () {
                                      Get.back();
                                    }),
                              )
                            : ListTile(
                                title: Text('Pickup', style: _heading,),
                                subtitle: Text('${ds[index]['method'] == 'Card' ? 'Prepaid with Credit Card' : 'Cash'}', style: _subtitle),
                                leading: Icon(FontAwesome.shopping_bag, size: 40,),
                                trailing: IconButton(icon: Icon(Icons.close, size: 40),
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
                              '名字： ${ds[index]['customerName']}',
                              style: _info,
                            ),
                            ds[index]['delivery']
                                ? Text(
                                    '地址： ${ds[index]['deliveryAddress']}',
                                    style: _info,
                                  )
                                : Container(),
                            Text(
                              '电话号码： ${ds[index]['customerPhone']}',
                              style: _info,
                            ),
                          ],
                        ),
                      ),

                      //List of the order food
                      Container(
                        height: foodItems.length > 4
                            ? MediaQuery.of(context).size.height - 450
                            : 350,
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: foodItems.length,
                            itemBuilder: (context, i) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]),
                                ),
                                child: ListTile(
                                  leading: Text(
                                    'x${foodItems[i]['count']}',
                                    style: _dishMain,
                                  ),
                                  title: Text(
                                    '${foodItems[i]['foodId']} . ${foodItems[i]['foodChineseName']}',
                                    style: _dishMain,
                                  ),
                                  subtitle: Text(
                                    '${foodItems[i]['foodName']}',
                                    style: _dishSub,
                                  ),
                                  trailing: Text(
                                    '\$${foodItems[i]['price'].toStringAsFixed(2)}',
                                    style: _dishMain,
                                  ),
                                ),
                              );
                            }),
                      ),
                      LineDivider(),
                      // Summary of the price
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text('${ds[index]['customerComments'] != '' ? '特殊需求: ${ds[index]['customerComments']}' : '无需求'}', style: _dishMain,),
                      ),

                      LineDivider(),

                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: <Widget>[
                            CheckoutSummaryItems(
                              title: '税前总额（折扣前）',
                              size: 27,
                              details:
                              '\$${ds[index]['subtotal'].toStringAsFixed(2)}',
                            ),
                            CheckoutSummaryItems(
                              title: '折扣',
                              size: 27,
                              details:
                              '\$(${(ds[index]['pointUsed'] / 100).toStringAsFixed(2)})',
                            ),
                            CheckoutSummaryItems(
                              title: '午餐折扣',
                              size: 27,
                              details:
                              '\$(${(ds[index]['lunchDiscount'] / 100).toStringAsFixed(2)})',
                            ),
                            LineDivider(),
                            CheckoutSummaryItems(
                              title: '税前总额',
                              size: 27,
                              details:
                              '\$${(ds[index]['calcSubtotal']).toStringAsFixed(2)}',
                            ),
                            CheckoutSummaryItems(
                              title: '税',
                              size: 27,
                              details: '\$${ds[index]['tax'].toStringAsFixed(2)}',
                            ),
                            ds[index]['delivery']
                                ? CheckoutSummaryItems(
                                    title: '运费',
                                    size: 27,
                                    details:
                                        '\$${(ds[index]['deliveryFee']).toStringAsFixed(2)}',
                                  )
                                : Container(),
                            CheckoutSummaryItems(
                              title: '小费',
                              size: 27,
                              details: '\$${ds[index]['tip'].toStringAsFixed(2)}',
                            ),
                            CheckoutSummaryItems(
                              title: '总额',
                              size: 27,
                              details:
                                  '\$${(ds[index]['total'] / 100).toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ),
                      LineDivider(),
                      status == 'Placed'
                          ? RaisedButton(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                              onPressed: () async {
                                await storeBloc.orderConfirmed(ds[index]['orderId']);
                                Get.back();
                              },
                              child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 25),),
                              color: Colors.red[400],
                            )
                          : Column(
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: () {},
                                  child: Text('Partial Refund'),
                                ),
                                RaisedButton(
                                  onPressed: () {},
                                  child: Text('Cancel Order'),
                                )
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
                  contentPadding: EdgeInsets.all(15),
                  title: Text(
                    '${ds[index]['delivery'] ? 'Delivery' : 'Pickup'}',
                    style: _cardHeader,
                  ),
                  trailing: Text(
                    '${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(ds[index]['createdAt']))}',
                    style: _cardBody,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(20),
                title: Text(
                  '${ds[index]['customerName']}',
                  style: _cardBody,
                ),
                subtitle: Text(
                  '${ds[index]['delivery'] ? ds[index]['deliveryAddress'] : ds[index]['customerPhone']}',
                  style: _cardBody,
                ),
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
