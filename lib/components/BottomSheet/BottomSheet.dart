import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/components/Buttons/Button.dart';
import 'package:TaipeiCuisine/components/FormComponents/InputField.dart';
import 'package:TaipeiCuisine/components/Helper/Validation.dart';
import 'package:get/get.dart';

class BottomSheetContent extends StatelessWidget {
  final String label;
  final String buttonText;
  final Function onPressed;
  final TextEditingController controller;


  BottomSheetContent({
    this.onPressed,
    this.label,
    this.buttonText,
    this.controller
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        BottomSheetHeader(title: label,
            height: 50,
            onPressed: (){
              Get.close(1);
            }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: <Widget>[
              Input(
                label: 'Enter your Email',
                validate: Validation.emailValidation,
                autoFocus: true,
                controller: controller,
              ),
              Button(
                title: 'Reset',
                color: Colors.red[400],
                textColor: Colors.white,
                textSize: 18,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ],
    );
  }
}



class BottomSheetHeader extends StatelessWidget {
  final Function onPressed;
  final String title;
  final String subtitle;
  final double height;

  BottomSheetHeader({@required this.title, this.subtitle = '', @required this.onPressed, this.height = 70});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: height,
        color: Colors.grey[200],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
                icon: Icon(Icons.close),
                onPressed: onPressed
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  '$title',
                  style: subtitle != '' ? TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400)
                      : TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                subtitle != '' ? Text(
                  subtitle,
                  style: TextStyle(
                      fontSize: 25, fontWeight: FontWeight.w600),
                ) : Container(),
              ],
            ),
            Text(''),
            Text(''),
          ],
        ));
  }
}
