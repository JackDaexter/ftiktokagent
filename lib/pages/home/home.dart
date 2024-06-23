import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_app/components/datagrid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/domain/Account.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  Future<void> _addAccountFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt','json'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      file.readAsString().then((String jsonContent){
        var elem = jsonDecode(jsonContent) as Map<List<String>, List<Account>>;
        log('jsonContent : $jsonContent');
        log('elem : $elem');
      });

    } else {
      // User canceled the picker
    }

  }

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      // Column is a vertical, linear layout.
      child: Column(
        children: [
          Expanded(
            child: AccountDatagrid(
              title: "Account datagrid",
            ),
          ),
          Expanded(child:  Row(
            children: <Widget>[
              Container(
                height: 40,
                width: 200,
                margin: const EdgeInsets.only(left: 20.0, right: 0.0),
                child:FloatingActionButton(
                  tooltip: 'Importer des comptes',
                  onPressed: _addAccountFromFile, // null disables the button
                  child: const Text("Importer des comptes"), // null disables the button
                ),
              ),
              Expanded(
                child:IconButton(
                  icon: Icon(Icons.menu),
                  tooltip: 'Navigsdsdation menu',
                  onPressed: _addAccountFromFile, // null disables the button
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }


}