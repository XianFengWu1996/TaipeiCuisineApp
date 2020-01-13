import 'package:flutter/material.dart';

class EmailInput extends StatelessWidget {

  final Function onChanged;

  EmailInput({@required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: "Enter Email",
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      onChanged: onChanged,
    );
  }
}