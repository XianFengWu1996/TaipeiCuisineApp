import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/AuthBloc.dart';
import 'package:food_ordering_app/screens/Order/components/OrderCard.dart';
import 'package:provider/provider.dart';

class OrderStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthBloc authBloc = Provider.of<AuthBloc>(context);
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
              height: 650,
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
            return Text('No past order');
          }
        } else {
          return Text('No past order');
        }
      },
    );
  }
}
