import 'dart:async';

import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class VerificationPinField extends StatefulWidget {


  @override
  _VerificationPinFieldState createState() => _VerificationPinFieldState();
}

class _VerificationPinFieldState extends State<VerificationPinField> {
  StreamController<ErrorAnimationType> errorController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
  }

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    TextEditingController _pinField = TextEditingController();

    return PinCodeTextField(
      autoDisposeControllers: true,
      length: 4,
      textInputType: TextInputType.number,
      obsecureText: false,
      animationType: AnimationType.fade,
      errorAnimationController: errorController,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        fieldHeight: 50,
        fieldWidth: 65,
        activeFillColor: Colors.white,
      ),
      animationDuration: Duration(milliseconds: 300),
      controller: _pinField,
      onChanged: (value){},
      onCompleted: (v) {
        if(v == functionalBloc.smsCode) {
          functionalBloc.setValue('verification', false);
          functionalBloc.setValue('showPinField', false);
          functionalBloc.setValue('successful', true);
          functionalBloc.setValue('allowResend', false);
          functionalBloc.setValue('countFinished', true);
        } else {
          errorController.add(ErrorAnimationType.shake);
        }
      },
      beforeTextPaste: (text) {
        return false;
      },
    );
  }
}
