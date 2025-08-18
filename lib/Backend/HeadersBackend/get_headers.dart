import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future getAllHeaders() async {
  final uri = Uri.parse(kHeadersUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  var p = json.decode(response.body);
  print(p);
  return p;
}