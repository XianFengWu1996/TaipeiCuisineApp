import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/InputField.dart';
import 'package:food_ordering_app/components/Validation.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Address extends StatelessWidget {
  static const id = 'address';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var street, city, apt, businessName;

    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    CartBloc cartBloc = Provider.of<CartBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${functionalBloc.selectedValue == 'english' ? 'Address' : '送餐地址'}'),
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
                  label: functionalBloc.selectedValue == 'english' ? 'Street' : '门牌号和街名',
                  validate: Validation.streetValidation,
                  initialValue: functionalBloc.street,
                  onSaved: (value){
                    street = value;
                  },
                ),

                Input(
                  label: functionalBloc.selectedValue == 'english' ? 'City' : '城市',
                  validate: Validation.cityValidation,
                  initialValue: functionalBloc.city,
                  onSaved: (value){
                    city = value;
                  },
                ),

                Input(
                  label: functionalBloc.selectedValue == 'english' ? 'Zip Code' : '邮政编码',
                  validate: Validation.zipValidation,
                  useNumKeyboard: true,
                  inputFormatter: [
                    LengthLimitingTextInputFormatter(5),
                  ],
                  initialValue: functionalBloc.zipCode,
                ),

                Input(
                  label: functionalBloc.selectedValue == 'english' ? 'Apt / Suite/ Floor' : '公寓号 / 楼层',
                  validate: null,
                  initialValue: functionalBloc.apt,
                  onSaved: (value){
                    apt = value;
                  },
                ),

                Input(
                  label: functionalBloc.selectedValue == 'english' ? 'Businesses or Building Name' : '公司名称 / 建筑名称',
                  validate: null,
                  initialValue: functionalBloc.business,
                  onSaved: (value){
                    businessName = value;
                  },
                ),

                RaisedButton(
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      functionalBloc.toggleLoading('start');
                      _formKey.currentState.save();
                      var geoCodingAddress = await cartBloc.geoCoding(street, city);
                      var formatStreet = geoCodingAddress[2] + ' ' + geoCodingAddress[3];

                      await functionalBloc.saveAddress(formatStreet, geoCodingAddress[4], geoCodingAddress[5], apt, businessName);
                      Navigator.pop(context);
                      _formKey.currentState.reset();

                      functionalBloc.toggleLoading('reset');
                    }
                  },
                  child: Text('${functionalBloc.selectedValue == 'english' ? 'Save' : '保存'}'),
                  color: Colors.red[400],textColor: Colors.white,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
