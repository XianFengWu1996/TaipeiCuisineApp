import 'package:TaipeiCuisine/components/Buttons/Button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:TaipeiCuisine/components/Helper/Validation.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Address extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var street, city, apt, businessName;

    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    CartBloc cartBloc = Provider.of<CartBloc>(context);

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
              padding: EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[

                  Input(
                    label: functionalBloc.selectedLanguage == 'english' ? 'Street' : '门牌号和街名',
                    validate: Validation.streetValidation,
                    initialValue: functionalBloc.deliveryStreet,
                    onSaved: (value){
                      street = value;
                    },
                  ),

                  Input(
                    label: functionalBloc.selectedLanguage == 'english' ? 'City' : '城市',
                    validate: Validation.cityValidation,
                    initialValue: functionalBloc.deliveryCity,
                    onSaved: (value){
                      city = value;
                    },
                  ),

                  Input(
                    label: functionalBloc.selectedLanguage == 'english' ? 'Zip Code' : '邮政编码',
                    validate: Validation.zipValidation,
                    useNumKeyboard: true,
                    inputFormatter: [
                      LengthLimitingTextInputFormatter(5),
                    ],
                    initialValue: functionalBloc.deliveryZipCode,
                  ),

                  Input(
                    label: functionalBloc.selectedLanguage == 'english' ? 'Apt / Suite/ Floor' : '公寓号 / 楼层',
                    validate: null,
                    initialValue: functionalBloc.deliveryApt,
                    onSaved: (value){
                      apt = value;
                    },
                  ),

                  Input(
                    label: functionalBloc.selectedLanguage == 'english' ? 'Businesses or Building Name' : '公司名称 / 建筑名称',
                    validate: null,
                    initialValue: functionalBloc.deliveryBusiness,
                    onSaved: (value){
                      businessName = value;
                    },
                  ),

                  Button(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        functionalBloc.setValue('loading','start');
                        _formKey.currentState.save();
                        var geoCodingAddress = await cartBloc.geoCoding(street, city);
                        print(geoCodingAddress);
                        var formatStreet = '${geoCodingAddress[2]} ${geoCodingAddress[3]}';

                        await cartBloc.saveAddress(formatStreet, geoCodingAddress[4], geoCodingAddress[5], apt, businessName, functionalBloc);
                        Navigator.pop(context);
                        _formKey.currentState.reset();

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
