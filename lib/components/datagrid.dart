import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/domain/Account.dart';
import '../models/mapping/AccountDataSource.dart';

class AccountDatagrid extends StatefulWidget {
  const AccountDatagrid({super.key,required this.accountsData, required this.title});

  Future<List<dynamic>> _addAccountFromFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'json']);

    if (result != null) {
      File file = File(result.files.single.path!);

      file.readAsString().then((String accountsStringFormat) {
        try {
          List<dynamic> accountsJsonFormat = jsonDecode(accountsStringFormat);
          List<Account> accounts = accountsJsonFormat
              .map((jsonAccount) => Account.fromJson(jsonAccount))
              .toList();
          return accounts;
        } catch (Exception) {}
        return [];
      });
    }
    return [];
  }

  final String title;
  final List<Account> accountsData;

  @override
  State<AccountDatagrid> createState() => _AccountDatagridState(accountsData: accountsData);
}

class _AccountDatagridState extends State<AccountDatagrid> {
  late AccountDataSource accountDataSource;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DataGridController dataGridController = DataGridController();
  bool isEmailValid = true;
  bool isUsernameValid = true;
  bool isPasswordValid = true;
  bool AddAnAccount = false;
  final List<Account> accountsData;

  _AccountDatagridState({required this.accountsData});

  @override
  void initState() {
    super.initState();
    loadAccountsFromPreviousSession();

    accountDataSource = AccountDataSource(accountData: accountsData);
  }

  Future<void> _addAccountFromFile() async {
    final prefs = await SharedPreferences.getInstance();
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'json']);

    if (result != null) {
      File file = File(result.files.single.path!);
      await prefs.setString('accountFilePath', result.files.single.path!);
      await prefs.setString('accountFileName', result.files.single.name);

      file.readAsString().then((String accountsStringFormat) async {
        try {
          List<dynamic> accountsJsonFormat = jsonDecode(accountsStringFormat);

          List<Account> accounts = accountsJsonFormat
              .map((jsonAccount) => Account.fromJson(jsonAccount))
              .toList();
          await prefs.setString('savedAccountsFromFile', accountsStringFormat);


          accountDataSource = AccountDataSource(accountData: accountsData);
        } catch (Exception) {}
      });
    } else {
      // User canceled the picker
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(children: [
      Container(
        color: Colors.blueGrey.withOpacity(0.2),
        child: Column(children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: <Widget>[
                    Container(
                        height: 25,
                        margin: const EdgeInsets.only(left: 20.0, right: 0.0),
                        child: OutlinedButton(
                            onPressed:
                                _addAccountFromFile, // null disables the button
                            child: Row(children: [
                              Icon(
                                Icons.file_download,
                                size: 13.0,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Importer des comptes",
                                style: TextStyle(fontSize: 12.0),
                              )
                            ]) // null disables the button
                            ))
                  ])),
              Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: <Widget>[
                    Container(
                        height: 25,
                        margin: const EdgeInsets.only(left: 20.0, right: 0.0),
                        child: OutlinedButton(
                            onPressed:
                                _activateAccountAdding, // null disables the button
                            child: Row(children: [
                              Icon(
                                Icons.add,
                                size: 16.0,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "Ajouter un compte",
                                style: TextStyle(fontSize: 12.0),
                              )
                            ]) // null disables the button
                            ))
                  ])),
            ],
          ),
          SfDataGrid(
              selectionMode: SelectionMode.single,
              source: accountDataSource,
              allowPullToRefresh: true,
              controller: dataGridController,
              columnWidthMode: ColumnWidthMode.fill,
              columns: <GridColumn>[
                GridColumn(
                    columnName: 'email',
                    label: Container(
                        padding: EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        child: Text('Email'))),
                GridColumn(
                    columnName: 'username',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child: Text('Username'))),
                GridColumn(
                    columnName: 'password',
                    label: Container(
                        padding: EdgeInsets.all(8.0),
                        alignment: Alignment.center,
                        child:
                            Text('Password', overflow: TextOverflow.ellipsis)))
              ]),
          Center(
              child: AddAnAccount
                  ? Container(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                      color: Colors.grey[300],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceAround, // use whichever suits your need
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                height: 30,
                                width: 200,
                                child: TextField(
                                  style: TextStyle(fontSize: 12),
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Email',
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                width: 200,
                                child: TextField(
                                  style: TextStyle(fontSize: 12),
                                  controller: usernameController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Username',
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                                width: 200,
                                child: TextField(
                                  style: TextStyle(fontSize: 12),
                                  controller: passwordController,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Password',
                                    labelStyle: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.green,
                                      child: IconButton(
                                          iconSize: 15.0,
                                          padding: EdgeInsets.all(0.0),
                                          onPressed: _addNewAccount,
                                          icon: Icon(Icons.check)),
                                    ),
                                    SizedBox(width: 10), // give it width

                                    CircleAvatar(
                                      radius: 15.0,
                                      backgroundColor: Colors.red,
                                      child: IconButton(
                                          iconSize: 15.0,
                                          padding: EdgeInsets.all(0.0),
                                          onPressed: _deactivateAccountAdding,
                                          icon: Icon(Icons.close)),
                                    ),
                                  ])
                            ],
                          ),
                        ],
                      ))
                  : new Container()),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 10, right: 10),
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      onPressed:
                          onSaveAccountUpdate, // null disables the button
                      child: Row(children: [
                        Icon(
                          Icons.save,
                          size: 16.0,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Sauvegarder ",
                          style: TextStyle(fontSize: 12.0),
                        )
                      ]) // null disables the button
                      ),
                )
              ],
            ),
          )
        ]),
      ),
      SizedBox(height: 10),
    ]));
  }

  void _addNewAccount() {
    var username = usernameController.text;
    var email = emailController.text;
    var password = passwordController.text;
    accountsData
        .add(Account(email: email, username: username, password: password));
    accountDataSource = AccountDataSource(accountData: accountsData);
    _deactivateAccountAdding();
    cleanControllers();
  }

  void _activateAccountAdding() {
    setState(() {
      AddAnAccount = !AddAnAccount;
    });
  }

  void _updateAccountSaving() {}

  void _deactivateAccountAdding() {
    setState(() {
      AddAnAccount = false;
    });
  }

  void cleanControllers() {
    usernameController.clear();
    emailController.clear();
    passwordController.clear();
  }

  void removeSelectedAccount() {
    var selectedAccount = dataGridController.selectedRow;
  }

  Future<void> loadAccountsFromPreviousSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAccountFromFile = prefs.getString('savedAccountsFromFile');
    if (savedAccountFromFile != null) {
      try {
        List<dynamic> accountsJsonFormat = jsonDecode(savedAccountFromFile);

        List<Account> accounts = accountsJsonFormat
            .map((jsonAccount) => Account.fromJson(jsonAccount))
            .toList();

        setState(() {
          //accountsData = accounts;
        });
        accountDataSource = AccountDataSource(accountData: accountsData);
      } catch (Exception) {}
    }
  }

  Future<void> onSaveAccountUpdate() async {
    final prefs = await SharedPreferences.getInstance();

    final accountFileName = prefs.getString('accountFileName');
    final accountFilePath = prefs.getString('accountFilePath');

    if (accountFilePath != null) {
      try {
        var encodedAccountData = jsonEncode(accountsData.first.toString());
        File file = File(accountFilePath);
        file.writeAsString(encodedAccountData);
      } catch (exception, e) {
        log(accountsData.first.toString());
        log(exception.toString());
        log(e.toString());
      }
    }
  }

  void saveAccountUpdateInLocalStorage() {}
}
