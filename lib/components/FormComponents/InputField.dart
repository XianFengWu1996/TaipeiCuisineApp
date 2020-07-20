import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Input extends StatelessWidget {
  Input({
    this.initialValue,
    this.label,
    this.validate,
    this.controller,
    this.onSaved,
    this.inputFormatter,
    this.useNumKeyboard = false,
    this.obscureText = false,
    this.icon,
    this.autoFocus = false,
    this.textCap  = TextCapitalization.words,
    this.onChanged,
    this.suffix,
  });

  final String initialValue;
  final String label;
  final Function validate;
  final bool useNumKeyboard ;
  final Function onSaved;
  final TextEditingController controller;
  final inputFormatter;
  final bool obscureText;
  final Widget icon;
  final bool autoFocus;
  final TextCapitalization textCap;
  final Function onChanged;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        autofocus: autoFocus,
        validator: validate,
        initialValue: initialValue,
        controller: controller,
        textCapitalization: textCap,
        enableSuggestions: false,
        decoration: InputDecoration(
          suffixIcon: icon,
          suffix: suffix,
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          )
        ),
        onSaved: onSaved,
        autocorrect: false,
        inputFormatters: inputFormatter,
        keyboardType: useNumKeyboard ? TextInputType.number : TextInputType.text,
        obscureText: obscureText,
        onChanged: onChanged,
      ),
    );
  }
}
