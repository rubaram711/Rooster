import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future deleteGroup(String id) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.delete(
    Uri.parse('$kDeleteGroupUrl/$id'),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
  );
  return json.decode(response.body);
}


