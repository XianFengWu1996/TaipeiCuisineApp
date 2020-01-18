import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Menu/MenuData.dart';

class MenuItem extends StatefulWidget {
  final int index;
  final String title;
  final bool displayChinese;

  MenuItem({@required this.index, @required this.title, this.displayChinese});

  @override
  _MenuItemState createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  List menuItem = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  getData() async {
    var data = await MenuData().retrieveMenuData();
    for(var item in data[widget.index]['dishes']){
      setState(() {
        menuItem.add(item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),

      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                itemCount: menuItem.length,
                itemBuilder: (context, index){
                  return Column(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          leading: Text('${menuItem[index]['food_id']}'),
                          title: Text(widget.displayChinese ? '${menuItem[index]['food_name_chinese']}' : '${menuItem[index]['food_name']}'),
                          subtitle: Text('\$ ${menuItem[index]['price']}'),
                          trailing: FlatButton(
                              child: Icon(Icons.add, size: 30,),
                              onPressed:(){
                                print('add to cart');
                              },
                          ),
                        ),
                      ),

                    ],
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: FloatingActionButton(
            onPressed: (){},
            child: Icon(Icons.shopping_cart),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
