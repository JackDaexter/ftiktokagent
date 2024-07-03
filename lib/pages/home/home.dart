import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_app/components/datagrid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/domain/Account.dart';
import 'package:my_app/models/domain/SimpleProxy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/Streamer.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});
  final List<Account> accountsData = <Account>[];
  final List<Streamer> streamerInstances = <Streamer>[];

  @override
  State<StatefulWidget> createState() => HomePageStatefull(
      accountsData: accountsData, streamerInstances: streamerInstances);
}

class HomePageStatefull extends State<HomePage> {
  List<Account> accountsData;
  List<Streamer> streamerInstances;
  List<SimpleProxy> proxiesData = <SimpleProxy>[];
  final List<Streamer> streamers = <Streamer>[];

  HomePageStatefull(
      {required this.accountsData, required this.streamerInstances});

  accountCallback(List<Account> account) {
    setState(() {
      accountsData = account;
    });
  }

  streamerCallback(List<Streamer> streamers) {
    setState(() {
      streamerInstances = streamers;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      // Column is a vertical, linear layout.
      color: Colors.grey[200],
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(


          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(left: 10.0, top: 15.0),
                  height: 550,
                  width: 800,
                  child: AccountDatagrid(
                    accountCallback: accountCallback,
                    streamerCallback: streamerCallback,
                  ),
                ),
                SizedBox(width: 30), // give it width
                Center(
                    child: Card(
                      // clipBehavior is necessary because, without it, the InkWell's animation
                      // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                      // This comes with a small performance cost, and you should not set [clipBehavior]
                      // unless you need it.
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        splashColor: Colors.blue.withAlpha(30),
                        onTap: () {
                          debugPrint('Card tapped.');
                        },
                        child: SizedBox(
                            width: 300,
                            height: 200,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child: Text(
                                      'Nombre de proxy chargés: ${proxiesData.length}',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Column(
                                    children: [
                                      ElevatedButton(
                                        onPressed: _importProxyFromFile,
                                        child: Text('Importer des proxies'),
                                      ),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: _removeProxies,
                                        child: Text('Supprimer les proxies'),
                                        style: ButtonStyle(
                                          textStyle:
                                          WidgetStateProperty.all<TextStyle>(
                                            TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                      ),
                    )),
              ],
            ),
            const Expanded(child: SizedBox.shrink()), // <-- Expanded

            Center(
                child: SizedBox(
                  width: 280,
                  child: Center(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green),
                          onPressed: _startStreaming,
                          child: Text(
                            "Lancer le bot",
                            style: TextStyle(fontSize: 18.0, color: Colors.white),
                          ))),
                )),
            const SizedBox(height: 20)
          ],
        ),
      )
    );
  }

  Future<void> _importProxyFromFile() async {
    final prefs = await SharedPreferences.getInstance();
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt']);

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        await prefs.setString('proxyFilePath', result.files.single.path!);
        await prefs.setString('proxyFileName', result.files.single.name);
        List<SimpleProxy> proxies = <SimpleProxy>[];

        List<String> lines = await file.readAsLines();
        for (String line in lines) {
          var ip = line.split(":")[0];
          var port = line.split(":")[1];

          proxies.add(new SimpleProxy(ip: ip, port: port));
        }

        setState(() {
          proxiesData = proxies;
        });
      } catch (e) {
        print(e);
      }
    } else {
      // User canceled the picker
    }
  }

  displayValue() {
    log(accountsData.toString());
  }

  void _removeProxies() {
    setState(() {
      proxiesData = [];
    });
  }

  void _startStreaming() {
    var accountData = this.accountsData.first;
    var streamer = Streamer(accountData: accountData);
    streamer.Start();
  }
}
