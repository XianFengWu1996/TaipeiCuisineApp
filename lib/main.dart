import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/BloC/StoreBloc.dart';
import 'package:food_ordering_app/screens/Auth/Login/Login.dart';
import 'package:food_ordering_app/screens/Auth/Signup.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartBloc(),),
        ChangeNotifierProvider(create: (context) => AuthBloc(),),
        ChangeNotifierProvider(create: (context) => PaymentBloc(),),
        ChangeNotifierProvider(create: (context) => FunctionalBloc(),),
        ChangeNotifierProvider(create: (context) => StoreBloc()),
        StreamProvider.value(value: (FirebaseAuth.instance.onAuthStateChanged)),
      ],
      child: MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.red[400],
          accentColor: Colors.redAccent,
        ),
        initialRoute: Login.id,
        navigatorKey: Get.key,
        routes: {
          // Authenication pages
          Login.id: (context) => Login(),
          Signup.id: (context) => Signup(),
        },
      ),
    );
  }
}
