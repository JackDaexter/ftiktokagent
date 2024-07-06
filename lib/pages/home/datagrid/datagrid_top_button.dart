import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatagridTopButtons extends StatelessWidget {
  late Function importAccountFromFileCallback;
  late Function activateAccountAddingCallback;
  late Function generateRandomGmailAccountCallBack;

  DatagridTopButtons(
      {required this.importAccountFromFileCallback,
      required this.activateAccountAddingCallback,
      required this.generateRandomGmailAccountCallBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              height: 25,
              margin: const EdgeInsets.only(left: 20.0, right: 0.0),
              child: OutlinedButton(
                  onPressed:
                      importAccountFromFileCallback(), // null disables the button
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
                      activateAccountAddingCallback(), // null disables the button
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
                      generateRandomGmailAccountCallBack(), // null disables the button
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
    );
  }
}
