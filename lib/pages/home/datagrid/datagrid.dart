import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_app/components/alert_dialog.dart';
import 'package:my_app/components/custom_dialog.dart';
import 'package:my_app/models/infrastructure/AccountFileAdapter.dart';
import 'package:my_app/usecases/CreateRandomGmailAccount.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../core/Streamer.dart';
import '../../../models/domain/Account.dart';
import '../../../models/mapping/AccountDataSource.dart';
import '../../../models/mapping/PaginatedStreamingDataSource.dart';
import '../../../models/mapping/StreamingDataSource.dart';
import 'datagrid_top_button.dart';

class AccountDatagrid extends StatefulWidget {
  Function accountCallback;
  Function streamerCallback;

  AccountDatagrid(
      {super.key,
      required this.accountCallback,
      required this.streamerCallback});

  @override
  State<AccountDatagrid> createState() => _AccountDatagridState();
}

class _AccountDatagridState extends State<AccountDatagrid> {
  List<Account> accountsData = <Account>[];
  List<Streamer> streamerInstances = <Streamer>[];

  late AccountDataSource accountDataSource = AccountDataSource(accountData: []);
  late PaginatedStreamingDataGridSource streamingDataSource =
      PaginatedStreamingDataGridSource(streamingData: []);
  AccountFileAdapter accountFileAdapter = AccountFileAdapter(path: '');

  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DataGridController dataGridController = DataGridController();
  final createRandomGmailAccount = CreateRandomGmailAccount();

  bool AddAnAccount = false;
  var rowsPerPage = 15;

  _AccountDatagridState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAccountsFromPreviousSession();
    });
  }

  Future<void> _importAccountFromFile() async {
    var accounts = await accountFileAdapter.loadAllAccountsAsync();

    if (accounts.isEmpty) {
      log('No accounts found');
      return;
    }
    setState(() {
      accountsData = accounts;
      widget.accountCallback(accounts);
      accountDataSource = AccountDataSource(accountData: accountsData);
      streamingDataSource =
          PaginatedStreamingDataGridSource(streamingData: streamerInstances);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 5.0,
        child: Container(
          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: Column(children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      height: 25,
                      margin: const EdgeInsets.only(left: 20.0, right: 0.0),
                      child: OutlinedButton(
                          onPressed:
                              _importAccountFromFile, // null disables the button
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
                          )),
                  Spacer(), // use Spacer

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
                          )),
                  Spacer(), // use Spacer

                  Container(
                      height: 25,
                      margin: const EdgeInsets.only(left: 20.0, right: 0.0),
                      child: OutlinedButton(
                          onPressed:
                              generateRandomGmailAccount, // null disables the button
                          child: Row(children: [
                            Icon(
                              Icons.generating_tokens,
                              size: 16.0,
                            ),
                            SizedBox(width: 5),
                            Text(
                              "Générer des comptes",
                              style: TextStyle(fontSize: 12.0),
                            )
                          ]) // null disables the button
                          ))
                ],
              ),
            ),

            const SizedBox(height: 10), // give it width

            SizedBox(
              width: 780,
              height: 400,
              child: SfDataGrid(
                  selectionMode: SelectionMode.single,
                  source: streamingDataSource,
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
                        columnName: 'account_status',
                        label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Status',
                                overflow: TextOverflow.ellipsis))),
                    GridColumn(
                        columnName: 'streaming_status',
                        label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('StreamingStatus',
                                overflow: TextOverflow.ellipsis))),
                    GridColumn(
                        columnName: 'seen_videos',
                        label: Container(
                            padding: EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text('Vidéos vues',
                                overflow: TextOverflow.ellipsis)))
                  ]),
            ),

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
                                    style: const TextStyle(fontSize: 12),
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
                    : new Container(
                        margin: EdgeInsets.only(top: 60),
                      )),
            (streamerInstances.isNotEmpty
                ? Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 500,
                    child: SfDataPager(
                      itemWidth: 10,
                      itemHeight: 5,
                      pageCount: streamerInstances.length / rowsPerPage,
                      visibleItemsCount: 0,
                      delegate: streamingDataSource,
                    ),
                  )
                : Container()),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 10, right: 10),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          onPressed: () => {}, // null disables the button
                          child: const Row(children: [
                            Icon(Icons.play_arrow,
                                size: 16.0, color: Colors.white),
                            SizedBox(width: 5),
                            Text(
                              "Lancer ce compte",
                              style: TextStyle(
                                  fontSize: 13.0, color: Colors.white),
                            )
                          ]) // null disables the button
                          ),
                    )
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(bottom: 10, right: 10),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent),
                            onPressed: () => {
                                  onSaveAccountUpdate()
                                }, // null disables the button
                            child: const Row(children: [
                              Icon(Icons.save, size: 16.0, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                "Sauvegarder",
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.white),
                              )
                            ]) // null disables the button
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 10, right: 10),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent),
                            onPressed:
                                onRemoveSelectedAccount, // null disables the button
                            child: const Row(children: [
                              Icon(Icons.remove_circle,
                                  size: 16.0, color: Colors.white),
                              SizedBox(width: 5),
                              Text(
                                "Remove",
                                style: TextStyle(
                                    fontSize: 12.0, color: Colors.white),
                              )
                            ]) // null disables the button
                            ),
                      )
                    ],
                  )
                ],
              ),
            )
          ]),
        ));
  }

  void _addNewAccount() {
    var username = usernameController.text;
    var email = emailController.text;
    var password = passwordController.text;
    accountsData.add(Account(
        email: email,
        username: username,
        password: password,
        status: Status.subscribe));
    widget.accountCallback(accountsData);
    accountDataSource = AccountDataSource(accountData: accountsData);
    setState(() {
      streamerInstances.add(new Streamer(
          account: Account(
              email: email,
              username: username,
              password: password,
              status: Status.subscribe)));
      log(streamerInstances.toString());
      widget.streamerCallback(streamerInstances);

      streamingDataSource =
          PaginatedStreamingDataGridSource(streamingData: streamerInstances);
    });
    _deactivateAccountAdding();
    cleanControllers();
  }

  void _activateAccountAdding() {
    setState(() {
      AddAnAccount = !AddAnAccount;
    });
  }

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

  void onRemoveSelectedAccount() {
    if (dataGridController.selectedIndex != -1) {
      var indexSelectedAccount = dataGridController.selectedIndex;

      accountsData.removeAt(indexSelectedAccount);
      streamerInstances.removeAt(indexSelectedAccount);

      widget.accountCallback(accountsData);
      accountDataSource = AccountDataSource(accountData: accountsData);

      widget.streamerCallback(streamerInstances);
      streamingDataSource =
          PaginatedStreamingDataGridSource(streamingData: streamerInstances);
    }
  }

  Future<void> loadAccountsFromPreviousSession() async {
    var accounts =
        await accountFileAdapter.loadAllAccountsFromPreviousSessionAsync();
    if (accounts.isEmpty) {
      log('No accounts found');
      return;
    }
    updateAccountStates(accounts);
    loadStreamerInstancesFromAccount();
  }

  Future<void> onSaveAccountUpdate() async {
    var status = await accountFileAdapter.saveMultipleAccounts(accountsData);
    log('Status: $status');
    String message = status ? "Sauvegarde réussie" : "Echec de la sauvegarde";
    await CustomDialog(context, "Status de la sauvegarde", message);
  }

  Future<void> saveAccountUpdateInLocalStorage() async {
    await accountFileAdapter.saveMultipleAccounts(accountsData);
  }

  Future<void> generateRandomGmailAccount() async {
    List<Account> accounts = [];
    List<Streamer> streamers = [];

    for (var i = 0; i < 1; i++) {
      var account = await createRandomGmailAccount.generateEmail();
      var username = account.split('@')[0];
      accounts.add(new Account(
          email: account,
          username: username,
          password: 'password1234',
          status: Status.unsubscribe));
      streamers.add(new Streamer(account: accounts.last));
    }
    streamers.addAll(streamerInstances);
    accounts.addAll(accountsData);

    updateAccountStates(accounts);
    updateStreamerStates(streamers);
  }

  void loadStreamerInstancesFromAccount() {
    List<Streamer> streamers = [];

    for (var account in accountsData) {
      streamers.add(new Streamer(account: account));
    }
    updateStreamerStates(streamers);
  }

  void updateStreamerStates(List<Streamer>? streamers) {
    if (streamers != null) {
      setState(() {
        widget.streamerCallback(streamers);
        streamerInstances = streamers;
        streamingDataSource =
            PaginatedStreamingDataGridSource(streamingData: streamerInstances);
      });
    }
  }

  void updateAccountStates(List<Account>? accounts) {
    if (accounts != null) {
      setState(() {
        accountsData = accounts;
        widget.accountCallback(accounts);
        accountDataSource = AccountDataSource(accountData: accountsData);
      });
    }
  }
}
