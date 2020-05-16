import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
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
    var cartBloc = Provider.of<CartBloc>(context);
    return cartBloc.isDelivery
        ? CheckoutCard(
            title: 'Deliver to',
            icon: FontAwesome.home,
            action: FlatButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddressDetails(
                      initStreet: cartBloc.street,
                      initCity: cartBloc.city,
                      initZip: cartBloc.zipCode,
                      initApt: cartBloc.apt,
                      initBusiness: cartBloc.businessName,
                    )));
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
  final initStreet;
  final initCity;
  final initZip;
  final initBusiness;
  final initApt;

  AddressDetails({this.initStreet, this.initCity, this.initZip, this.initBusiness, this.initApt});

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
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Address'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[

                Input(
                  initialValue: widget.initStreet,
                  label: 'Street',
                  validate: Validation.streetValidation,
                  onSaved: (value){
                    street = value;
                  },
                ),

                Input(
                  initialValue: widget.initCity,
                  label: 'City',
                  validate: Validation.cityValidation,
                  onSaved: (value){
                    city = value;
                  },
                ),

                Input(
                  initialValue: widget.initZip,
                  label: 'Zip Code',
                  validate: Validation.zipValidation,
                  useNumKeyboard: true,
                  inputFormatter: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  onSaved: (value){
                    zipCode = value;
                  },
                ),

                Input(
                  initialValue: widget.initApt,
                  label: 'Apt / Suite / Floor',
                  validate: null,
                  onSaved: (value){
                    apt = value;
                  },
                ),

                Input(
                  initialValue: widget.initBusiness,
                  label: 'Business or building name',
                  validate: null,
                  onSaved: (value){
                    businessName = value;
                  },
                ),

                FlatButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      functionalBloc.toggleLoading();
                      _formKey.currentState.save();
                      await cartBloc.saveAddress(authBloc.user.uid, street, city, zipCode, apt, businessName);
                      Navigator.pop(context);
                      functionalBloc.toggleLoading();
                    }
                  },
                  child: cartBloc.address == '' ? Text('Save') : Text('Update'),
                  color: Colors.red[400],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


