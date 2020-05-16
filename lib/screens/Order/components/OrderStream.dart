import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_ordering_app/screens/Order/components/OrderCard.dart';

class OrderStream extends StatelessWidget {
  final String uid;
  final String status;
  final String emptyStatus;

  OrderStream({this.uid, this.status, this.emptyStatus});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
            .collection('users/$uid/order')
          .where('status', isEqualTo: '$status')
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
                    status: ds[index]['status'],
                    data: ds[index],
                  );
                },
              ),
            );
          } else {
            return Text('$emptyStatus');
          }
        } else {
          return Text('$emptyStatus');
        }
      },
    );
  }
}
