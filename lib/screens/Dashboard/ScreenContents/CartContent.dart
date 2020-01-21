import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/Database/Database.dart';
import 'package:food_ordering_app/components/Cart/CartItem.dart';

class CartContent extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: FutureBuilder(
            future: DatabaseProvider.db.readData(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.data != null){
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {

                      CartItem item = snapshot.data[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${item.foodId}. ${item.foodName}',
                                      style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600
                                      ),),
                                    SizedBox(height: 5,),
                                    Text('\$ ${item.price}')
                                  ],
                                ),
                              ),
                              SizedBox(width: 10,),
                              Row(
                                children: <Widget>[
                                  GestureDetector(
                                    child: Icon(
                                      FontAwesome.plus_circle,
                                      size: 32,
                                      color: Colors.red[400],
                                    ),
                                    onTap: () {
                                    },
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Icon(
                                    FontAwesome.minus_circle,
                                    size: 32,
                                    color: Colors.red[400],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return Text('Empty Cart');
              }
            }),
        ),
        Divider(
          height: 20,
          thickness: 1.2,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Container(
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Subtotal: \$39.99',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Tax: \$6.99',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Total: \$45.98',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                FlatButton(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  onPressed: () {

                  },
                  child: Text(
                    'Checkout',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  color: Colors.red[400],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
