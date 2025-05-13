import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future getAllClients(String search) async {
  final uri = Uri.parse(kClientUrl).replace(queryParameters: {
    'name': search,
    'isPaginated':'0'
  });
  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  var p = json.decode(response.body);
  if(response.statusCode==200) {
    return p['data'];
  }else {
    return [];
  }
}

