import 'package:TaipeiCuisine/screens/Account/Screen/Reward/components/RewardCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/components/Divider/Divider.dart';
import 'package:provider/provider.dart';

class Reward extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('${functionalBloc.selectedLanguage == 'english' ? 'Rewards' : '积分回馈'}'),
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
                        padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Text('${functionalBloc.selectedLanguage == 'english' ? 'Reward Points' : '获得积分'}'),
                              Text('${data['point']}',
                                style: TextStyle(fontSize: 50, color: Colors.red[400]),
                              ),
                              LineDivider(),
                          Container(
                            height: MediaQuery.of(context).size.height - 200,
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
                    child: Text('${functionalBloc.selectedLanguage == 'english' ? 'No Reward History' : '尚未获得积分'}'),
                  );
                }
              } else {
                return Center(
                  child: Text('${functionalBloc.selectedLanguage == 'english' ? 'No Reward History' : '尚未获得积分'}'),
                );
              }
            }));
  }
}
