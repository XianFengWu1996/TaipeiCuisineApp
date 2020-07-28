import 'package:TaipeiCuisine/components/Buttons/Button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:TaipeiCuisine/components/Helper/Validation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';

class PaymentForm extends StatefulWidget {
  @override
  _PaymentFormState createState() => _PaymentFormState();
}

class _PaymentFormState extends State<PaymentForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController first;
  TextEditingController last;
  TextEditingController phone;
  String street = '';
  String city = '';
  String zip = '';


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    first.dispose();
    last.dispose();
    phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);

    first = TextEditingController(text: functionalBloc.customerFirstName);
    last = TextEditingController(text: functionalBloc.customerLastName);
    phone = TextEditingController(text: functionalBloc.customerPhoneNumber);


    return Scaffold(
        appBar: AppBar(
          title: Text('${functionalBloc.selectedLanguage == 'english' ? 'Billing Information' : '账单信息'}'),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios),
            onPressed: (){
              paymentBloc.setValue('resetPaymentMethod', false);
              Get.close(1);
            },
          ),
        ),
        resizeToAvoidBottomPadding: false,
        body: GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
          },
          child: ListView(
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
                        label: '${functionalBloc.selectedLanguage == 'english' ? 'First Name' : '名字'}',
                        controller: first,
                        useNumKeyboard: false,
                        validate: Validation.firstNameValidation,
                      ),
                      Input(
                        label: '${functionalBloc.selectedLanguage == 'english' ? 'Last Name' : '姓'}',
                        controller: last,
                        useNumKeyboard: false,
                        validate: Validation.lastNameValidation,
                      ),
                      Input(
                        label: '${functionalBloc.selectedLanguage == 'english' ? 'Phone Number' : '电话'}',
                        useNumKeyboard: true,
                        controller: phone,
                        validate: Validation.phoneValidation,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      !paymentBloc.sameAsDelivery? Column(
                        children: [
                          Input(
                            label: '${functionalBloc.selectedLanguage == 'english' ? 'Street' : '街名'}',
                            useNumKeyboard: false,
                            onSaved: (value){
                              street = value;
                            },
                            validate: Validation.streetValidation,
                          ),
                          Input(
                            label: '${functionalBloc.selectedLanguage == 'english' ? 'City' : '城市'}',
                            useNumKeyboard: false,
                              onSaved: (value){
                                city = value;
                              },
                            validate: Validation.cityValidation

                          ),
                          Input(
                            label: '${functionalBloc.selectedLanguage == 'english' ? 'Zip Code' : '邮政编码'}',
                            useNumKeyboard: true,
                            onSaved: (value){
                              zip = value;
                            },
                            validate: Validation.zipValidation,
                            inputFormatter: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(5),
                            ],
                          ),
                        ],
                      ) : Container(),
                      functionalBloc.deliveryAddress != '' ? CheckboxListTile(
                        title: Text('${functionalBloc.selectedLanguage == 'english' ? 'Same as Delivery Address' : '和送餐地址一样'}'),
                        value: paymentBloc.sameAsDelivery,
                        onChanged: (bool value) {
                          paymentBloc.setValue('sameAsDelivery',value);
                        },
                      ) : Container(),
                      CheckboxListTile(
                          title: Text('${functionalBloc.selectedLanguage == 'english' ? 'Save for Express Checkout' : '保存卡信息，方便快速下单'}'),
                          value: paymentBloc.saveCard,
                          onChanged: (value) {
                            paymentBloc.setValue('saveCard', value);
                          }),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Button(
                          onPressed: () {
                            if (_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              functionalBloc.setValue('billing', {
                                'firstName': first.text,
                                'lastName': last.text,
                                'phone': phone.text,
                                'street': street == ''
                                    ? functionalBloc.deliveryStreet
                                    : street,
                                'city': city == '' ? functionalBloc.deliveryCity : city,
                                'zip': zip == '' ? functionalBloc.deliveryZipCode : zip,
                              });

                              paymentBloc.payment(cartBloc, functionalBloc, cartBloc.total);
                              _formKey.currentState.reset();
                            }
                          },
                          title: '${functionalBloc.selectedLanguage == 'english' ? 'Proceed to Square Payment' : '前往 Square Payment'}',
                          color: Colors.red[400],
                        ),
                      ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
