import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/components/CheckoutComponents/PageComponents/AddressInputField.dart';
import 'package:food_ordering_app/components/CheckoutComponents/Parts/CheckoutComponents.dart';
import 'package:food_ordering_app/screens/Auth/EmailPassword/Validation.dart';
import 'package:provider/provider.dart';

class Address extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var cartBloc = Provider.of<CartBloc>(context);
    return cartBloc.isDelivery
        ? CheckoutCard(
            title: 'Deliver to',
            icon: FontAwesome.home,
            action: FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddressDetails()));
              },
              child: cartBloc.address == '' ? Text('Add') : Text('Switch'),
            ),
            subtitle:
                cartBloc.address == '' ? 'Add an address' : cartBloc.address,
          )
        : Container();
  }
}

class AddressDetails extends StatefulWidget {
  @override
  _AddressDetailsState createState() => _AddressDetailsState();
}

class _AddressDetailsState extends State<AddressDetails> {

  String street;
  String city;
  String zipCode;
  String apt;
  String businessName;

  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var cartBloc = Provider.of<CartBloc>(context);
    var authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Text('Address'),

              AddressInput(
                initialValue: cartBloc.street,
                label: 'Street',
                validate: Validation.streetValidation,
                onSaved: (value){
                  street = value;
                },
              ),

              AddressInput(
                initialValue: cartBloc.city,
                label: 'City',
                validate: Validation.cityValidation,
                onSaved: (value){
                  city = value;
                },
              ),

              AddressInput(
                initialValue: cartBloc.zipCode,
                label: 'Zip Code',
                validate: Validation.zipValidation,
                onSaved: (value){
                  zipCode = value;
                },
                useNumKeyboard: true,
              ),

              AddressInput(
                initialValue: cartBloc.apt,
                label: 'Apt / Suite / Floor',
                validate: null,
                onSaved: (value){
                  apt = value;
                },
              ),

              AddressInput(
                initialValue: cartBloc.businessName,
                label: 'Business or building name',
                validate: null,
                onSaved: (value){
                  businessName = value;
                },
              ),

              FlatButton(
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    cartBloc.saveAddress(authBloc.user.uid, street, city, zipCode, apt, businessName);
                    Navigator.pop(context);
                  }
                },
                child: cartBloc.address == '' ? Text('Save') : Text('Update'),
                color: Colors.red[400],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Payment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CheckoutCard(
      title: 'Payment Method',
      subtitle: 'xx-4292',
      action: FlatButton(
        onPressed: () {
          print('pressed');
        },
        child: Text('Add'),
      ),
      icon: FontAwesome.credit_card,
    );
  }
}
