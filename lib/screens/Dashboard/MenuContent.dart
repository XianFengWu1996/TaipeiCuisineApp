import 'dart:convert';
import 'package:flutter/material.dart';

class MenuContent extends StatefulWidget {
  @override
  _MenuContentState createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {
  List category = [];
  List dishes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getMenu();
  }

  getMenu() async {
    String data = await DefaultAssetBundle.of(context)
        .loadString("assets/menu_data.json");
    final json = await jsonDecode(data);

    for (int i = 0; i < json.length; i++) {
      setState(() {
        category.add(json[i]['category']);
        dishes.add(json[i]['dishes']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: category.length,
      itemBuilder: (BuildContext context, int index) {
        return FlatButton(
          onPressed: () {
            Navigator.pushNamed(context, category[index]);
          },
          child: ListTile(
            title: (Text(
              '${category[index]}',
              style: TextStyle(color: Colors.black),
            )),
          ),
        );
      },
    );
  }
}
