import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/CartBloc.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/BloC/PaymentBloc.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutChoice.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/CheckoutSummary.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/OrderList.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/Address.dart';
import 'package:food_ordering_app/components/Chips.dart';
import 'package:food_ordering_app/components/Divider.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/Payment/PaymentModal.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/PersonInfo.dart';
import 'package:food_ordering_app/screens/Cart/Content/Checkout/components/Reward.dart';
import 'package:food_ordering_app/screens/Home.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CartBloc cartBloc = Provider.of<CartBloc>(context);
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    String _comment = '';


    return Scaffold(
      appBar: AppBar(
        title: Text('${functionalBloc.selectedValue == 'english' ?  'Checkout' : '结账 / 付款'}'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Get.offAll(Home());
            },
          )
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: functionalBloc.loading,
        child: Padding(
          padding: EdgeInsets.fromLTRB(5, 5, 5, 20),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              //Chip to choose pick up or delivery
              CheckoutChoice(),

              LineDivider(),

              //Cards for selecting the address and payments
              AddressCard(),

              PersonInfo(),

              LineDivider(),
              // The list of cart items
              OrderList(),

              LineDivider(),
              //Select the amount of reward point for redemption
              RewardInput(),

              LineDivider(),

              // Chips for selecting the amount of tips
              TipSelection(),

              LineDivider(),

              //Button for adding comments
              RaisedButton(onPressed: (){
                Get.defaultDialog(
                  title: '${functionalBloc.selectedValue == 'english' ? 'Add Comments' : '添加特殊要求'}',
                  content: TextFormField(
                    maxLines: 3,
                    initialValue: paymentBloc.comments,
                    onChanged: (value){
                      _comment = value;
                    },
                    decoration: InputDecoration.collapsed(
                        hintText: '${functionalBloc.selectedValue == 'english' ?
                              "Enter your comments here.            (Comments are subject to additional charge)"
                            : '请输入任何特殊要求(特殊要求可能需要收取额外费用)'}'
                        )
                    ,
                  ),
                  confirm: FlatButton(onPressed: (){
                    paymentBloc.getComments(_comment);
                    Get.off(CheckoutScreen());
                  },
                child: Text('${functionalBloc.selectedValue == 'english' ? 'Add' : '添加'}'),
                ));
              }, child: paymentBloc.comments == '' ?
                    Text('${functionalBloc.selectedValue == 'english' ? 'Add Comments' : '添加特殊要求'}')
                  : Text('${functionalBloc.selectedValue == 'english' ? 'Edit Comments' : '修改特殊要求'}'),),

              LineDivider(),

              //Summary of the order
              CheckoutSummary(),

              FlatButton(
                child: Text('${functionalBloc.selectedValue == 'english'? 'Proceed To Payment': '选择付款方式'}'),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 13),
                textColor: Colors.white,
                onPressed: () {
                  if(cartBloc.isDelivery){

                    if(cartBloc.address != ''){
                      if(paymentBloc.customerLastName != '' || paymentBloc.customerFirstName != ''||paymentBloc.customerPhoneNumber != ''){
                        if(cartBloc.tipPercent != 0.0 || cartBloc.tipPercent == .0000000001 || cartBloc.tipPercent == 0.0000001){
                          paymentBloc.getTotal(cartBloc.total);
                          showModalBottomSheet(
                              isDismissible: false,
                              context: context,
                              builder: (context) {
                                return PaymentModal();
                              });
                        } else {
                          Get.snackbar(functionalBloc.selectedValue == 'english'? 'Missing Tip for driver' : '未选择司机的小费',
                              functionalBloc.selectedValue == 'english' ?
                              'Please select tip for the driver, if you wish to pay in cash, select Cash.' :
                              '请选择给予司机的小费，如果你想选择给现金小费，选择现金',
                              backgroundColor: Colors.orange[300],
                              colorText: Colors.white);
                        }
                      } else {
                        Get.snackbar(functionalBloc.selectedValue == 'english' ? 'Missing Information' : '未填写个人信息',
                            functionalBloc.selectedValue == 'english' ?
                            'Please fillout the missing information. (Name, phone, or both)' :
                            '请填写您完整个人信息（姓名，电话，或者 姓名和电话）'
                            ,backgroundColor: Colors.orange[300], colorText: Colors.white);
                      }
                    } else {
                      Get.snackbar(functionalBloc.selectedValue == 'english' ? 'Missing Address' : '未填写地址',
                          functionalBloc.selectedValue == 'english' ?
                          'Missing delivery address, please provide your delivery address.' :
                          '未填写送餐地址，请填写您想送餐的地址',
                          backgroundColor: Colors.orange[300], colorText: Colors.white);
                    }

                  } else {
                    // Check list for pick up
                    if(paymentBloc.customerLastName != '' || paymentBloc.customerFirstName != ''||paymentBloc.customerPhoneNumber != ''){
                      paymentBloc.getTotal(cartBloc.total);
                      showModalBottomSheet(
                          isDismissible: false,
                          context: context,
                          builder: (context) {
                            return PaymentModal();
                          });
                    } else {
                      Get.snackbar(functionalBloc.selectedValue == 'english' ? 'Missing Information' : '未填写个人信息',
                          functionalBloc.selectedValue == 'english' ?
                          'Please fillout the missing information. (Name, phone, or both)' :
                          '请填写您完整个人信息（姓名，电话，或者 姓名和电话）'
                          ,backgroundColor: Colors.orange[300], colorText: Colors.white);                    }
                  }
                },
                color: Colors.red[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
