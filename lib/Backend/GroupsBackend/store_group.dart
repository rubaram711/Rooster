import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future oldStoreGroup(
    String name,
    String code,
    String parentId,
    ) async {
  final uri = Uri.parse(kStoreGroupUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    'name': name,
    'code':code,
    'parentId': parentId,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}


Future storeGroup(data)async{
  final dio = Dio();
  String token = await getAccessTokenFromPref();
  final response = await dio.post(
    kStoreGroupUrl,
    options: Options(
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    ),
    data: FormData.fromMap(data),
  );

  return response.data;
}