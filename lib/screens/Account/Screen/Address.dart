import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/Address.dart';
import 'package:provider/provider.dart';

class Address extends StatelessWidget {
  static const id = 'address';
  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return AddressDetails(
      initStreet: functionalBloc.street,
      initCity: functionalBloc.city,
      initZip: functionalBloc.zipCode,
      initApt: functionalBloc.apt,
      initBusiness: functionalBloc.business,
    );
  }
}
