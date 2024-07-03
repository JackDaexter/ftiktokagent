import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

class GmailGeneratorApi {
  static Future<Map<String, dynamic>> generateEmail() async {
    final response = await http.post(
      Uri.parse('https://gmailnator.p.rapidapi.com/generate-email'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'x-rapidapi-host': 'gmailnator.p.rapidapi.com',
        'x-rapidapi-key': '58b7f248c6msh8250181ba404c36p1db46fjsn3bbab41db9f0',
      },
      body: jsonEncode({
        'options': [1, 2, 3]
      }),
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      var json = jsonDecode(response.body);
      log(json.runtimeType.toString());
      return json;
    } else {
      log("Erreur lors de l'appel de l'API GmailGeneratorApi");
      return Map();
    }
  }
}
