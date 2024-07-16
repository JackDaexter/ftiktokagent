import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/domain/SimpleProxy.dart';
import 'package:my_app/pages/home/datagrid/datagrid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_loading_dialog/simple_loading_dialog.dart';
import 'package:updat/updat.dart';

import '../../components/custom_dialog.dart';
import '../../core/Streamer.dart';
import '../../main.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageStatefull();
}

class HomePageStatefull extends State<HomePage> {
  late void Function() updateChildState;
  List<SimpleProxy> proxiesData = <SimpleProxy>[];
  final List<Streamer> streamers = <Streamer>[];
  final Map<Streamer, ReceivePort> receivePort = HashMap(); // Is a HashMap
  Timer? timer;
  final String appVersion = "0.0.1";
  Color color = const Color(0xff1890ff);

  HomePageStatefull({Key? key}) {
    loadProxyFromData();
  }

  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Scaffold(
        body: Material(

            // Column is a vertical, linear layout.
            color: Colors.grey[200],
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 10.0, top: 5.0),
                        height: 600,
                        width: 800,
                        child: AccountDatagrid(parentCallBuilder:
                            (BuildContext context,
                                void Function() methodFromChild) {
                          updateChildState = methodFromChild;
                        }),
                      ),
                      const SizedBox(width: 30), // give it width
                      Card(
                        // clipBehavior is necessary because, without it, the InkWell's animation
                        // will extend beyond the rounded edges of the [Card] (see https://github.com/flutter/flutter/issues/109776)
                        // This comes with a small performance cost, and you should not set [clipBehavior]
                        // unless you need it.
                        color: Colors.white,
                        clipBehavior: Clip.hardEdge,
                        child: SizedBox(
                          width: 300,
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Center(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.security,
                                        color: Colors.green, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Nombre de proxy chargés: ${proxiesData.length}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                )),
                                const SizedBox(height: 30),
                                Column(
                                  children: [
                                    ElevatedButton(
                                        onPressed: _importProxyFromFile,
                                        style: ButtonStyle(
                                          textStyle: WidgetStateProperty.all<
                                              TextStyle>(
                                            const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                        child:
                                            const Text('Importer des proxies')),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: _removeProxies,
                                      style: ButtonStyle(
                                        textStyle:
                                            WidgetStateProperty.all<TextStyle>(
                                          const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                          Colors.redAccent,
                                        ),
                                      ),
                                      child:
                                          const Text('Supprimer les proxies'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox.shrink()), // <-- Expanded

                  Center(
                      child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Never change v$appVersion',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _startStreaming,
                                style: ButtonStyle(
                                  backgroundColor:
                                      WidgetStateProperty.all<Color>(
                                    Colors.green,
                                  ),
                                ),
                                child: const Text('Démarrer le streaming',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                    )),
                              ),
                              const SizedBox(width: 10),
                            ],
                          ))),
                  const SizedBox(height: 0)
                ],
              ),
            )),
        floatingActionButton: UpdatWidget(
          closeOnInstall: false,
          openOnDownload: true,

          getLatestVersion: () async {
            log(Directory.current.path);
            try{
              log("GRos pd");
              final data = await http.get(Uri.parse(
                "https://api.github.com/repos/JackDaexter/ftiktokagent/releases/latest",
              ));

              var version = jsonDecode(data.body)["tag_name"];
              log(version);
              return version.split("v")[1].toString();
            }catch(e){

              await CustomDialog(context, "Erreur lors de la recherche de MAJ",e.toString());
              return null;
            }

          },
          getDownloadFileLocation: (version) async {

            return File("C:\\Users\\franc\\IdeaProjects\\ftiktokagent\\build\\windows\\x64\\runner\\Release\\myy_app.exe");
          },

          getBinaryUrl: (version) async {
            var message = "Downloading files";
            var currentPath = Directory.current.path;
            return "https://github.com/JackDaexter/ftiktokagent/releases/latest/download/my_app.exe";

          },

          appName: "ftiktokagent", // This is used to name the downloaded files.
          currentVersion: appVersion,
          callback: (status) {
            print(status);
          },
        ));
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
        await prefs.setStringList('proxies', lines);

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

  Future<void> loadProxyFromData() async {
    final prefs = await SharedPreferences.getInstance();

    var lines = prefs.get('proxies') as List<dynamic>?;
    if (lines != null) {
      List<SimpleProxy> proxies = <SimpleProxy>[];
      for (String line in lines) {
        var ip = line.split(":")[0];
        var port = line.split(":")[1];
        proxies.add(new SimpleProxy(ip: ip, port: port));
      }

      setState(() {
        proxiesData = proxies;
      });
    }
  }

  void _removeProxies() {
    log("Removing proxies");

    setState(() {
      proxiesData = [];
    });
    log(proxiesData.toString());
  }

  void _startStreaming() async {
    for (var streamer in MyAppInherited.of(context).streamerInstances) {
      var proxy = getRandomProxy();
      if (streamer.browserStatus == BrowserStatus.Inactive) {
        receivePort[streamer] = ReceivePort();
        await Isolate.spawn(
            streamer.start, [receivePort[streamer]!.sendPort, proxy]);
        receivePort[streamer]!.listen((message) {
          Streamer strems = message as Streamer;
          updateStreamerWithEmail(strems);
        });
      }
    }
  }

  SimpleProxy? getRandomProxy() {
    var random = new math.Random();
    if (proxiesData.isEmpty) {
      return null;
    }
    return proxiesData[random.nextInt(proxiesData.length)];
  }

  void updateStreamerWithEmail(Streamer newStreamer) {
    MyAppInherited.of(context).streamerInstances[MyAppInherited.of(context)
        .streamerInstances
        .indexWhere((element) =>
            element.account.email == newStreamer.account.email)] = newStreamer;

    updateChildState.call();
  }
}
