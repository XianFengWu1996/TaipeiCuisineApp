import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders/CustomerInfo.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderConstant.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderHeader.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderList.dart';
import 'package:TaipeiCuisine/StoreDashboard/Orders/OrderSummary.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Menubar.dart';
import 'package:TaipeiCuisine/components/Divider/Divider.dart';
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

              // Play sound for every new order
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

class OrderCard extends StatefulWidget {
  OrderCard({this.index, this.ds, this.status});

  final int index;
  final List<DocumentSnapshot> ds;
  final String status;

  @override
  _OrderCardState createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> {
  TextEditingController amount = TextEditingController();
  TextEditingController cancel = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    amount.dispose();
    cancel.dispose();
  }


  @override
  Widget build(BuildContext context) {
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    var foodItems = widget.ds[widget.index]['items'];


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
                      // order information
                      OrderHeader(data: widget.ds[widget.index],),
                      LineDivider(),
                      CustomerInfo(data: widget.ds[widget.index],),


                      //List of the order food
                      StoreOrderList(foodItems: foodItems,),
                      LineDivider(),

                      //Comments
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Text('${widget.ds[widget.index]['customerComments'] != '' ? '特殊需求: ${widget.ds[widget.index]['customerComments']}' : '无需求'}', style: dishMain,),
                      ),
                      LineDivider(),
                      // Summary of the price
                      OrderSummary(data: widget.ds[widget.index],),
                      LineDivider(),
                      widget.status == 'Placed'
                          ? RaisedButton(
                        padding: EdgeInsets.only(top: 20, bottom: 20),
                              onPressed: () async {
                                await storeBloc.orderConfirmed(widget.ds[widget.index]['orderId']);
                                Get.back();
                              },
                              child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 25),),
                              color: Colors.red[400],
                            )
                          : Column(
                              children: <Widget>[
                                !widget.ds[widget.index]['refund'] && !widget.ds[widget.index]['cancel'] ? RaisedButton(
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: 'Partial Refund',
                                      content: Input(
                                      useNumKeyboard: true,
                                      label: 'Amount',
                                      controller: amount,
                                      ),
                                      confirm: RaisedButton(onPressed: () async {
                                        if(double.parse(amount.text) > 0 && double.parse(amount.text) <= widget.ds[widget.index]['total']){
                                          await storeBloc.requestRefund(
                                            data: widget.ds[widget.index],
                                            token: functionalBloc.squareToken,
                                            amount: (double.parse(amount.text) * 100).toInt(),
                                            reward: widget.ds[widget.index]['method'] == 'Card' ? functionalBloc.cardReward : functionalBloc.cashReward
                                          );
                                        }

                                      }, child: Text('Refund'),),
                                      cancel: FlatButton(onPressed: (){
                                        Get.close(1);
                                      }, child: Text('Cancel')),
                                    );
//
                                  },
                                  child: Text('Partial Refund'),
                                ) : Container(),
                                !widget.ds[widget.index]['cancel'] ? RaisedButton(
                                  onPressed: (){
                                    Get.defaultDialog(
                                        title: 'Cancel',
                                        content: Input(
                                          label: 'Type \'Cancel\' to Confirm',
                                          controller: cancel,
                                        ),
                                        confirm: RaisedButton(onPressed: () async{
                                          if(cancel.text =='Cancel'){
                                            Get.close(1);
                                            await storeBloc.cancelOrder(
                                                paymentId: widget.ds[widget.index]['paymentId'],
                                                token: functionalBloc.squareToken,
                                                data: widget.ds[widget.index],
                                                reward: widget.ds[widget.index]['method'] == 'Card' ? functionalBloc.cardReward : functionalBloc.cashReward
                                            );
                                            Get.close(1);

                                          } else {
                                            Get.snackbar('Error', 'Type in the word \'Cancel\', then confirm', backgroundColor: Colors.red[400], colorText: Colors.white);
                                          }
                                        }, child: Text('Confirm'),)
                                    );
                                  },
                                  child: Text('Cancel Order'),
                                ) : Container(),
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
                    '${widget.ds[widget.index]['delivery'] ? 'Delivery' : 'Pickup'} ${widget.ds[widget.index]['cancel'] ? '(Canceled)' : ''}' ,
                    style: cardHeader,
                  ),
                  trailing: Text(
                    '${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(widget.ds[widget.index]['createdAt']))}',
                    style: cardBody,
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.all(20),
                title: Text(
                  '${widget.ds[widget.index]['customerName']}',
                  style: cardBody,
                ),
                subtitle: Text(
                  '${widget.ds[widget.index]['delivery'] ? widget.ds[widget.index]['deliveryAddress'] : widget.ds[widget.index]['customerPhone']}',
                  style: cardBody,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
