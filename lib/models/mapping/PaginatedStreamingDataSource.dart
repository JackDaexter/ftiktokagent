import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../core/Streamer.dart';

class PaginatedStreamingDataGridSource extends DataGridSource {
  final int _rowsPerPage = 15;

  PaginatedStreamingDataGridSource({required List<Streamer> streamingData}) {
    _streamingData = streamingData
        .map<DataGridRow>((e) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'email', value: e.account.email),
              DataGridCell<String>(
                  columnName: 'username', value: e.account.username),
              DataGridCell<String>(
                  columnName: 'account_status',
                  value: e.account.status.name.toString()),
              DataGridCell<String>(
                  columnName: 'streaming_status',
                  value: e.browserStatus.name.toString()),
              DataGridCell<String>(
                  columnName: 'seen_videos',
                  value: e.numberOfStream.toString()),
            ]))
        .toList();
  }

  List<DataGridRow> _streamingData = [];

  @override
  List<DataGridRow> get rows => _streamingData;

  MaterialColor getAppropriateColor(String status) {
    if (status == 'Inactive') {
      return Colors.red;
    } else if (status == 'Captcha') {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataCell) {
      if (dataCell.columnName == 'streaming_status') {
        return Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Chip(
            avatar:
                Icon(Icons.circle, color: getAppropriateColor(dataCell.value)),
            label: Text(dataCell.value.toString(),
                style: const TextStyle(
                    fontSize: 14.0, fontWeight: FontWeight.w400)),
          ),
        );
      }
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: Text(dataCell.value.toString()),
      );
    }).toList());
  }

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    int startRowIndex = newPageIndex * _rowsPerPage;
    int endRowIndex = startRowIndex + _rowsPerPage;
    _streamingData = _streamingData
        .getRange(startRowIndex, _streamingData.length)
        .toList(growable: false);
    notifyDataSourceListeners();
    return true;
  }

  @override
  Future<void> updateDataGridSource() async {
    await Future.delayed(Duration(seconds: 5));
    _streamingData;
    notifyListeners();
  }

  @override
  Future<void> handleRefresh() async {
    await Future.delayed(Duration(seconds: 5));
    _streamingData;
    notifyListeners();
  }
}
