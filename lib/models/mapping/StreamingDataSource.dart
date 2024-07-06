import 'package:flutter/cupertino.dart';
import 'package:my_app/core/Streamer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class StreamingDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  StreamingDataSource({required List<Streamer> streamingData}) {
    _streamingData = streamingData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'email', value: e.account.email),
              DataGridCell<String>(
                  columnName: 'username', value: e.account.username),
              DataGridCell<String>(
                  columnName: 'account_status',
                  value: e.account.status.toString()),
              DataGridCell<String>(
                  columnName: 'streaming status',
                  value: e.browserStatus.toString()),
            ]))
        .toList();
  }

  List<DataGridRow> _streamingData = [];

  @override
  List<DataGridRow> get rows => _streamingData;

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
    _streamingData;
    notifyListeners();
  }
}
