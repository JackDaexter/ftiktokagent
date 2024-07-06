import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

Future<http.Response> fetchInbox(String email) async {
  const url = 'https://gmailnator.p.rapidapi.com/inbox';
  const apiKey =
      '58b7f248c6msh8250181ba404c36p1db46fjsn3bbab41db9f0'; // Replace with your actual RapidAPI key

  final headers = {
    'Content-Type': 'application/json',
    'x-rapidapi-host': 'gmailnator.p.rapidapi.com',
    'x-rapidapi-key': apiKey,
  };

  final body = jsonEncode({'email': email, 'limit': 10});

  log(body);
  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  return response;
}
