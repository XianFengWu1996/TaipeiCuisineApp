import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/CartBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/screens/Auth/Login/Login.dart';
import 'package:TaipeiCuisine/screens/Auth/Signup.dart';
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
