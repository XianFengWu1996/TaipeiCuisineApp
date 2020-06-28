import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/components/InputField.dart';
import 'package:TaipeiCuisine/components/Validation.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/CheckoutComponents.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class PersonInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return CheckoutCard(
      title:
      '${functionalBloc.selectedValue == 'english' ? 'Name' : '姓名'}: '
          '${paymentBloc.customerFirstName == '' || paymentBloc.customerLastName == '' ?
          '${functionalBloc.selectedValue == 'english' ? 'Not Provided' : '未填写'}' :
          paymentBloc.customerFirstName + ' ' + paymentBloc.customerLastName
      }',
      subtitle:
      '${functionalBloc.selectedValue == 'enlgish' ? 'Phone' : '电话'}: '
          '${paymentBloc.customerPhoneNumber == '' ? 'Not Provided' : paymentBloc.customerPhoneNumber}' ,
      icon: Icons.contact_phone,
      action: FlatButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => PersonInfoForm()));
      }, child: Text('${functionalBloc.selectedValue == 'english' ? 'Edit' : '更改' }')),
    );
  }
}

class PersonInfoForm extends StatefulWidget {

  @override
  _PersonInfoFormState createState() => _PersonInfoFormState();
}

class _PersonInfoFormState extends State<PersonInfoForm> {

  TextEditingController _firstName = TextEditingController();
  TextEditingController _lastName = TextEditingController();
  TextEditingController _phoneNumber = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();

    _firstName.dispose();
    _lastName.dispose();
    _phoneNumber.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${functionalBloc.selectedValue == 'english' ? 'Edit Information' : '修改个人信息'} '),
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
                  label: '${functionalBloc.selectedValue == 'english' ? 'First Name' : '名字'}',
                  validate: Validation.firstNameValidation,
                  controller: _firstName,
                ),
                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'Last Name' : '姓'}',
                  validate: Validation.lastNameValidation,
                  controller: _lastName,
                ),
                Input(
                  label: '${functionalBloc.selectedValue == 'english' ? 'Phone' : '电话号码'}',
                  useNumKeyboard: true,
                  validate: Validation.phoneValidation,
                  controller: _phoneNumber,
                ),

                FlatButton(
                  onPressed: () async {
                    if(_formKey.currentState.validate()) {
                      functionalBloc.toggleLoading('start');
                      await paymentBloc.saveCustomerInfo(
                        firstName: _firstName.text,
                        lastName: _lastName.text,
                        phone: _phoneNumber.text,
                      );
                      functionalBloc.toggleLoading('reset');
                      Navigator.pop(context);
                      _formKey.currentState.reset();
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

