import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/components/CartCard.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/CheckoutScreen.dart';
import 'package:provider/provider.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CartContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var bloc = Provider.of<CartBloc>(context);
    var authBloc = Provider.of<AuthBloc>(context);
    var paymentBloc = Provider.of<PaymentBloc>(context);

    return Column(
      children: <Widget>[
        Expanded(
          child: bloc.items.length > 0
              ? ListView.builder(
                  itemCount: bloc.items.length,
                  itemBuilder: (context, index) {
                    var item = bloc.items[index].product;
                    return Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          caption: 'Remove',
                          color: Colors.red[400],
                          icon: FontAwesome.trash,
                          onTap: () {
                            bloc.deleteItem(item.foodId,
                                bloc.items[index].count, item.price);
                          },
                        ),
                      ],
                      child: CartCard(index: index, item: item,),
                    );
                  })
              : Center(child: Text('Empty Cart')),
        ),
        Container(
          height: 200,
          child: Column(
            children: <Widget>[
              Text('Subtotal: \$${bloc.subtotal}'),
              FlatButton(
                color: Colors.red[400],
                onPressed: () async {
                  if (bloc.items.isNotEmpty) {
                    if (double.parse(bloc.subtotal) < 15) {
                      bloc.checkChoice('pickup');
                    }
                    await paymentBloc.retrieveBillingInfo(authBloc.user.uid);
                    await paymentBloc.retrieveRewardPoints(authBloc.user.uid);
                    Navigator.pushNamed(context, CheckoutScreen.id);
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text('Add items to the cart before checkout'),
                    ));
                  }
                },
                child: Text(
                  'Checkout',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              FlatButton(
                color: Colors.red[400],
                onPressed: () {
                  bloc.clearCart();
                },
                child:
                    Text('Clear Cart', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


