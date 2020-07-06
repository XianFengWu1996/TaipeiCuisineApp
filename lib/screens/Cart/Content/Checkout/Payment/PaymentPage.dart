import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/Payment/PaymentModal.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: PaymentModal()),
    );
  }
}
