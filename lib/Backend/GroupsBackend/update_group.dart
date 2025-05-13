import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future updateGroup(
    String id,
    String code,
    String name,
    // String parentId,
    ) async {
  // print('parentId');
  // print(parentId);
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.post(
      Uri.parse('$kUpdateGroupUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "code": code,
        "name": name,
        // "parentId":parentId
      }
  );
  var p = json.decode(response.body);
  return p;
}


