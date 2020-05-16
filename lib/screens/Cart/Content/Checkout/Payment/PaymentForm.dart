import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/InputField.dart';
import 'package:food_ordering_app/screens/Auth/EmailPassword/Validation.dart';
import 'package:provider/provider.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';

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
    var cartBloc = Provider.of<CartBloc>(context);
    var authBloc = Provider.of<AuthBloc>(context);
    var paymentBloc = Provider.of<PaymentBloc>(context);

    final _formKey = GlobalKey<FormState>();
    return Scaffold(
        appBar: AppBar(
          title: Text('Billing Information'),
        ),
        resizeToAvoidBottomPadding: false,
        body: Form(
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
                  label: 'First Name',
                  controller: first,
                  useNumKeyboard: false,
                  validate: Validation.firstNameValidation,
                ),
                Input(
                  label: 'Last Name',
                  controller: last,
                  useNumKeyboard: false,
                  validate: Validation.lastNameValidation,
                ),
                Input(
                  label: 'Phone Number',
                  useNumKeyboard: true,
                  controller: phone,
                  validate: Validation.phoneValidation,
                  inputFormatter: [
                    WhitelistingTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                cartBloc.isDelivery
                    ? CheckboxListTile(
                  title: Text('Same as Delivery Address'),
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
                      label: 'Street',
                      useNumKeyboard: false,
                      controller: street,
                      validate: !paymentBloc.sameAsDelivery ? Validation.streetValidation : null,
                    ),
                    Input(
                      label: 'City',
                      useNumKeyboard: false,
                      controller: city,
                      validate: !paymentBloc.sameAsDelivery ? Validation.cityValidation : null,
                    ),
                    Input(
                      label: 'Zip Code',
                      useNumKeyboard: true,
                      controller: zip,
                      validate: !paymentBloc.sameAsDelivery ? Validation.zipValidation : null,
                    ),
                  ],
                )
                    : Container(),
                CheckboxListTile(
                    title: Text('Save card to wallet'),
                    value: paymentBloc.saveCard,
                    onChanged: (value) {
                      paymentBloc.checkSaveCard(value);
                    }),
                FlatButton(
                  onPressed: () {
                    if(_formKey.currentState.validate()){

                      paymentBloc.saveBillingInfo(
                        first: first.text,
                        last: last.text,
                        phone: phone.text,
                        email: authBloc.user.email,
                        street: street.text == '' ? cartBloc.street : street.text,
                        city: city.text == '' ? cartBloc.city : city.text,
                        zip: zip.text == '' ? cartBloc.zipCode : zip.text,
                      );

                      paymentBloc.payment(cartBloc, double.parse(cartBloc.total));
                    }
                  },
                  child: Text('Proceed to Square Payment'),
                  color: Colors.red[400],
                ),
              ],
            ),
          ),
        ));
  }
}
