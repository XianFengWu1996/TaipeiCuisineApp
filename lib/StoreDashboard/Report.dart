import 'package:TaipeiCuisine/BloC/StoreBloc.dart';
import 'package:TaipeiCuisine/StoreDashboard/Menubar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Report extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoreBloc storeBloc = Provider.of<StoreBloc>(context);

    TextStyle _fontLarge = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    );

    TextStyle _fontMedium = TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w500,
    );


    List<String> _month = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
      ),
      drawer: MenuBar(),
      body: ListView(shrinkWrap: true, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton(
              value: storeBloc.monthDropdown,
              onChanged: (value) {
                storeBloc.changeValue('month', value);
              },
              items: <int>[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
                  .map<DropdownMenuItem<String>>((int value) {
                return DropdownMenuItem<String>(
                  value: value.toString(),
                  child: Text(_month[value < 0 ? value - 1 : value]),
                );
              }).toList(),
            ),
            DropdownButton(
              value: storeBloc.yearDropdown,
              onChanged: (value) {
                storeBloc.changeValue('year', value);
              },
              items: <String>['2020', '2021', '2022', '2023']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            RaisedButton(
              onPressed: () async {
                await storeBloc.getTotalReports();
              },
              child: Text('Search'),
              color: Colors.red[400],
              textColor: Colors.white,
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  value: storeBloc.summary == 'summary',
                  onChanged: (value) {
                    storeBloc.changeValue('summary', value ? 'summary' : '');
                  },
                  title: Text('Summary'),
                ),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: CheckboxListTile(
                  value: storeBloc.details == 'details',
                  onChanged: (value) {
                    storeBloc.changeValue('details', value ? 'details' : '');
                  },
                  title: Text('Details'),
                ),
              ),
            ],
          ),
        ),
        storeBloc.summary == 'summary' ? Scrollbar(child: ListView(
          shrinkWrap: true,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:Column(
                children: [
                  DataTable(
                      columns: [
                        DataColumn(label: Text('Date', style: _fontMedium)),
                        DataColumn(label: Text('Order #', style: _fontMedium)),
                        DataColumn(label: Text('Customer Name', style: _fontMedium)),
                        DataColumn(label: Text('Subtotal', style: _fontMedium)),
                        DataColumn(label: Text('Discount', style: _fontMedium)),
                        DataColumn(label: Text('Tax', style: _fontMedium)),
                        DataColumn(label: Text('Tip', style: _fontMedium)),
                        DataColumn(label: Text('Total', style: _fontMedium)),
                      ],
                      rows: storeBloc.reportSnapshot.map(
                              (e){
                                return DataRow(
                                  cells: [
                                    DataCell(Text('${DateFormat('Md').format(DateTime.fromMillisecondsSinceEpoch(e.data['createdAt']))}'
                                        , style: _fontMedium)
                                    ),
                                    DataCell(Text('${e.data['orderId']}', style: _fontMedium)),
                                    DataCell(Text('${e.data['customerName']}', style: _fontMedium)),
                                    DataCell(Text('\$${(e.data['subtotal'] - e.data['lunchDiscount']).toStringAsFixed(2)}', style: _fontMedium)),
                                    DataCell(Text('\$${(e.data['pointUsed'] / 100).toStringAsFixed(2)}', style: _fontMedium)),
                                    DataCell(Text('\$${e.data['tax'].toStringAsFixed(2)}', style: _fontMedium)),
                                    DataCell(Text('\$${e.data['tip'].toStringAsFixed(2)}', style: _fontMedium)),
                                    DataCell(Text('\$${(e.data['total'] / 100).toStringAsFixed(2)}', style: _fontMedium)),
                                ]
                                );
                              }
                      ).toList(),

                  ),
                ],
              ),
            )
          ],
        )) : Container(),
        storeBloc.details == 'details' ? Padding(
          padding: const EdgeInsets.only(right: 10, top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Subtotal: \$${storeBloc.reportSubtotal.toStringAsFixed(2)}', style: _fontLarge,),
              Text('Discount: (\$${(storeBloc.reportDiscount / 100).toStringAsFixed(2)})', style: _fontLarge),
              Text('Tax: \$${storeBloc.reportTax.toStringAsFixed(2)}', style: _fontLarge),
              Text('Tip: \$ ${storeBloc.reportTip.toStringAsFixed(2)}', style: _fontLarge),
              Text('Total: \$${(storeBloc.reportTotal / 100).toStringAsFixed(2)}', style: _fontLarge),
            ],
          ),
        ) : Container(),
      ]),
    );
  }
}
