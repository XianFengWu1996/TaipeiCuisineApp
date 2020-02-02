import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/screens/Auth/Login.dart';
import 'package:food_ordering_app/screens/Auth/Signup.dart';
import 'package:food_ordering_app/screens/Dashboard/Home.dart';
import 'package:food_ordering_app/screens/Auth/OtherSigninMethods/PhoneVerification.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartBloc()),
        ChangeNotifierProvider(create: (context)  => AuthBloc()),
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
          // Dashboard page after users are verified
          Home.id : (context) => Home(),

          // Authenication pages
          Login.id : (context) => Login(),
          Signup.id : (context) => Signup(),
          PhoneVerification.id : (context) => PhoneVerification(),

        },
      ),
    );
  }
}

