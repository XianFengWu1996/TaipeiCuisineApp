import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/screens/Order/components/OrderCard.dart';
import 'package:provider/provider.dart';

class OrderStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return StreamBuilder(
      stream: Firestore.instance
            .collection('users/${authBloc.user.uid}/order')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot){
        if (snapshot.hasData) {
          List<DocumentSnapshot> ds = snapshot.data.documents;
          ds.sort((a, b) {
            return b['createdAt'].compareTo(a['createdAt']);
          });
          if (ds.isNotEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height - 10,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: ds.length,
                itemBuilder: (context, index) {
                  return OrderCard(
                    orderId: ds[index]['orderId'],
                    itemTotal: ds[index]['total'],
                    itemCount: ds[index]['totalCount'],
                    createdAt: ds[index]['createdAt'],
                    data: ds[index],
                  );
                },
              ),
            );
          } else {
            return Center(child: Text('${functionalBloc.selectedLanguage == 'english' ? 'Try order something first' : '请先下单再来查看'}'));
          }
        } else {
          return Center(child: Text(''));
        }
      },
    );
  }
}
