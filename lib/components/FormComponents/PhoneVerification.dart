import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:pin_entry_text_field/pin_entry_text_field.dart';

class PhoneVerification extends StatefulWidget {
  static const id = 'phone_verification';
  @override
  _PhoneVerificationState createState() => _PhoneVerificationState();
}

class _PhoneVerificationState extends State<PhoneVerification> {
  String phoneNumber;
  String smsCode;
  String verificationId;

  final _formKey = GlobalKey<FormState>();
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Verification'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: PhoneContent(
          formKey: _formKey,
          onPressed: () async {
            final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String id) {
              verificationId = id;
            };

            final PhoneCodeSent smsCodeSent =
                (String id, [int forceCodeResend]) {
              verificationId = id;
            };

            final PhoneVerificationCompleted verifiedSuccess =
                (AuthCredential credential) {
              print(credential);
            };

            final PhoneVerificationFailed verifiedFailed = (e) {
              print('error ' + e.message);
            };

            if (_formKey.currentState.validate()) {
              await _auth.verifyPhoneNumber(
                phoneNumber: '+1' + phoneNumber,
                timeout: Duration(minutes: 1),
                verificationCompleted: verifiedSuccess,
                verificationFailed: verifiedFailed,
                codeSent: smsCodeSent,
                codeAutoRetrievalTimeout: autoRetrieve,
              );

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'SMS Verification',
                            style: TextStyle(fontSize: 23),
                          ),
                          PinEntryTextField(
                            fields: 6,
                            fieldWidth: 30.0,
                            fontSize: 15.0,
                            onSubmit: (value) {
                              smsCode = value;
                            },
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () async {
                              FirebaseUser user =
                                  (await _auth.signInWithCredential(
                                PhoneAuthProvider.getCredential(
                                  verificationId: verificationId,
                                  smsCode: smsCode,
                                ),
                              )).user;
                              if(user != null){
                                print(user);
                                Navigator.pushReplacementNamed(context, Home.id);
                              }
                            },
                            child: Text('Verify'))
                      ],
                    );
                  });
            }
          },
          onChanged: (value) {
            phoneNumber = value;
          },
        ),
      ),
    );
  }
}

class PhoneContent extends StatelessWidget {
  final Function onChanged;
  final Function onPressed;

  const PhoneContent({
    this.onPressed,
    this.onChanged,
    @required GlobalKey<FormState> formKey,
  }) : _formKey = formKey;

  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Form(
          key: _formKey,
          autovalidate: true,
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Phone Number",
              labelStyle: TextStyle(
                fontSize: 20,
              ),
              helperText: "The phone number should be 10 digits",
              prefixIcon: Icon(Icons.phone),
            ),
            onChanged: onChanged,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value.isEmpty) {
                return "Phone number can not be empty";
              }

              if (value.length < 10) {
                return "Enter a valid phone number";
              }
            },
          ),
        ),
        SizedBox(
          height: 30,
        ),
        RaisedButton(
          onPressed: onPressed,
          shape: CircleBorder(),
          elevation: 2.0,
          color: Colors.red[400],
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Text(
                'Next',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
