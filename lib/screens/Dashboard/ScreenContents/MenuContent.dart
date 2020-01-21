import 'package:flutter/material.dart';
import 'package:food_ordering_app/components//Menu/MenuData.dart';
import 'package:food_ordering_app/components//Menu/MenuItem.dart';

class MenuContent extends StatefulWidget {
  @override
  _MenuContentState createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {

  List<String> category = [];
  List<String> chineseCategory = [];
  bool chinese = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getCategory();
    getChineseCategory();
  }

  void getCategory() async {
    var data = await MenuData().retrieveCategory();
    for(var item in data[0]['category']){
      setState(() {
        category.add(item);
      });
    }
  }

  void getChineseCategory() async {
    var data = await MenuData().retrieveChineseCategory();
    for(var item in data[0]['category_chinese']){
      setState(() {
        chineseCategory.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('EN'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Transform.scale(
                scale: 1.5,
                child: Switch(
                  value: chinese,
                  onChanged: (value){
                    setState(() {
                      chinese = value;
                    });
                  },
                  inactiveThumbImage: AssetImage('images/united-states.png'),
                  activeThumbImage: AssetImage('images/china.png'),
                ),
              ),
            ),
            Text('中'),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: category.length,
              itemBuilder: (context, index){
                return FlatButton(
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MenuItem(
                              index: index,
                              title: chinese ? chineseCategory[index] : category[index],
                              displayChinese: chinese
                            ),
                        ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      trailing: Icon(Icons.arrow_forward_ios),
                      title: Text(
                        chinese ? '${chineseCategory[index]}' : '${category[index]}'
                      ),),
                  ),
                );
              }
          ),
        ),
      ],
    );
  }
}

//"Icon made by Freepik from www.flaticon.com"