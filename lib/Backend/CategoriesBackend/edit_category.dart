import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future editCategory(
    String name,
    String id,
    ) async {
  final uri = Uri.parse('$kEditCategoryUrl/$id');
  String token = await getAccessTokenFromPref();
  var response = await http.put(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    "categoryName": name,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
