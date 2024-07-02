import 'package:flutter/widgets.dart';
import 'package:my_app/models/domain/Account.dart';
import 'package:my_app/models/domain/SimpleProxy.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ProxyDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  AccountDataSource({required List<SimpleProxy> proxyData}) {
    _proxyData = proxyData
        .map<DataGridRow>((proxy) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'ip', value: proxy.ip),
              DataGridCell<String>(columnName: 'port', value: proxy.port),
            ]))
        .toList();
  }

  List<DataGridRow> _proxyData = [];

  @override
  List<DataGridRow> get rows => _proxyData;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }

  @override
  Future<void> handleRefresh() async {
    await Future.delayed(Duration(seconds: 5));
    _proxyData;
    notifyListeners();
  }
}
