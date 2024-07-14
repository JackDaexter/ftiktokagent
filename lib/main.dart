import 'dart:io';
import 'dart:math';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/pages/home/home.dart';

import 'core/Streamer.dart';
import 'models/domain/Account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// This HttpOverride will be set globally in the app.
  HttpOverrides.global = MyHttpOverrides();


  runApp(const MyApp());
}

class MyAppInherited extends InheritedWidget {
  late List<Account> accounts;
  late List<Streamer> streamerInstances;

  MyAppInherited({
    Key? key,
    required Widget child,
    required this.accounts,
    required this.streamerInstances,
  }) : super(child: child, key: key);

  static MyAppInherited of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MyAppInherited>()!;
  }

  @override
  bool updateShouldNotify(MyAppInherited oldWidget) {
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var randomNumber = Random();
    int videoToSelect = randomNumber.nextInt(6) + 1;
    dev.log("Video to Select $videoToSelect");

    return MaterialApp(
      title: 'TiktokAgent',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFEFEF),
        // This is the theme of your application.
        //
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

        useMaterial3: true,
      ),
      home: MyAppInherited(
          child: HomePage(), accounts: [], streamerInstances: []),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port){
      // Allowing only our Base API URL.
      List<String> validHosts = ["https://api.github.com/repos/JackDaexter/ftiktokagent/releases/latest"];

      final isValidHost = validHosts.contains(host);
      return isValidHost;

      // return true if you want to allow all host. (This isn't recommended.)
      // return true;
    };
  }
}
