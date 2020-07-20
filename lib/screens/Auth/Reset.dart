import 'package:flutter/material.dart';
import 'package:TaipeiCuisine/BloC/AuthBloc.dart';
import 'package:TaipeiCuisine/components/BottomSheet/BottomSheet.dart';
import 'package:get/get.dart';

class ResetPass extends StatelessWidget {
  final TextEditingController resetEmailController;
  final AuthBloc authBloc;

  ResetPass({this.resetEmailController, this.authBloc});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FlatButton(
          child: Text(
            'Reset Password',
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
                      label: 'Reset Password',
                      buttonText: 'Reset',
                      controller: resetEmailController,
                      onPressed: () async {
                        await authBloc.resetPasswordWithEmail(
                            resetEmailController.text);

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
                  })
                : showModalBottomSheet(
                context: context,
                builder: (context) {
                  return BottomSheetContent(
                    label: 'Reset Password',
                    buttonText: 'Reset',
                    controller: resetEmailController,
                    onPressed: () async {
                      await authBloc.resetPasswordWithEmail(
                          resetEmailController.text);

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
