import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/components/Buttons/Rectangular.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutSummary.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/OrderList.dart';
import 'package:TaipeiCuisine/components/Divider.dart';
import 'package:TaipeiCuisine/screens/Home.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Confirmation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('${functionalBloc.selectedValue == 'english' ? 'Confirmation' : '订单成功'}'),
          leading: Text(''),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${functionalBloc.selectedValue == 'english' ? 'Order Confirmation' : '订单信息'}',
                    style: TextStyle(fontSize: 30),
                  ),
                  LineDivider(),
                  Text('${functionalBloc.selectedValue == 'english' ? 'Order#' : '订单号' }: ${paymentBloc.orderNumber}'),
                  Text('${functionalBloc.selectedValue == 'english' ? 'Customer Name' : '姓名'}: ${paymentBloc.customerFirstName + ' ' + paymentBloc.customerLastName}'),
                  Text('${functionalBloc.selectedValue == 'english' ? 'Customer Phone' : '电话'}: ${paymentBloc.customerPhoneNumber}'),
                  Text('${cartBloc.isDelivery ?
                    '${functionalBloc.selectedValue == 'english' ? 'Delivery' : '送餐'}'
                      : '${functionalBloc.selectedValue == 'english' ? 'Pickup' : '自取'}'}'),
                  cartBloc.isDelivery ?
                    Text('${cartBloc.street}, ${cartBloc.apt == '' ? '' : '${cartBloc.apt},'} ${cartBloc.city}, ${cartBloc.zipCode}')
                    : Container(),
                  LineDivider(),
                  cartBloc.businessName != ''
                      ? Text(cartBloc.businessName)
                      : Container(),
                  functionalBloc.selectedValue == 'english' ?
                    Text('Estimate time for ${cartBloc.isDelivery ? 'delivery' : 'pickup'} '
                      'is about ${cartBloc.isDelivery ? '45-60min' : '15-20min'}') :
                    Text('${cartBloc.isDelivery ? '你的餐预计在45-60分钟内到达' : '您的餐预计在15-20分钟内准备好'}'),

                  Text(functionalBloc.selectedValue == 'english' ?
                  '(Larger orders might take 10-15min more to prepare)' :
                  '(较大的订单可能需要更多时间来准备（10-15分钟)'),
                  LineDivider(),
                  OrderList(),
                  LineDivider(),
                  paymentBloc.comments != '' ? Text('${functionalBloc.selectedValue == 'enlgish' ? 'Customer comments' : '特殊要求'}: ${paymentBloc.comments}') : Container(),
                  paymentBloc.comments != '' ? LineDivider() : Container(),
                  CheckoutSummary(),
                  Center(
                    child: RectangularLogin(
                      onPressed: () {
                        functionalBloc.changeTab(2);
                        paymentBloc.clearAfterCheckout();
                        cartBloc.clearValueUponCheckout();
                        Get.offAll(Home());
                      },
                      title: '${functionalBloc.selectedValue == 'english' ? 'Return to Home': '回到主页'}',
                      color: Colors.red[400],
                      vertical: 10,
                      horizontal: 15,
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
