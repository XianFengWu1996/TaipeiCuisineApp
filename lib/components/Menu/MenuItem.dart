import 'package:flutter/material.dart';
import 'package:food_ordering_app/Database/Database.dart';
import 'package:food_ordering_app/components/Cart/CartItem.dart';
import 'package:food_ordering_app/components//Menu/MenuData.dart';

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
                  var item = menuItem[index];
                  return Column(
                    children: <Widget>[
                      Card(
                        child: ListTile(
                          leading: Text('${item['food_id']}'),
                          title: Text(widget.displayChinese ? '${item['food_name_chinese']}' : '${item['food_name']}'),
                          subtitle: Text('\$ ${item['price']}'),
                          trailing: FlatButton(
                              child: Icon(Icons.add, size: 30,),
                              onPressed:() {
                                DatabaseProvider.db.insertData(
                                  CartItem(
                                    id: int.parse(item['id']),
                                    foodId: item['food_id'] ,
                                    foodName: item['food_name'],
                                    foodChineseName: item['food_name_chinese'],
                                    price: double.parse(item['price']) ,
                                    quantity: 1
                                  ),
                                );
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
