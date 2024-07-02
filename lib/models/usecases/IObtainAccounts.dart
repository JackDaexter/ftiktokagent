import '../domain/Account.dart';
import '../domain/SimpleProxy.dart';

abstract class IObtainAccounts {
  Future<List<Account>> loadAllAccountsAsync();
  Future<List<Account>> loadAllAccountsFromPreviousSessionAsync();
  Future<void> saveMultipleAccounts(List<Account> accounts);
  Future<void> saveAccount(List<Account> accountsData, Account account);
  Future<List<SimpleProxy>> loadAllProxyAsync();
}
