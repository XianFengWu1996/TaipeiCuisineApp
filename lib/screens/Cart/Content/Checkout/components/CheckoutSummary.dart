import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:provider/provider.dart';

class CheckoutSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Column(
      children: <Widget>[
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Subtotal' : '税前总额',
          details: '\$${cartBloc.subtotal.toStringAsFixed(2)}',
        ),
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Reward Point' : '积分兑换',
          details: '(\$${(cartBloc.rewardPoint / 100).toStringAsFixed(2)})',
        ),
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Lunch Discount' : '午餐折扣',
          details: '(\$${(cartBloc.lunchDiscount).toStringAsFixed(2)})',
        ),
        LineDivider(),
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Subtotal(After)' : '税前总额(折扣后）',
          details: '\$${cartBloc.calcSubtotal.toStringAsFixed(2)}',
        ),
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Tax' : '税',
          details: '\$${cartBloc.tax.toStringAsFixed(2)}',
        ),
        cartBloc.isDelivery
            ? CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Delivery Fee' : '运费',
          details: '\$${cartBloc.deliveryFee.toStringAsFixed(2)}',
        )
            : Container(),
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Tip' : '小费',
          details: '${cartBloc.tipPercent == .0000000001 ? 'Cash' : '\$${cartBloc.tip.toStringAsFixed(2)}'}',
        ),
        CheckoutSummaryItems(
          title: functionalBloc.selectedValue == 'english' ? 'Total' : '总额',
          details: '\$${cartBloc.total.toStringAsFixed(2)}',
        ),
      ],
    );
  }
}
