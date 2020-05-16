import 'package:flutter/material.dart';

class AccountItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Function onTap;

  AccountItem({this.icon, this.title, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50,color: Colors.red[400],),
            SizedBox(height: 10,),
            Text('${title.toUpperCase()}', style: TextStyle(
                fontSize: 18,
              fontWeight: FontWeight.w600
            ),)
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
