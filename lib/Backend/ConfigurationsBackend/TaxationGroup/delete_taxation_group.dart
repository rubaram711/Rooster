import 'package:http/http.dart' as http;
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';





Future<http.Response> deleteTaxationGroup(String id) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.delete(
    Uri.parse('$kDeleteTaxationGroupUrl/$id'),
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  return response;
}