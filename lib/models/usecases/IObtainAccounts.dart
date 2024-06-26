import '../domain/Account.dart';
import '../domain/SimpleProxy.dart';

abstract class IObtainAccounts {
  Future<List<Account>> loadAllAccountsAsync();
  Future<void> saveMultipleAccounts(List<Account> accounts);
  Future<void> saveAccount(Account account);
  Future<List<SimpleProxy>> loadAllProxyAsync();
}
