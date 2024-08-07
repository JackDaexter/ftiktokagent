import 'dart:developer';

import 'package:my_app/models/infrastructure/IObtainAccounts.dart';

import '../api/gmai_generator_api.dart';

class AccountObject {
  String email;
  AccountObject({required this.email});
}

class CreateRandomGmailAccount {
  //final IObtainAccounts accountRepository;
  CreateRandomGmailAccount();

  Future<String> generateEmail() async {
    Map<String, dynamic> response = await GmailGeneratorApi.generateEmail();
    log(response.toString());
    var account = response['email'];
    log(account);
    return account;
  }
}

abstract class IAccountRepository {
  late String email;
  late String password;
  late String name;
}
