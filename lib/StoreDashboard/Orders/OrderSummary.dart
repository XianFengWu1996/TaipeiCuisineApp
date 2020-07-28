import 'package:TaipeiCuisine/components/Divider/Divider.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:flutter/material.dart';

class OrderSummary extends StatelessWidget {
  OrderSummary({this.data});
  final data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Column(
        children: <Widget>[
          CheckoutSummaryItems(
            title: '税前总额（折扣前）',
            size: 27,
            details:
            '\$${data['subtotal'].toStringAsFixed(2)}',
          ),
          CheckoutSummaryItems(
            title: '折扣',
            size: 27,
            details:
            '\$(${(data['pointUsed'] / 100).toStringAsFixed(2)})',
          ),
          CheckoutSummaryItems(
            title: '午餐折扣',
            size: 27,
            details:
            '\$(${(data['lunchDiscount']).toStringAsFixed(2)})',
          ),
          LineDivider(),
          CheckoutSummaryItems(
            title: '税前总额',
            size: 27,
            details:
            '\$${(data['calcSubtotal']).toStringAsFixed(2)}',
          ),
          CheckoutSummaryItems(
            title: '税',
            size: 27,
            details: '\$${data['tax'].toStringAsFixed(2)}',
          ),
          data['delivery']
              ? CheckoutSummaryItems(
            title: '运费',
            size: 27,
            details:
            '\$${(data['deliveryFee']).toStringAsFixed(2)}',
          )
              : Container(),
          CheckoutSummaryItems(
            title: '小费',
            size: 27,
            details: '\$${data['tip'].toStringAsFixed(2)}',
      ),
          data['refund'] ?
          CheckoutSummaryItems(
            title: '退款',
            size: 27,
            details:
            '(\$${(data['refund_amount'] / 100).toStringAsFixed(2)})',
          ) : Container(),
          data['cancel'] ?
          CheckoutSummaryItems(
            title: '取消订单',
            size: 27,
            details:
            '(\$${(data['refund_amount'] / 100).toStringAsFixed(2)})',
          ) : Container(),
          CheckoutSummaryItems(
            title: '总额',
            size: 27,
            details:
            '\$${((data['total'])/ 100) .toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }
}
