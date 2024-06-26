import 'package:flutter/material.dart';
import 'package:my_app/pages/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TiktokAgent',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFEFEF),
        // This is the theme of your application.
        //
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),

        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
