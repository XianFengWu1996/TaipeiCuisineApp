import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:provider/provider.dart';

class RewardInput extends StatefulWidget {
  @override
  _RewardInputState createState() => _RewardInputState();
}

class _RewardInputState extends State<RewardInput> {
  TextEditingController _pointController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _pointController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Column(
      children: <Widget>[
        Text('${functionalBloc.selectedLanguage == 'english' ? 'Point Available' : '可使用的积分'}: ${paymentBloc.rewardPoint}'),
        Container(
          width: 250,
          child: TextFormField(
            controller: _pointController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: functionalBloc.selectedLanguage == 'english'
                    ? '100 pts = \$1'
                    : '每100分可抵消\$1',
                contentPadding: EdgeInsets.all(5.0),
                suffixIcon: IconButton(
                    icon: Icon(
                      FontAwesome.check_circle_o,
                      size: 30,
                    ),
                    onPressed: () {
                      if (_pointController.text != '') {
                        int point = int.parse(_pointController.text);
                        if (point <= paymentBloc.rewardPoint) {

                          if(point > cartBloc.subtotal * 100){
                            cartBloc.setValue('useReward',(cartBloc.subtotal * 100).toInt());
                          } else {
                            cartBloc.setValue('useReward', point);
                          }
                        }

                      }
                    }),
                border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 1,
                    ))),
          ),
        ),
        cartBloc.rewardPoint > 0 ?
        Text('${functionalBloc.selectedLanguage == 'english' ? 'Point Remaining' : '剩余积分'}: '
            '${paymentBloc.rewardPoint - cartBloc.rewardPoint}') : Container(),
      ],
    );
  }
}
