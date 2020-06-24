import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderModalDetail extends StatelessWidget {
  final DocumentSnapshot data;

  OrderModalDetail({this.data});

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return ListView(
      children: <Widget>[
        Container(
          height: 50,
          color: Colors.grey[200],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(icon: Icon(Icons.close), onPressed: (){
                Get.close(1);
              }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            child: Column(
              children: <Widget>[
                Text('${functionalBloc.selectedValue == 'english' ? 'Date' : '日期'}: ${DateFormat("yyyy-MM-dd HH:mm").format(DateTime.fromMillisecondsSinceEpoch(data['createdAt']))}'),
                Text('${functionalBloc.selectedValue == 'english' ? 'Order #' : '订单号'}: ${data['orderId']}'),
                LineDivider(),
                Text('${functionalBloc.selectedValue == 'english' ? 'Customer Name' : '姓名'}: ${data['customerName']}'),
                Text('${functionalBloc.selectedValue == 'english' ? 'Phone Number' : '电话'}: ${data['customerPhone']}'),
                LineDivider(),
                Text('${functionalBloc.selectedValue == 'english' ? 'Method' : '取餐方式'}: ${data['delivery'] ? '${functionalBloc.selectedValue == 'english' ? 'Delivery' : '送餐'}' : '${functionalBloc.selectedValue == 'english' ? 'Pickup' : '自取'}'}'),
                data['delivery'] ? Text('${data['deliveryAddress']}') : Container(),
                Text('${functionalBloc.selectedValue == 'english' ? 'Payment Method' : '付款方式'}: ${data['method']}'),
                Text('${functionalBloc.selectedValue == 'english' ? 'Number of Items' : '数量'}: ${data['totalCount']}'),
                Text('${functionalBloc.selectedValue == 'english' ? 'Reward Point Earned' : '获得积分'}: ${data['pointEarned']}'),
                LineDivider(),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: data['items'].length,
                  itemBuilder: (context, index){
                    return Row(
                      children: <Widget>[
                        Text('${data['items'][index]['foodId']}. ',),
                        Expanded(
                          child: Text('${functionalBloc.selectedValue == 'english' ? data['items'][index]['foodName'] :data['items'][index]['foodChineseName'] } ',
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
                data['customerComments'] != '' ? Text('${functionalBloc.selectedValue == 'english' ? 'Customer Comments' : '特殊要求'}: ${data['customerComments']}') : Container(),
                data['customerComments'] != '' ? LineDivider() : Container(),
                CheckoutSummaryItems(
                  title: '${functionalBloc.selectedValue == 'english' ? 'Subtotal' : '税前总额'}',
                  details: '\$${data['subtotal'].toStringAsFixed(2)}',),
                CheckoutSummaryItems(title: '${functionalBloc.selectedValue == 'english' ? 'Reward Point' : '兑换积分'}', details: '(\$${(data['pointUsed']/100).toStringAsFixed(2)})'),
                CheckoutSummaryItems(title: '${functionalBloc.selectedValue == 'english' ? 'Lunch Discount' : '午餐折扣'}', details: '(\$${(data['lunchDiscount']).toStringAsFixed(2)})'),
                LineDivider(),
                CheckoutSummaryItems(
                  title: '${functionalBloc.selectedValue == 'english' ? 'Subtotal(After)' : '税前总额(折扣后)'}',
                  details: '\$${data['calcSubtotal'].toStringAsFixed(2)}',),
                CheckoutSummaryItems(title: '${functionalBloc.selectedValue == 'english' ? 'Tax' : '税'}', details: '\$${data['tax'].toStringAsFixed(2)}',),
                CheckoutSummaryItems(title: '${functionalBloc.selectedValue == 'english' ? 'Tip' : '小费'}', details: '\$${data['tip'].toStringAsFixed(2)}',),
                CheckoutSummaryItems(title: '${functionalBloc.selectedValue == 'english' ? 'Total' : '总额'}', details: '\$${(data['total']/100).toStringAsFixed(2)}',),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
