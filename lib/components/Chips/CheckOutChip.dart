import 'package:flutter/material.dart';

class CheckoutChip extends StatelessWidget {
  CheckoutChip({this.choice, this.onSelected, this.title, this.icon});

  final bool choice;
  final Function onSelected;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ChoiceChip(
        labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        label: Text('$title'),
        labelStyle: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600,),
        selected: choice,
        selectedColor: Colors.red[400],
        avatar: Icon(
          icon,
          color: Colors.white,
        ),
        onSelected: onSelected,
      ),
    );
  }
}
