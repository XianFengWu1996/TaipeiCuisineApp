import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/Helper/helper.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//chip to select the percentage of tips
class TipSelection extends StatelessWidget {

  void checkTip({bool selected, CartBloc bloc, double percent}){
    // Check to see if the chip is selected
    if(selected){
      // if it is 0, get the tip percentage
      bloc.setValue('getTipPercent',percent);
    } else {
      // if it is not selected, clear the tip
      bloc.setValue('resetTipPercent', false);
    }
  }

  @override
  Widget build(BuildContext context) {

    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Column(
      children: <Widget>[
        cartBloc.isDelivery
            ? Text('${functionalBloc.selectedLanguage == 'english' ? 'Select tips for your driver' : '请选择给予司机的小费'}')
            : Text('${functionalBloc.selectedLanguage == 'english' ? 'Select tip amount (optional)' : '请选择给予的小费(可不选)'}'),
        Wrap(
          spacing: 10,
          children: <Widget>[
            //The following chips are use for selecting the tips
            CheckoutTip(
              labelText: '10%',
              tipAmount: cartBloc.tipPercent == .1,
              onSelected: (bool selected) {
                cartBloc.setValue('resetTipPercent', false);
                checkTip(selected: selected, bloc: cartBloc, percent: .1);
              },
            ),
            CheckoutTip(
              labelText: '15%',
              tipAmount: cartBloc.tipPercent == .15,
              onSelected: (selected) {
                cartBloc.setValue('resetTipPercent', false);
                checkTip(selected: selected, bloc: cartBloc, percent: .15);
              },
            ),
            CheckoutTip(
              labelText: '20%',
              tipAmount: cartBloc.tipPercent == .2,
              onSelected: (selected) {
                cartBloc.setValue('resetTipPercent', false);
                checkTip(selected: selected, bloc: cartBloc, percent: .2);
              },
            ),
            CheckoutTip(
              labelText: '${functionalBloc.selectedLanguage == 'english' ? 'Cash' : '现金'}',
              tipAmount: cartBloc.tipPercent == .0000000001,
              onSelected: (selected) {
                cartBloc.setValue('resetTipPercent', false);
                checkTip(selected: selected, bloc: cartBloc, percent: .0000000001);
              },
            ),
            CheckoutTip(
              labelText: '${functionalBloc.selectedLanguage == 'english' ? 'Custom' : '自订'}',
              tipAmount: cartBloc.tipPercent == 0.0000001,
              onSelected: (selected) {
                if(selected){
                  cartBloc.setValue('getTipPercent',0.0000001);
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('${functionalBloc.selectedLanguage == 'english' ? 'Enter the desired tip amount' : '请输入你想给予的小费'}'),
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
                            onChanged: (value)async{
                              await cartBloc.setValue('customTipValue', value);
                            },
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text('${functionalBloc.selectedLanguage == 'english' ? 'Confirm' : '确认'}'),
                              onPressed: () {
                                if(cartBloc.customTip != null) {
                                  cartBloc.isCustomTip(true, cartBloc.customTip);
                                  Navigator.pop(context);
                                }
                              },
                              color: Colors.red[400],
                            ),

                            FlatButton(
                              child: Text('${functionalBloc.selectedLanguage == 'english' ? 'Cancel' : '取消'}'),
                              onPressed: () {
                                Navigator.pop(context);
                                cartBloc.setValue('resetTipPercent', false);
                              },
                            ),
                          ],
                        );
                      });
                } else {
                  cartBloc.isCustomTip(false, 0.00);
                  cartBloc.setValue('resetTipPercent', false);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
