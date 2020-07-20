import 'package:TaipeiCuisine/components/Buttons/Rectangular.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:TaipeiCuisine/components/Helper/Validation.dart';
import 'package:TaipeiCuisine/components/FormComponents/DividerWithText.dart';
import 'package:TaipeiCuisine/screens/Auth/SocialMediaLogin.dart';
import 'package:TaipeiCuisine/components/FormComponents/TextWithLink.dart';
import 'package:TaipeiCuisine/screens/Auth/Login.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class Signup extends StatefulWidget {
  static const id = 'signup_screen';

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);


    return Scaffold(
      body: GestureDetector(
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: ModalProgressHUD(
          inAsyncCall: functionalBloc.loading,
          child: SafeArea(
            child: Padding(
              padding:
              EdgeInsets.only(left: 20, right: 20),
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Container(
                      child: Image.asset('images/blacklogo.png'),
                      height: 180.0,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Input(
                            label: 'Enter Email',
                            controller: _emailController,
                            validate: Validation.emailValidation,
                          ),
                          Input(
                            label: 'Enter Password',
                            controller: _passwordController,
                            obscureText: !authBloc.obscureText,
                            validate: Validation.passwordValidation,
                            textCap: TextCapitalization.none,
                            icon: IconButton(
                                icon: Icon(!authBloc.obscureText
                                    ? FontAwesome.lock
                                    : FontAwesome.unlock),
                                onPressed: () {
                                  authBloc.setValue('showPass', !authBloc.obscureText);
                                }),
                          ),
                          Input(
                            label: 'Confirm Password',
                            controller: _confirmController,
                            obscureText: !authBloc.obscureText,
                            validate: Validation.passwordValidation,
                            textCap: TextCapitalization.none,
                            icon: IconButton(
                                icon: Icon(!authBloc.obscureText
                                    ? FontAwesome.lock
                                    : FontAwesome.unlock),
                                onPressed: () {
                                  authBloc.setValue('showPass', !authBloc.obscureText);
                                }),
                          ),

                          // Login with Email and Password
                          RoundRectangularButton(
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                if(_passwordController.text == _confirmController.text){
                                  // loading here will be true
                                  functionalBloc.setValue('loading','start');
                                  await authBloc.signUpWithEmailAndPassword(_emailController.text, _passwordController.text);
                                }

                                if(authBloc.errorMessage.isNotEmpty){
                                  Get.snackbar('Warning',
                                    authBloc.errorMessage[0],
                                    backgroundColor: Colors.red[400],
                                    colorText: Colors.white,
                                  );
                                  Future.delayed(Duration(seconds: 1), () {
                                    authBloc.setValue('errMsg', []);
                                    // when the error shows we stop the loading
                                    functionalBloc.setValue('loading','reset');
                                  });
                                } else {
                                  // when the sign up is successful, we stop loading
                                  functionalBloc.setValue('loading','reset');
                                  Get.to(Login());

                                  Get.snackbar('Notice',
                                      authBloc.noticeMessage[0],
                                    backgroundColor: Colors.green[400],
                                    colorText: Colors.white,
                                  );
                                }
                              }
                            },
                            title: 'Sign Up',
                            color: Colors.red[400],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    DividerWithText(),
                    SocialMediaLogin(),
                    TextWithLink(
                      textTitle: 'Already have an account? ',
                      linkTitle: 'Sign in here',
                      onPressed: () {
                        Navigator.pushNamed(context, Login.id);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
