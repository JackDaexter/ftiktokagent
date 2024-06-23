import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../models/domain/Account.dart';
import '../models/mapping/AccountDataSource.dart';

class AccountDatagrid extends StatefulWidget {
  const AccountDatagrid({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<AccountDatagrid> createState() => _AccountDatagridState();
}

class _AccountDatagridState extends State<AccountDatagrid> {
  List<Account> accountsData = <Account>[];
  late AccountDataSource accountDataSource;

  @override
  void initState() {
    super.initState();
    accountsData = [new Account(email: "<ops>", username: "Popsld", password: "[Clan]")];
    accountDataSource = AccountDataSource(accountData: accountsData);
  }

  void _addAccount() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      accountsData.add(new Account(email: "email", username: "username", password: "password"));
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of components.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SfDataGrid(
        source: accountDataSource,
        allowPullToRefresh: true,
        columnWidthMode: ColumnWidthMode.fill,
        columns: <GridColumn>[
          GridColumn(
              columnName: 'email',
              label: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    'Email',
                  ))),
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
                  child: Text(
                    'Password',
                    overflow: TextOverflow.ellipsis,
                  ))),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAccount,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
