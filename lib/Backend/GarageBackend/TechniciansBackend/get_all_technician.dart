import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';


Future getAllTechnicians(String search) async {
  final uri = Uri.parse(
    kCarTechniciansTermsUrl,
  ).replace(queryParameters: {'isPaginated': '0','search': search});
  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  var p = json.decode(response.body);
  return p;
}
