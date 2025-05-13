import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';



Future deleteImage(
    String itemId,
    String imgUrl,
    ) async {
  // print('itemId $itemId');
  // print('imgUrl');
  // print(imgUrl);
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.post(
      Uri.parse(kDeleteProductImageUrl),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "itemId": itemId,
        "imgUrl": imgUrl,
      }
  );
  var p = json.decode(response.body);
  return p;
}


