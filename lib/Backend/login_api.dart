import 'package:http/http.dart' as http;
import 'dart:convert';
import '../const/urls.dart';


Future login(String email, String password) async {
  final uri = Uri.parse(kLoginUrl);
  var response = await http.post(uri, body: {
    'email': email,
    'password': password,
  });
  var p = json.decode(response.body);
  return p;
}
