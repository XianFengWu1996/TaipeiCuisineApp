import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:TaipeiCuisine/BloC/PaymentBloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class Comments extends StatefulWidget {
  @override
  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  TextEditingController _comments;
  @override
  Widget build(BuildContext context) {
    PaymentBloc paymentBloc = Provider.of<PaymentBloc>(context);
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    _comments = TextEditingController(text: paymentBloc.comments);


    return RaisedButton(onPressed: (){
      Get.defaultDialog(
          title: '${functionalBloc.selectedLanguage == 'english' ? 'Add Comments' : '添加特殊要求'}',
          content: TextFormField(
            maxLines: 3,
            controller: _comments,
            decoration: InputDecoration.collapsed(
                hintText: '${functionalBloc.selectedLanguage == 'english' ?
                "Enter your comments here.            (Comments are subject to additional charge)"
                    : '请输入任何特殊要求(特殊要求可能需要收取额外费用)'}'
            )
            ,
          ),
          confirm: FlatButton(onPressed: (){
            paymentBloc.setValue('getComments', _comments.text);
            Get.close(1);
          },
            child: Text('${functionalBloc.selectedLanguage == 'english' ? 'Add' : '添加'}'),
          ));
    }, child: paymentBloc.comments == '' ?
    Text('${functionalBloc.selectedLanguage == 'english' ? 'Add Comments' : '添加特殊要求'}')
        : Text('${functionalBloc.selectedLanguage == 'english' ? 'Edit Comments' : '修改特殊要求'}'),);
  }
}
