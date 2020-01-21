import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final bool isEmail;

  final Function validator;
  final Function onChanged;
  final String labelText;

  TextFieldInput({
    @required this.onChanged,
    @required this.labelText,
    @required this.isEmail,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      obscureText: isEmail ? false : true,
      decoration: InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
        ),
      ),
      onChanged: onChanged,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
    );
  }
}
