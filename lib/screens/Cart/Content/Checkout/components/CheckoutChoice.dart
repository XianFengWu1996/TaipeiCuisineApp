import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/Chips.dart';
import 'package:provider/provider.dart';

class CheckoutChoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      children: <Widget>[
        CheckoutChip(
          title: functionalBloc.selectedValue == 'english' ? 'Pickup' : '自取',
          icon: FontAwesome.shopping_bag,
          choice: !cartBloc.isDelivery,
          onSelected: (value) {
            if (value) {
              cartBloc.checkChoice('pickup');
            }
          },
        ),
        CheckoutChip(
            title: functionalBloc.selectedValue == 'english' ? 'Delivery' : '送餐',
            icon: FontAwesome.car,
            choice: cartBloc.isDelivery,
            onSelected: (value) async {
              if (cartBloc.subtotal >= 15) {
                if (cartBloc.address == '') {
                  await cartBloc.getAddress();
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
