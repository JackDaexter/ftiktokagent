import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:my_app/components/alert_dialog.dart';
import 'package:my_app/components/custom_dialog.dart';
import 'package:my_app/main.dart';
import 'package:my_app/models/infrastructure/AccountFileAdapter.dart';
import 'package:my_app/usecases/CreateRandomGmailAccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../core/Streamer.dart';
import '../../../models/domain/Account.dart';
import '../../../models/domain/SimpleProxy.dart';
import '../../../models/mapping/AccountDataSource.dart';
import '../../../models/mapping/PaginatedStreamingDataSource.dart';
import '../../../models/mapping/StreamingDataSource.dart';
import 'datagrid_top_buttons.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function() methodFromChild);
void main() => runApp(MyApp());

class AccountDatagrid extends StatefulWidget {
  final MyBuilder parentCallBuilder;

  AccountDatagrid({
    super.key,
    required this.parentCallBuilder,
  });

  @override
  State<AccountDatagrid> createState() => _AccountDatagridState();
}

class _AccountDatagridState extends State<AccountDatagrid> {
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
      MyAppInherited.of(context).accounts.addAll(accounts);
      accountDataSource = AccountDataSource(accountData: accounts);
      /*streamingDataSource =
          PaginatedStreamingDataGridSource(streamingData: streamerInstances);*/
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.parentCallBuilder.call(context, updateDataSources);
    return Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 5.0,
        child: Container(
          padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
          child: Column(children: [
            Row(
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

            const SizedBox(height: 10), // give it width

            SizedBox(
              width: 780,
              height: 400,
              child: SfDataGrid(
                  selectionMode: SelectionMode.single,
                  source: streamingDataSource,
                  allowPullToRefresh: true,
                  allowSorting: true,
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
            (getInheritedStreamerInstances().isNotEmpty
                ? Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 500,
                    child: SfDataPager(
                      itemWidth: 10,
                      itemHeight: 5,
                      pageCount:
                          getInheritedStreamerInstances().length / rowsPerPage,
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

    var newAccount = Account(
        email: email,
        username: username,
        password: password,
        status: Status.subscribe);
    updateAccountStatesByAddingItem(newAccount);

    var newStreamerInstance = new Streamer(
        account: Account(
            email: email,
            username: username,
            password: password,
            status: Status.subscribe));
    updateStreamerStatesByAddingItem(newStreamerInstance);

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

      getInheritedStreamerInstances().removeAt(indexSelectedAccount);
      getInheritedAccounts().removeAt(indexSelectedAccount);

      setState(() {
        streamingDataSource = PaginatedStreamingDataGridSource(
            streamingData: getInheritedStreamerInstances());
        accountDataSource =
            AccountDataSource(accountData: getInheritedAccounts());
      });
    }
  }

  List<Streamer> getInheritedStreamerInstances() {
    return MyAppInherited.of(context).streamerInstances;
  }

  List<Account> getInheritedAccounts() {
    return MyAppInherited.of(context).accounts;
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
    var status =
        await accountFileAdapter.saveMultipleAccounts(getInheritedAccounts());
    String message = status ? "Sauvegarde réussie" : "Echec de la sauvegarde";
    await CustomDialog(context, "Status de la sauvegarde", message);
  }

  Future<void> saveAccountUpdateInLocalStorage() async {
    await accountFileAdapter.saveMultipleAccounts(getInheritedAccounts());
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

    getInheritedStreamerInstances().addAll(streamers);
    getInheritedAccounts().addAll(accounts);

    updateAccountStates(accounts);
    updateStreamerStates(streamers);
  }

  void loadStreamerInstancesFromAccount() {
    List<Streamer> streamers = [];

    for (var account in MyAppInherited.of(context).accounts) {
      streamers.add(new Streamer(account: account));
    }
    updateStreamerStates(streamers);
  }

  void updateAccountStatesByAddingItem(Account accounts) {
    if (accounts != null) {
      setState(() {
        MyAppInherited.of(context).accounts.add(accounts);
        accountDataSource =
            AccountDataSource(accountData: MyAppInherited.of(context).accounts);
      });
    }
  }

  void updateStreamerStatesByAddingItem(Streamer streamers) {
    if (streamers != null) {
      setState(() {
        MyAppInherited.of(context).streamerInstances.add(streamers);
        streamingDataSource = PaginatedStreamingDataGridSource(
            streamingData: MyAppInherited.of(context).streamerInstances);
      });
    }
  }

  void updateStreamerStates(List<Streamer>? streamers) {
    if (streamers != null) {
      setState(() {
        MyAppInherited.of(context).streamerInstances = streamers;
        streamingDataSource = PaginatedStreamingDataGridSource(
            streamingData: MyAppInherited.of(context).streamerInstances);
      });
    }
  }

  void updateAccountStates(List<Account>? accounts) {
    if (accounts != null) {
      setState(() {
        MyAppInherited.of(context).accounts = accounts;
        accountDataSource =
            AccountDataSource(accountData: MyAppInherited.of(context).accounts);
      });
    }
  }

  void updateDataSources() {
    log("updateDataSources");
    log(getInheritedStreamerInstances().toString());
    setState(() {
      streamingDataSource = PaginatedStreamingDataGridSource(
          streamingData: getInheritedStreamerInstances());
      accountDataSource =
          AccountDataSource(accountData: getInheritedAccounts());
    });
  }
}
