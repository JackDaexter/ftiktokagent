import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> CustomDialog(BuildContext context, String titreDeLaDialog,
        String stateOfSaving) async =>
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titreDeLaDialog),
          content: Text(stateOfSaving),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
