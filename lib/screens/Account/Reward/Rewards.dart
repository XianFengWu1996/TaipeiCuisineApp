import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/components/CheckoutComponents/Parts/CheckoutDivider.dart';
import 'package:food_ordering_app/screens/Reward/components/RewardCard.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Reward extends StatelessWidget {
  static const id = 'reward';
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Rewards'),
        ),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('users/${authBloc.user.uid}/rewards')
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                QuerySnapshot qs = snapshot.data;
                if (qs.documents.isNotEmpty) {
                  var data = qs.documents[0];
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text('Reward Points'),
                              Text('${data['point']}',
                                style: TextStyle(fontSize: 50, color: Colors.red[400]),
                              ),
                              CheckoutDivider(),
                          Container(
                            height: 570,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: data['pointDetails'].length,
                                itemBuilder: (context, index){
                                  return RewardCard(
                                    action: data['pointDetails'][index]['action'],
                                    amount: data['pointDetails'][index]['amount'],
                                    createdAt: data['pointDetails'][index]['createdAt'],
                                    orderId: data['pointDetails'][index]['orderId'],
                                    method: data['pointDetails'][index]['method'],
                                  );
                                }
                            ),
                          )
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                } else{
                  return Center(
                    child: Text('No reward history'),
                  );
                }
              } else {
                return Center(
                  child: Text('No reward history'),
                );
              }
            }));
  }
}
