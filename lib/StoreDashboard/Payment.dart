import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Menubar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class ProcessPayment extends StatefulWidget {
  @override
  _ProcessPaymentState createState() => _ProcessPaymentState();
}

class _ProcessPaymentState extends State<ProcessPayment> {
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Process Payment'),
      ),
      drawer: MenuBar(),
      body: ModalProgressHUD(
        inAsyncCall: _loading,
        child: Column(
          children: [
            RaisedButton(onPressed: () async{
              // retrieve the unprocessed payment id from database
              _loading = true;
              try{
                await storeBloc.completePayment(token: functionalBloc.squareToken, paymentEndpoint: functionalBloc.paymentEndPoint);
                _loading = false;
              } catch(e){
                _loading = false;
                Get.snackbar('出错', '出现了错误');
              }
            },
            child: Text('Complete Payment'),),
          ],
        ),
      ),
    );
  }
}
