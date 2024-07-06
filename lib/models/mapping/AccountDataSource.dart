import 'package:flutter/widgets.dart';
import 'package:my_app/models/domain/Account.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class AccountDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  AccountDataSource({required List<Account> accountData}) {
    _accountData = accountData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'email', value: e.email),
              DataGridCell<String>(columnName: 'username', value: e.username),
              DataGridCell<String>(columnName: 'pwd', value: e.password),
            ]))
        .toList();
  }

  List<DataGridRow> _accountData = [];

  @override
  List<DataGridRow> get rows => _accountData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(
          e.value.toString(),
        ),
      );
    }).toList());
  }

  @override
  Future<void> handleRefresh() async {
    await Future.delayed(Duration(seconds: 5));
    _accountData;
    notifyListeners();
  }
}
