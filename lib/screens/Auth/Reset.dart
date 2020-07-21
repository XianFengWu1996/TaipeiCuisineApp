import 'package:TaipeiCuisine/BloC/FunctionalBloc.dart';
import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/components/BottomSheet/BottomSheet.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class ResetPass extends StatelessWidget {
  final TextEditingController resetEmailController;
  final AuthBloc authBloc;

  ResetPass({this.resetEmailController, this.authBloc});

  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          child: Text(
            '${functionalBloc.loginLanguage == 'english' ? 'Reset Password': '忘记密码'}',
            style: TextStyle(
              color: Colors.blue,
            ),
          ),
          onPressed: () {
            MediaQuery.of(context).size.height < 812
                ? showBottomSheet(
                  context: context,
                  builder: (context) {
                    return BottomSheetContent(
                      label: '${functionalBloc.loginLanguage == 'english' ? 'Reset Password': '忘记密码'}',
                      buttonText: '${functionalBloc.loginLanguage == 'english' ? 'Reset': '发送邮件'}',
                      controller: resetEmailController,
                      onPressed: () async {
                        await authBloc.resetPasswordWithEmail(
                            resetEmailController.text,
                          functionalBloc
                        );

                        Navigator.pop(context);

                        resetEmailController.clear();

                        if (authBloc.noticeMessage.isNotEmpty) {
                          Get.snackbar(
                            '${functionalBloc.loginLanguage == 'english' ? 'Check Your Email': '请到邮箱里查找密码重置的邮件'}',
                            authBloc.noticeMessage[0],
                            backgroundColor: Colors.green[400],
                            colorText: Colors.white,
                          );
                          Future.delayed(Duration(seconds: 1), () {
                            authBloc.setValue('errMsg', []);
                          });
                        }

                        if (authBloc.errorMessage.isNotEmpty) {
                          Get.snackbar(
                            '${functionalBloc.loginLanguage == 'english' ? 'Error': '出现错误'}',
                            authBloc.errorMessage[0],
                            backgroundColor: Colors.red[400],
                            colorText: Colors.white,
                          );
                          Future.delayed(Duration(seconds: 1), () {
                            authBloc.setValue('errMsg', []);
                          });
                        }
                      },
                    );
                  })
                : showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BottomSheetContent(
                    label: '${functionalBloc.loginLanguage == 'english' ? 'Reset Password': '忘记密码'}',
                    buttonText: '${functionalBloc.loginLanguage == 'english' ? 'Reset': '发送邮件'}',
                    controller: resetEmailController,
                    onPressed: () async {
                      await authBloc.resetPasswordWithEmail(
                          resetEmailController.text, functionalBloc);

                      Navigator.pop(context);

                      resetEmailController.clear();

                      if (authBloc.noticeMessage.isNotEmpty) {
                        Get.snackbar(
                          'Check your Email',
                          authBloc.noticeMessage[0],
                          backgroundColor: Colors.green[400],
                          colorText: Colors.white,
                        );
                        Future.delayed(Duration(seconds: 1), () {
                          authBloc.setValue('errMsg', []);
                        });
                      }

                      if (authBloc.errorMessage.isNotEmpty) {
                        Get.snackbar(
                          'Error',
                          authBloc.errorMessage[0],
                          backgroundColor: Colors.red[400],
                          colorText: Colors.white,
                        );
                        Future.delayed(Duration(seconds: 1), () {
                          authBloc.setValue('errMsg', []);
                        });
                      }
                    },
                  );
                }
            );
          },
        ),
      ],
    );
  }
}
