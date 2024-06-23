enum Compte {
  subscribe,
  unsubscribe,
}

class Account {
  String email;
  String username;
  String password;

  Account({required this.email,required this.username,required this.password});
}