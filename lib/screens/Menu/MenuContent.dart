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
              label: Text('Full-Day'),
              selected: functionalBloc.menuChoice == 'fullday',
              onSelected: (value) {
                if (value) {
                  functionalBloc.switchMenuChoice('fullday');
                }
              },
            ),
            ChoiceChip(
              label: Text('Lunch'),
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
        ) : Expanded(
          child: ListView.builder(
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
        ),
      ],
    );
  }
}
