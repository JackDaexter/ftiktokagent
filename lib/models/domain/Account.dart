enum Compte {
  subscribe,
  unsubscribe,
}

class Account {
  String email;
  String username;
  String password;

  Account(
      {required this.email, required this.username, required this.password});

  // Factory method for JSON deserialization
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'],
      username: json['username'],
      password: json['password'],
    );
  }

  @override
  String toString() {
    return "{ email : "+this.email+","+ "username : " + this.username + ", password :" + this.password +" }";
  }
}
