import 'package:flutter/material.dart';
import 'package:food_ordering_app/BloC/OrderBloc.dart';
import 'package:provider/provider.dart';

class ProgressChipGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    OrderBloc orderBloc = Provider.of<OrderBloc>(context);

    return Row(
      children: <Widget>[
        ProgressChip(
          title: 'In Progress',
          selected: orderBloc.orderStatus == 'inProgress',
          onSelected: (bool selected){
            if(selected){
              orderBloc.changeStatus('inProgress');
            }
          },
        ),
        ProgressChip(
          title: 'Completed',
          selected: orderBloc.orderStatus == 'completed',
          onSelected: (bool selected){
            if(selected){
              orderBloc.changeStatus('completed');
            }
          },
        ),
        ProgressChip(
          title: 'Cancelled',
          selected: orderBloc.orderStatus == 'cancelled',
          onSelected: (bool selected){
            if(selected){
              orderBloc.changeStatus('cancelled');
            }
          },
        ),
      ],
    );
  }
}

class ProgressChip extends StatelessWidget {
  final String title;
  final bool selected;
  final Function onSelected;

  ProgressChip({this.title, this.selected, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ChoiceChip(
        label: Text('$title'),
        selected: selected,
        onSelected: onSelected,
        shape: RoundedRectangleBorder(),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        selectedColor: Colors.red[400],
        disabledColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
      ),
    );
  }
}
