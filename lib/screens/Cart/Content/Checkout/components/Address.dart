import 'package:TaipeiCuisine/components/Buttons/Button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:TaipeiCuisine/components/Helper/Validation.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class AddressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return cartBloc.isDelivery
        ? CheckoutCard(
            title: functionalBloc.selectedLanguage == 'english' ? 'Deliver to' : '送到：',
            icon: FontAwesome.home,
            action: FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddressDetails()));
              },
              child: functionalBloc.deliveryAddress == ''
                  ? Text('${functionalBloc.selectedLanguage == 'english' ? 'Add' : '添加'}')
                  : Text('${functionalBloc.selectedLanguage == 'english' ? 'Switch' : '更改'}'),
            ),
            subtitle:
            functionalBloc.deliveryAddress == ''
                    ? functionalBloc.selectedLanguage == 'english'
                    ? 'Add An Address'
                    : '添加你的送餐地址'
                    : functionalBloc.deliveryAddress,
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
        title: Text('${functionalBloc.selectedLanguage == 'english' ? 'Address' : '送餐地址'}'),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ModalProgressHUD(
          inAsyncCall: functionalBloc.loading,
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: ListView(
                children: <Widget>[

                  Input(
                    label: '${functionalBloc.selectedLanguage == 'english' ? 'Street' : '门牌号和街名'}',
                    validate: Validation.streetValidation,
                    controller: _street,
                  ),

                  Input(
                    label: '${functionalBloc.selectedLanguage == 'english' ? 'City' : '城市'}',
                    validate: Validation.cityValidation,
                    controller: _city,
                  ),

                  Input(
                    label: '${functionalBloc.selectedLanguage == 'english' ? 'Zip Code' : '邮政编码'}',
                    validate: Validation.zipValidation,
                    useNumKeyboard: true,
                    inputFormatter: [
                      LengthLimitingTextInputFormatter(5),
                      WhitelistingTextInputFormatter.digitsOnly
                    ],
                    controller: _zipCode,
                  ),

                  Input(
                    label: '${functionalBloc.selectedLanguage == 'english' ? 'Apt / Suite / Floor' : '公寓号 / 楼层'}',
                    validate: null,
                    controller: _apt,
                  ),

                  Input(
                    label: '${functionalBloc.selectedLanguage == 'english' ? 'Businesses or Building Name' : '公司地址 / 建筑名称'}',
                    validate: null,
                    controller: _businessName,
                  ),

                  Button(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        functionalBloc.setValue('loading','start');
                        await cartBloc.saveAddress(_street.text, _city.text, _zipCode.text, _apt.text, _businessName.text, functionalBloc);
                        _formKey.currentState.reset();
                        Navigator.pop(context);

                        functionalBloc.setValue('loading','reset');
                      }
                    },
                    title: '${functionalBloc.selectedLanguage == 'english' ? 'Save' : '保存'}',
                    color: Colors.red[400],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


