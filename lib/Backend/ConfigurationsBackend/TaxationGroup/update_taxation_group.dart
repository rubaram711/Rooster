import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updateTaxationGroup(
    String id,
    String name,
    String code,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdateTaxationGroupUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "name": name,
        "code": code,
      }
  );
  var p = json.decode(response.body);
  return p;
}


