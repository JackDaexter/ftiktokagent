import 'package:flutter/material.dart';

/// Flutter code sample for [AlertDialog].

class AlertDialogExampleApp extends StatelessWidget {
  const AlertDialogExampleApp(
      {super.key, required this.dialogTitle, required this.dialogContent});

  final String dialogTitle;
  final String dialogContent;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AlertDialog Sample')),
        body: Center(
            child: DialogExample(
                dialogTitle: dialogTitle, dialogContent: dialogContent)),
      ),
    );
  }
}

class DialogExample extends StatelessWidget {
  final String dialogTitle;
  final String dialogContent;

  const DialogExample(
      {super.key, required this.dialogTitle, required this.dialogContent});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text(dialogTitle),
          content: Text(dialogContent),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
      child: const Text('Show Dialog'),
    );
  }
}
