enum Status {
  subscribe,
  unsubscribe,
}

class Account {
  String email;
  String username;
  String password;
  Status status;

  Account(
      {required this.email,
      required this.username,
      required this.password,
      required this.status});

  // Factory method for JSON deserialization
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['email'],
      username: json['username'],
      password: json['password'],
      status: Status.subscribe,
    );
  }

  @override
  String toString() {
    return "{ 'email': '$email', 'username': '$username', 'password': '$password', 'status': '$status' }";
  }
}
