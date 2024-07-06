import '../domain/Account.dart';
import '../domain/SimpleProxy.dart';

abstract class IObtainAccounts {
  Future<List<Account>> LoadAllAccountsAsync();
  Future<List<SimpleProxy>> LoadAllProxyAsync();
  Future<void> SaveAccount(Account account);
  Future<void> SaveMultipleAccounts(List<Account> account);
}
