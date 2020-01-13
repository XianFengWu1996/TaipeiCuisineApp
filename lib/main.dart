import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Auth/Login.dart';
import 'package:food_ordering_app/screens/Auth/Signup.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:food_ordering_app/screens/menu/chicken.dart';
import 'package:food_ordering_app/components/FormComponents/PhoneVerification.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider.value(value: (FirebaseAuth.instance.onAuthStateChanged)),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.red[400],
          accentColor: Colors.redAccent,

        ),
        initialRoute: Login.id,
        routes: {
          Login.id : (context) => Login(),
          Signup.id : (context) => Signup(),
          Home.id : (context) => Home(),
          PhoneVerification.id : (context) => PhoneVerification(),
          Chicken.id : (context) => Chicken(),
        },
      ),
    );
  }
}

