import 'package:flutter/material.dart';

class PasswordInput extends StatelessWidget {

  final bool showPassword;
  final Function onChanged;
  final String labelText;

  PasswordInput({@required this.showPassword, @required this.onChanged, this.labelText = "Enter Password"});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: !showPassword,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
        ),
      ),
      onChanged: onChanged,
    );
  }
}