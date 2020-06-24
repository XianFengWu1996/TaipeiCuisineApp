import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/InputField.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:food_ordering_app/components/Validation.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class AddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return cartBloc.isDelivery
        ? CheckoutCard(
            title: functionalBloc.selectedValue == 'english' ? 'Deliver to' : '送到：',
            icon: FontAwesome.home,
            action: FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddressDetails()));
              },
              child: cartBloc.address == ''
                  ? Text('${functionalBloc.selectedValue == 'english' ? 'Add' : '添加'}')
                  : Text('${functionalBloc.selectedValue == 'english' ? 'Switch' : '更改'}'),
            ),
            subtitle:
                cartBloc.address == ''
                    ? functionalBloc.selectedValue == 'english'
                    ? 'Add An Address'
                    : '添加你的送餐地址'
                    : cartBloc.address,
          )
        : Container();
  }
}

class AddressDetails extends StatefulWidget {
  @override
  _AddressDetailsState createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {

  final _formKey = GlobalKey<FormState>();

  TextEditingController _street = TextEditingController();
  TextEditingController _city= TextEditingController();
  TextEditingController _zipCode = TextEditingController();
  TextEditingController _apt = TextEditingController();
  TextEditingController _businessName = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _street.dispose();
    _city.dispose();
    _zipCode.dispose();
    _apt.dispose();
    _businessName.dispose();

  }

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${functionalBloc.selectedValue == 'english' ? 'Address' : '送餐地址'}'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(top: 20, left: 20, right: 20),
            child: ListView(
              children: <Widget>[

                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'Street' : '门牌号和街名'}',
                  validate: Validation.streetValidation,
                  controller: _street,
                ),

                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'City' : '城市'}',
                  validate: Validation.cityValidation,
                  controller: _city,
                ),

                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'Zip Code' : '邮政编码'}',
                  validate: Validation.zipValidation,
                  useNumKeyboard: true,
                  inputFormatter: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  controller: _zipCode,
                ),

                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'Apt / Suite / Floor' : '公寓号 / 楼层'}',
                  validate: null,
                  controller: _apt,
                ),

                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'Businesses or Building Name' : '公司地址 / 建筑名称'}',
                  validate: null,
                  controller: _businessName,
                ),

                FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      functionalBloc.toggleLoading('start');
                      await cartBloc.saveAddress(_street.text, _city.text, _zipCode.text, _apt.text, _businessName.text);
                      _formKey.currentState.reset();
                      Navigator.pop(context);

                      functionalBloc.toggleLoading('reset');
                    }
                  },
                  child: Text('${functionalBloc.selectedValue == 'english' ? 'Save' : '保存'}'),
                  color: Colors.red[400], textColor: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


