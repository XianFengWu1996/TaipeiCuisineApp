import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/FunctionalBloc.dart';
import 'package:food_ordering_app/screens/Menu/MenuItems.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MenuContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FunctionalBloc functionalBloc = Provider.of<FunctionalBloc>(context);
    return Column(
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: <Widget>[
            ChoiceChip(
              label: Text('${functionalBloc.selectedValue == 'english' ? 'Full-Day' : '全天菜单'}'),
              selected: functionalBloc.menuChoice == 'fullday',
              onSelected: (value) {
                if (value) {
                  functionalBloc.switchMenuChoice('fullday');
                }
              },
            ),
            ChoiceChip(
              label: Text('${functionalBloc.selectedValue == 'english' ? 'Lunch' : '特价午餐'}'),
              selected: functionalBloc.menuChoice == 'lunch',
              onSelected: (value) {
                if (value) {
                  functionalBloc.switchMenuChoice('lunch');
                }
              },
            )
          ],
        ),
        functionalBloc.menuChoice == 'fullday' ?
        Expanded(
          child: ListView.builder(
              itemCount: functionalBloc.fullDayMenu.length,
              itemBuilder: (context, index) {
                return FlatButton(
                  child: Card(
                      child: ListTile(
                    trailing: Icon(Icons.arrow_forward_ios),
                    title: Text('${functionalBloc.selectedValue == 'english'
                        ? functionalBloc.fullDayMenu[index]['englishName']
                        : functionalBloc.fullDayMenu[index]['chineseName']
                    }'),
                  )),
                  onPressed: () {
                    Get.to(MenuItems(
                        count: index,
                        title: functionalBloc.selectedValue == 'english'
                            ? functionalBloc.fullDayMenu[index]['englishName']
                            : functionalBloc.fullDayMenu[index]
                                ['chineseName'],
                      lunch: functionalBloc.menuChoice == 'lunch',
                    ));
                  },
                );
              }),
        ) : ListView(
          shrinkWrap: true,
          children: [
            Card(
              child: Column(
                children: [
                  functionalBloc.selectedValue == 'english' ?
                  Text('Lunch Special serve daily from 11am - 4pm') :
                  Text('特价午餐 每天上午11点到下午4点'),
                  functionalBloc.selectedValue == 'english' ?
                  Text('Discount are calculated during checkout') :
                  Text('折扣将会在结算界面计算'),
                  functionalBloc.selectedValue == 'english' ?
                  Text('Lunch after 4pm will not include discount and soup') :
                  Text('4点后可继续订购，可不会配折扣和汤'),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
                itemCount: functionalBloc.lunchMenu.length,
                itemBuilder: (context, index) {
                  return FlatButton(
                    child: Card(
                        child: ListTile(
                          trailing: Icon(Icons.arrow_forward_ios),
                          title: Text('${functionalBloc.selectedValue == 'english'
                              ? functionalBloc.lunchMenu[index]['englishName']
                              : functionalBloc.lunchMenu[index]['chineseName']
                          }'),
                        )),
                    onPressed: () {
                      Get.to(MenuItems(
                          count: index,
                          title: functionalBloc.selectedValue == 'english'
                              ? functionalBloc.lunchMenu[index]['englishName']
                              : functionalBloc.lunchMenu[index]
                          ['chineseName'],
                        lunch: functionalBloc.menuChoice == 'lunch',
                      ));
                    },
                  );
                }),
          ],
        ),
      ],
    );
  }
}
