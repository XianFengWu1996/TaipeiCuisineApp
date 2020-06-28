import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/InputField.dart';
import 'package:TaipeiCuisine/components/Validation.dart';
import 'package:provider/provider.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';

class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  TextEditingController first = TextEditingController();
  TextEditingController last = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController zip = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    first.dispose();
    last.dispose();
    phone.dispose();
    street.dispose();
    city.dispose();
    zip.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);

    final _formKey = GlobalKey<FormState>();
    return Scaffold(
        appBar: AppBar(
          title: Text('${functionalBloc.selectedValue == 'english' ? 'Billing Information' : '账单信息'}'),
        ),
        resizeToAvoidBottomPadding: false,
        body: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 20,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Input(
                      label: '${functionalBloc.selectedValue == 'english' ? 'First Name' : '名字'}',
                      controller: first,
                      useNumKeyboard: false,
                      validate: Validation.firstNameValidation,
                    ),
                    Input(
                      label: '${functionalBloc.selectedValue == 'english' ? 'Last Name' : '姓'}',
                      controller: last,
                      useNumKeyboard: false,
                      validate: Validation.lastNameValidation,
                    ),
                    Input(
                      label: '${functionalBloc.selectedValue == 'english' ? 'Billing Information' : '电话'}',
                      useNumKeyboard: true,
                      controller: phone,
                      validate: Validation.phoneValidation,
                      inputFormatter: [
                        WhitelistingTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                    ),
                    cartBloc.isDelivery && cartBloc.address != ''
                        ? CheckboxListTile(
                            title: Text('${functionalBloc.selectedValue == 'english' ? 'Same as Delivery Address' : '和送餐地址一样'}'),
                            value: paymentBloc.sameAsDelivery,
                            onChanged: (bool value) {
                              paymentBloc.showAddressInput(value);
                            },
                          )
                        : Container(),
                    !paymentBloc.sameAsDelivery
                        ? Column(
                            children: <Widget>[
                              Input(
                                label: '${functionalBloc.selectedValue == 'english' ? 'Zip Code' : '邮政编码'}',
                                useNumKeyboard: true,
                                controller: zip,
                                validate: !paymentBloc.sameAsDelivery
                                    ? Validation.zipValidation
                                    : null,
                              ),
                              Input(
                                label: '${functionalBloc.selectedValue == 'english' ? 'Street' : '街名'}',
                                useNumKeyboard: false,
                                controller: street,
                                validate: !paymentBloc.sameAsDelivery
                                    ? Validation.streetValidation
                                    : null,
                              ),
                              Input(
                                label: '${functionalBloc.selectedValue == 'english' ? 'City' : '城市'}',
                                useNumKeyboard: false,
                                controller: city,
                                validate: !paymentBloc.sameAsDelivery
                                    ? Validation.cityValidation
                                    : null,
                              ),

                            ],
                          )
                        : Container(),
                    CheckboxListTile(
                        title: Text('${functionalBloc.selectedValue == 'english' ? 'Save to Wallet' : '保存卡信息，方便快速下单'}'),
                        value: paymentBloc.saveCard,
                        onChanged: (value) {
                          paymentBloc.checkSaveCard(value);
                        }),
                    FlatButton(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          paymentBloc.saveBillingInfo(
                            first: first.text,
                            last: last.text,
                            phone: phone.text,
                            email: authBloc.user.email,
                            street: street.text == ''
                                ? cartBloc.street
                                : street.text,
                            city: city.text == '' ? cartBloc.city : city.text,
                            zip: zip.text == '' ? cartBloc.zipCode : zip.text,
                          );

                          paymentBloc.payment(cartBloc, functionalBloc, cartBloc.total);
                        }
                      },
                      child: Text('${functionalBloc.selectedValue == 'english' ? 'Proceed to Square Payment' : '前往 Square Payment'}'),
                      color: Colors.red[400],textColor: Colors.white,
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
