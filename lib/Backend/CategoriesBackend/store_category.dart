import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future storeCategory(
    String categoryName,
    String parentId,
    ) async {
  final uri = Uri.parse(kStoreCategoryUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  }, body: {
    'categoryName': categoryName,
    'parentId': parentId,
  });

  var p = json.decode(response.body);
  return p; //p['success']==true
}
