import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Account/Reward/components/RewardCard.dart';
import 'package:provider/provider.dart';

class Reward extends StatelessWidget {
  static const id = 'reward';
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('${functionalBloc.selectedValue == 'english' ? 'Rewards' : '积分回馈'}'),
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
                              Text('${functionalBloc.selectedValue == 'english' ? 'Reward Points' : '获得积分'}'),
                              Text('${data['point']}',
                                style: TextStyle(fontSize: 50, color: Colors.red[400]),
                              ),
                              LineDivider(),
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
                    child: Text('${functionalBloc.selectedValue == 'english' ? 'No Reward History' : '尚未获得积分'}'),
                  );
                }
              } else {
                return Center(
                  child: Text('${functionalBloc.selectedValue == 'english' ? 'No Reward History' : '尚未获得积分'}'),
                );
              }
            }));
  }
}
