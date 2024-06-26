import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:my_app/components/datagrid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/domain/Account.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key });
  final List<Account> accountsData = <Account>[];

  @override
  State<StatefulWidget> createState() => HomePageStatefull(accountsData : accountsData);
}

class HomePageStatefull extends State<HomePage>{
  HomePageStatefull({required this.accountsData });

  final List<Account> accountsData;



  @override
  Widget build(BuildContext context) {
    // Material is a conceptual piece
    // of paper on which the UI appears.
    return Material(
      // Column is a vertical, linear layout.
      color: Colors.grey[200],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                margin:  const EdgeInsets.only(left: 10.0, top:15.0)  ,
                height: 500,
                width: 600,
                child: AccountDatagrid(
                  title: "Account datagrid",
                  accountsData: [],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

}
