import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Auth/Login/Login.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Setting extends StatefulWidget {
  static const id = 'setting';
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  TextEditingController _password = TextEditingController();
  TextEditingController _confirmPassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    CartBloc cartBloc = Provider.of<CartBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${functionalBloc.selectedValue == 'english' ? 'Setting' : '设置'}'),
      ),
      body: Column(
        children: <Widget>[
          SettingItem(
            title: functionalBloc.selectedValue == 'english' ? 'Change Language' : '更改语言',
            icon: FontAwesome.language,
            onPressed: () {
              Get.to(ChangeLanguage());
            },
          ),
          SettingItem(
            title: functionalBloc.selectedValue == 'english' ? 'Change Password' : '更改密码',
            icon: Icons.lock,
            onPressed: (){
              Get.defaultDialog(
                title: '${functionalBloc.selectedValue == 'english' ? 'Change Password' : '更改密码'}',
                content: Container(
                  height: 130,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(
                          labelText: '${functionalBloc.selectedValue == 'english' ? 'New Password' : '新密码'}'
                        ),
                      ),
                      TextFormField(
                        controller: _confirmPassword,
                        decoration: InputDecoration(
                            labelText: '${functionalBloc.selectedValue == 'english' ? 'Confirm New Password' : '确认新密码'}',
                        ),
                      ),
                    ],
                  ),
                ),
                confirm: RaisedButton(onPressed: (){
                  if(_password.text == _confirmPassword.text){
                    functionalBloc.changePassword(
                      password: _password.text,
                      cart: cartBloc,
                      payment: paymentBloc,
                      auth: authBloc
                    );
                  } else {
                    Get.snackbar('Error', 'The password does not match', colorText: Colors.white, backgroundColor: Colors.orangeAccent[400]);
                  }
                }, child: Text('${functionalBloc.selectedValue == 'english' ? 'Change' : '更改'}'),color: Colors.red[400],textColor: Colors.white,),
                cancel: FlatButton(onPressed: (){
                  _password.clear();
                  _confirmPassword.clear();
                  Get.back();
                }, child: Text('${functionalBloc.selectedValue == 'english' ? 'Cancel' : '取消'}'), textColor: Colors.black,),
              );
            },
          ),
          SettingItem(
            title: functionalBloc.selectedValue == 'english' ? 'Logout' : '退出账号',
            icon: FontAwesome.sign_out,
            onPressed: (){
              Get.defaultDialog(
                title: functionalBloc.selectedValue == 'english' ? 'Logout' : '退出账号',
                content: Text('${functionalBloc.selectedValue == 'english' ? 'Do you want to log out?' : '确认退出账号'}'),
                confirm: RaisedButton(onPressed: (){
                  Get.offAll(Login());
                  functionalBloc.logout(authBloc: authBloc, paymentBloc: paymentBloc,cartBloc: cartBloc);
                }, child: Text('${functionalBloc.selectedValue == 'english' ? 'Yes' : '确认'}'), color: Colors.red[400]),

                cancel: FlatButton(onPressed: (){
                  Get.back();
                }, child: Text('${functionalBloc.selectedValue == 'english' ? 'Cancel' : '取消'}')
              ));
            },
          ),
        ],
      ),
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function onPressed;

  SettingItem({this.title, this.icon, this.onPressed});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: onPressed,
          child: ListTile(
            title: Text('$title'),
            trailing: Icon(Icons.arrow_forward_ios),
            leading: Icon(icon),
          ),
        ),
        LineDivider(),
      ],
    );
  }
}

class ChangeLanguage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${functionalBloc.selectedValue == 'english' ? 'Change Language' : '更改语言'}'),
      ),
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: Column(
          children: <Widget>[
            RadioListTile(
              value: 'english',
              groupValue: functionalBloc.selectedValue,
              title: Text('English'),
              onChanged: (value) {
                functionalBloc.changeSelectedValue(value);
              },
            ),
            RadioListTile(
              value: 'chinese',
              groupValue: functionalBloc.selectedValue,
              title: Text('简体中文'),
              onChanged: (value) {
                functionalBloc.changeSelectedValue(value);
              },
            ),

            RaisedButton(onPressed: () async{
              functionalBloc.toggleLoading('start');
              await functionalBloc.updateChoiceInDB();

            },
            child: Text('${functionalBloc.selectedValue == 'english' ? 'Switch' : '更改'}'), color: Colors.red[400],textColor: Colors.white,),
          ],
        ),
      ),
    );
  }
}



