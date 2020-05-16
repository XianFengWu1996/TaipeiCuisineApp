import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/components/Chips.dart';
import 'package:provider/provider.dart';

class CheckoutChoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cartBloc = Provider.of<CartBloc>(context);
    var authBloc = Provider.of<AuthBloc>(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        CheckoutChip(
          title: 'Pickup',
          icon: FontAwesome.shopping_bag,
          choice: !cartBloc.isDelivery,
          onSelected: (value) {
            if (value) {
              cartBloc.checkChoice('pickup');
            }
          },
        ),
        CheckoutChip(
            title: 'Delivery',
            icon: FontAwesome.car,
            choice: cartBloc.isDelivery,
            onSelected: (value) async {
              if (double.parse(cartBloc.subtotal) >= 15) {
                if (cartBloc.address == '') {
                  await cartBloc.getAddress(authBloc.user.uid);
                }

                if (value) {
                  cartBloc.checkChoice('delivery');
                } else {
                  cartBloc.checkChoice('pickup');
                }
              } else {
                Scaffold.of(context).showSnackBar(
                  SnackBar(content: Text('Minimum for delivery is \$15')),
                );
              }
            }),
      ],
    );
  }
}
