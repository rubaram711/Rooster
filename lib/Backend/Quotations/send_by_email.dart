import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';



Future sendByEmail(
    String id,
    ) async {
  final uri = Uri.parse('$kSendQuotationByEmailUrl/$id');
  String token = await getAccessTokenFromPref();
  var response = await http.post(uri, headers: {
    "Accept": "application/json",
    "Authorization": "Bearer $token"
  },
      body: {}
  ) .catchError((err) {
    // print('100');
    // print(err.response);
    return err.response;
    // if (err is DioError) {
    //   print(err.response);
    // }
  }
  );

  var p = json.decode(response.body);
  return p;
}




