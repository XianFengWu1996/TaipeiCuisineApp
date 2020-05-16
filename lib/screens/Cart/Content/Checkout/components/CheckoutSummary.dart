import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/components/CheckoutComponents/Parts/CheckoutComponents.dart';
import 'package:provider/provider.dart';

class CheckoutSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var cartBloc = Provider.of<CartBloc>(context);

    return Column(
      children: <Widget>[
        CheckoutSummaryItems(
          title: 'Subtotal',
          details: '\$${cartBloc.subtotal}',
        ),
        CheckoutSummaryItems(
          title: 'Tax',
          details: '\$${cartBloc.tax}',
        ),
        cartBloc.isDelivery
            ? CheckoutSummaryItems(
          title: 'Delivery fee',
          details: '\$${cartBloc.deliveryFee.toStringAsFixed(2)}',
        )
            : Container(),
        CheckoutSummaryItems(
          title: 'Tip',
          details: '\$${cartBloc.tip}',
        ),
        CheckoutSummaryItems(
          title: 'Discount',
          details: '(\$${(cartBloc.rewardPoint / 100).toStringAsFixed(2)})',
        ),
        CheckoutSummaryItems(
          title: 'Total',
          details: '\$${cartBloc.total}',
        ),
      ],
    );
  }
}
