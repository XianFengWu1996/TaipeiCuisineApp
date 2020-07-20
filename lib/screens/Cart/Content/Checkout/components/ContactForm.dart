import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/components/Buttons/Button.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:TaipeiCuisine/components/Helper/Validation.dart';
import 'package:TaipeiCuisine/screens/Cart/Content/Checkout/components/VerificationPinField.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

class ContactForm extends StatefulWidget {
  @override
  _ContactFormState createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();

  String _firstName ;
  String _lastName;
  String _phoneNumber;

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${functionalBloc.selectedLanguage == 'english' ? 'Edit Information' : '修改个人信息'} '),
        leading: Container(),
      ),
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ModalProgressHUD(
          inAsyncCall: functionalBloc.loading,
          child: ListView(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                      Input(
                        label: '${functionalBloc.selectedLanguage == 'english' ? 'First Name' : '名字'}',
                        validate: Validation.firstNameValidation,
                        initialValue: functionalBloc.customerFirstName,
                        onSaved: (value){
                            _firstName = value;
                        },
                      ),
                      Input(
                        label: '${functionalBloc.selectedLanguage == 'english' ? 'Last Name' : '姓'}',
                        validate: Validation.lastNameValidation,
                        initialValue: functionalBloc.customerLastName,
                        onSaved: (value){
                            _lastName = value;
                        },
                      ),

                      Text('${functionalBloc.selectedLanguage == 'english' ?
                      'New Phone Number requires SMS verification' : '新的电话号码需要短信验证'}'),
                      SizedBox(
                        height: 10,
                      ),
                      Input(
                        label: '${functionalBloc.selectedLanguage == 'english' ? 'Phone' : '电话号码'}',
                        useNumKeyboard: true,
                        validate: Validation.phoneValidation,
                        inputFormatter: [
                          WhitelistingTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        initialValue: functionalBloc.customerPhoneNumber,
                        suffix: functionalBloc.requireVerification ?
                        RaisedButton(
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onPressed: () async{
                            if(functionalBloc.requireVerification && !functionalBloc.allowResend){
                              functionalBloc.initializeVerification(_phoneNumber);
                            }
                            if(functionalBloc.allowResend){
                              functionalBloc.resendCode(_phoneNumber);
                            }
                          },
                          child:
                          // change the child base on the condition
                          functionalBloc.countFinished ?
                          Text('${functionalBloc.allowResend ?
                          '${functionalBloc.selectedLanguage == 'english' ? 'Resend' : '重发'}' :
                          '${functionalBloc.selectedLanguage == 'english' ? 'Verify' : '验证'}'}') :
                          RaisedButton(onPressed: (){},
                            child: functionalBloc.allowResend ?  Text('${functionalBloc.selectedLanguage == 'english' ? 'Resend' : '重发'}')
                                : Countdown(seconds: 5,
                              build: (_, double time)=> Text('${time.toInt()}'),
                              onFinished: (){
                                functionalBloc.setValue('countFinished', true);
                                functionalBloc.setValue('allowResend', true);
                              },),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          padding: EdgeInsets.all(0),
                          color: functionalBloc.allowResend ? Colors.green[400] : Colors.deepOrange[400],
                          textColor: Colors.white,
                        ) : Text('') ,
                        onChanged: (value){
                          setState(() {
                            if(value != functionalBloc.customerPhoneNumber && value.length == 10){
                              if(!functionalBloc.verifiedNumbers.contains(value)){
                                functionalBloc.setValue('verification', true);
                                print(functionalBloc.requireVerification);
                              }
                            } else {
                              functionalBloc.setValue('verification', false);
                              functionalBloc.setValue('allowResend', false);
                              functionalBloc.setValue('showPinField', false);
                              functionalBloc.setValue('successful', false);
                            }
                            _phoneNumber = value;
                          });
                        },
                      ),


                      functionalBloc.showPinField ? VerificationPinField() : Container(),
                      !functionalBloc.countFinished ? Text('${functionalBloc.selectedLanguage == 'english' ?
                      '(Please allow two minutes to resend code)' : '（两分钟后可以重新发送验证码）'} ') : Container(),
                      functionalBloc.successful ?
                      Text('Successfully Verified', style: TextStyle(
                          color: Colors.green,
                          fontSize: 18
                      ),) :
                      Container(),
                      SizedBox(
                        height: functionalBloc.showPinField || functionalBloc.successful? 10 : 0,
                      ),
                      Button(
                        onPressed: !functionalBloc.requireVerification
                            ? () async {
                          _formKey.currentState.save();

                          if (_formKey.currentState.validate()) {

                            if (functionalBloc.customerPhoneNumber != _phoneNumber ||
                                functionalBloc.customerFirstName != _firstName||
                                functionalBloc.customerLastName != _lastName) {
                              if (functionalBloc.successful) {
                                functionalBloc.setValue('resetSMS', false);
                              }

                              functionalBloc.setValue('loading', 'start');
                              await paymentBloc.saveCustomerInfo(
                                  firstName: _firstName,
                                  lastName: _lastName,
                                  phone: _phoneNumber,
                                  functionalBloc: functionalBloc);
                              _formKey.currentState.reset();
                              functionalBloc.setValue('loading', 'reset');
                              Get.close(1);
                            } else {
                              Get.close(1);
                            }
                          }
                        } : null,
                        title:
                        '${functionalBloc.selectedLanguage == 'english' ? 'Save' : '保存'}',
                        color: Colors.red[400],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
