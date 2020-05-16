import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:food_ordering_app/components/Helper/helper.dart';
import 'package:provider/provider.dart';

//chip to select the percentage of tips
class TipSelection extends StatefulWidget {
  @override
  _TipSelectionState createState() => _TipSelectionState();
}

class _TipSelectionState extends State<TipSelection> {

  void checkTip({bool selected, CartBloc bloc, double percent}){
    // Check to see if the chip is selected
    if(selected){
      // check if the custom tip is 0,
      if(bloc.customTip != 0){
        //if not, clear the tip
        bloc.clearCustomTip();
      }
      // if it is 0, get the tip percentage
      bloc.getTipPercent(percent);
    } else {
      // if it is not selected, clear the tip
      bloc.clearTip();
    }
  }

  @override
  Widget build(BuildContext context) {

    var cartBloc = Provider.of<CartBloc>(context);

    String tipValue;

    return Column(
      children: <Widget>[
        cartBloc.isDelivery
            ? Text('Select tips for your driver')
            : Text('Select tip amount (optional)'),
        Wrap(
          spacing: 10,
          children: <Widget>[
            //The following chips are use for selecting the tips
            CheckoutTip(
              labelText: '10%',
              tipAmount: cartBloc.tipPercent == .1,
              onSelected: (bool selected) {
                checkTip(selected: selected, bloc: cartBloc, percent: .1);
              },
            ),
            CheckoutTip(
              labelText: '15%',
              tipAmount: cartBloc.tipPercent == .15,
              onSelected: (selected) {
                checkTip(selected: selected, bloc: cartBloc, percent: .15);
              },
            ),
            CheckoutTip(
              labelText: '20%',
              tipAmount: cartBloc.tipPercent == .2,
              onSelected: (selected) {
                checkTip(selected: selected, bloc: cartBloc, percent: .2);
              },
            ),
            CheckoutTip(
              labelText: 'Custom',
              tipAmount: cartBloc.tipPercent == 0.0000001,
              onSelected: (selected) {
                if(selected){
                  cartBloc.getTipPercent(0.0000001);
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Enter the desired tip amount'),
                          content: TextField(
                            style: TextStyle(fontSize: 30),
                            decoration: InputDecoration(
                              labelText: '\$',
                              labelStyle: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w600),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              DecimalTextInputFormatter(decimalRange: 2),
                              DotTextInputFormatter(),
                            ],
                            onChanged: (value){
                              setState(() {
                                tipValue = value;
                              });
                            },
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('Confirm'),
                              onPressed: () {
                                if(tipValue != null) {
                                  cartBloc.isCustomTip(true, tipValue);
                                  Navigator.pop(context);
                                }
                              },
                              color: Colors.red[400],
                            ),

                            FlatButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                                cartBloc.clearTip();
                              },
                            ),
                          ],
                        );
                      });
                } else {
                  cartBloc.isCustomTip(false, '0.00');
                  cartBloc.clearTip();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

// Chip to select pickup or delivery
class CheckoutChip extends StatelessWidget {
  CheckoutChip({this.choice, this.onSelected, this.title, this.icon});

  final bool choice;
  final Function onSelected;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ChoiceChip(
        labelPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        label: Text('$title'),
        labelStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,),
        selected: choice,
        selectedColor: Colors.red[400],
        avatar: Icon(
          icon,
          color: Colors.white,
        ),
        onSelected: onSelected,
      ),
    );
  }
}

// Chips to select type of payment
class PaymentSelectionChip extends StatelessWidget {

  PaymentSelectionChip({
    @required this.title,
    this.icon,
    @required this.selected,
    @required this.onSelected
  });

  final String title;
  final IconData icon;
  final bool selected;
  final Function onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ChoiceChip(
        label: ListTile(
          title: Text(title),
          leading: Icon(icon),
        ),
        shape: BeveledRectangleBorder(),
        selectedColor: Colors.redAccent[100],
        selected: selected,
        onSelected: onSelected
      ),
    );
  }
}


