import 'package:flutter/material.dart';

class PaymentChip extends StatelessWidget {
  PaymentChip({
    @required this.title,
    this.subtitle,
    this.icon,
    @required this.selected,
    @required this.onSelected,
    this.rewardPercent = '',
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Function onSelected;
  final String rewardPercent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10, left: 10, right: 10),
      child: ChoiceChip(
          label: subtitle == null
              ? ListTile(
                  title: Text(title),
                  leading: Icon(icon),
                  trailing: Text(rewardPercent),
                )
              : ListTile(
                  title: Text(title),
                  subtitle: Text(subtitle),
                  leading: Icon(icon),
                  trailing: Text(rewardPercent),
                ),
          shape: BeveledRectangleBorder(),
          selectedColor: Colors.redAccent[100],
          selected: selected,
          onSelected: onSelected),
    );
  }
}
