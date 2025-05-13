import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future editRole(
    String id,
    String name,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.post(
      Uri.parse('$kUpdateRoleUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "name": name,
      }
  );
  var p = json.decode(response.body);
  return p;
}


