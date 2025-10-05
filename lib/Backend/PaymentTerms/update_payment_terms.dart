import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';


Future updatePaymentTerms(String id,String code,String title) async {
  final uri = Uri.parse('$kUpdatePaymentTermsUrl/$id');
  String token = await getAccessTokenFromPref();
  var response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "title":title,
        "code":code,
      }
  );

  var p = json.decode(response.body);
  return p;//p['success']==true
}