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
        labelPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
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

class CheckoutCard extends StatelessWidget {

  CheckoutCard({this.title, this.subtitle, this.action, this.icon});

  final String title;
  final String subtitle;
  final String action;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$title'),
        subtitle: Text('$subtitle'),
        trailing: Text('$action'),
        leading: Icon(icon),
      ),
    );
  }
}

class CheckoutTip extends StatelessWidget {

  CheckoutTip({this.labelText, this.onSelected, this.tipAmount});

  final String labelText;
  final Function onSelected;
  final bool tipAmount;


  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text('$labelText'),
      selected: tipAmount,
      disabledColor: Colors.grey[400],
      selectedColor: Colors.red[400],
      onSelected: onSelected,
      labelStyle: TextStyle(color: Colors.black),
    );
  }
}

class CheckoutSummaryItems extends StatelessWidget {

  CheckoutSummaryItems({this.title, this.details});

  final String title;
  final String details;

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('$title :'),
        Text('$details')
      ],
    );
  }
}



