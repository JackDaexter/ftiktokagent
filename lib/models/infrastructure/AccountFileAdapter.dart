import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:my_app/models/domain/Account.dart';

import 'package:my_app/models/domain/SimpleProxy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../usecases/IObtainAccounts.dart';

class AccountFileAdapter implements IObtainAccounts {
  String path;

  AccountFileAdapter({required this.path});

  Future<List<Account>> loadAllAccountsFromPreviousSessionAsync() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAccountFromFile = prefs.getString('accountFilePath');

    List<Account> accounts = [];

    if (savedAccountFromFile != null) {
      try {
        File file = File(savedAccountFromFile);
        await file.readAsString().then((String accountsStringFormat) async {
          try {
            List<dynamic> accountsJsonFormat = jsonDecode(accountsStringFormat);

            accounts = accountsJsonFormat
                .map((jsonAccount) => Account.fromJson(jsonAccount))
                .toList();
          } catch (Exception) {
            log(Exception.toString());
          }
        });
        return accounts;
      } catch (Exception) {}
    } else {}
    return [];
  }

  @override
  Future<List<Account>> loadAllAccountsAsync() async {
    final prefs = await SharedPreferences.getInstance();
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['txt', 'json']);

    List<Account> accounts = [];
    if (result != null) {
      await prefs.setString('accountFilePath', result.files.single.path!);
      await prefs.setString('accountFileName', result.files.single.name);
      File file = File(result.files.single.path!);

      await file.readAsString().then((String accountsStringFormat) async {
        try {
          List<dynamic> accountsJsonFormat = jsonDecode(accountsStringFormat);

          accounts = accountsJsonFormat
              .map((jsonAccount) => Account.fromJson(jsonAccount))
              .toList();
        } catch (Exception) {
          log(Exception.toString());
        }
      });
    } else {
      log("User canceled the picker");
      // User canceled the picker
    }
    return accounts;
  }

  @override
  Future<List<SimpleProxy>> loadAllProxyAsync() {
    // TODO: implement loadAllProxyAsync
    throw UnimplementedError();
  }

  @override
  Future<void> saveAccount(List<Account> allAccounts, Account account) async {
    final prefs = await SharedPreferences.getInstance();

    final accountFilePath = prefs.getString('accountFilePath');
    allAccounts.add(account);

    if (accountFilePath != null) {
      try {
        File file = File(accountFilePath);
        var encodedDataFile = jsonEncode(allAccounts.toString());
        file.writeAsString(
            encodedDataFile.replaceAll("\"", "").replaceAll("\'", "\""));
      } catch (exception, e) {
        log(exception.toString());
        log(e.toString());
      }
    } else {
      allAccounts.add(account);
      await SaveAccountsInDefaultDocumentFolder(allAccounts);
    }
  }

  @override
  Future<void> saveMultipleAccounts(List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();

    final accountFilePath = prefs.getString('accountFilePath');

    if (accountFilePath != null) {
      try {
        File file = File(accountFilePath);
        var encodedDataFile = jsonEncode(accounts.toString());

        file.writeAsString(
            encodedDataFile.replaceAll("\"", "").replaceAll("\'", "\""));
      } catch (exception, e) {
        log(exception.toString());
      }
    } else {
      await SaveAccountsInDefaultDocumentFolder(accounts);
    }
  }

  Future<void> SaveAccountsInDefaultDocumentFolder(
      List<Account> accounts) async {
    final prefs = await SharedPreferences.getInstance();

    final directory = await getApplicationDocumentsDirectory();
    await prefs.setString(
        'accountFileName', directory.path + "/" + "accounts.json");
    await prefs.setString(
        'accountFilePath', directory.path + "/" + "accounts.json");
    final accountFilePath = prefs.getString('accountFilePath');

    try {
      File file = File(accountFilePath.toString());
      var encodedDataFile = jsonEncode(accounts.toString());
      file.writeAsString(
          encodedDataFile.replaceAll("\"", "").replaceAll("\'", "\""));
    } catch (exception, e) {
      log(exception.toString());
      log(e.toString());
    }
  }
}
