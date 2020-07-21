import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/ContactForm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PersonInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return CheckoutCard(
      title:
      '${functionalBloc.selectedLanguage == 'english' ? 'Name' : '姓名'}: '
          '${functionalBloc.customerFirstName == '' || functionalBloc.customerLastName == '' ?
      '${functionalBloc.selectedLanguage == 'english' ? 'Not Provided' : '未填写'}' :
      functionalBloc.customerFirstName + ' ' + functionalBloc.customerLastName
      }',
      subtitle:
      '${functionalBloc.selectedLanguage == 'english' ? 'Phone' : '电话'}: '
          '${functionalBloc.customerPhoneNumber == '' ? '${functionalBloc.selectedLanguage == 'english' ? 'Not Provider': '未填写'}' : functionalBloc.customerPhoneNumber}' ,
      icon: Icons.contact_phone,
      action: RaisedButton(onPressed: (){
        Get.to(ContactForm());
      }, child: Text('${functionalBloc.selectedLanguage == 'english'?'Edit': '更改'}'),),
    );
  }
}
