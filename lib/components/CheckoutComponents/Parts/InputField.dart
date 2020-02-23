import 'package:flutter/material.dart';

class Input extends StatelessWidget {
  Input({
    this.initialValue,
    this.label,
    this.validate,
    this.onSaved,
    this.useNumKeyboard = false,
  });

  final String initialValue;
  final String label;
  final Function validate;
  final Function onSaved;
  final bool useNumKeyboard ;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        validator: validate,
        initialValue: initialValue,
        textCapitalization: useNumKeyboard ? TextCapitalization.none : TextCapitalization.words,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
          )
        ),
        onSaved: onSaved,
        autocorrect: false,
        keyboardType: useNumKeyboard ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}
