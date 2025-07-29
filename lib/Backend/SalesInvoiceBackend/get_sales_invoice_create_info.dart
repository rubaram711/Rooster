import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import 'package:rooster_app/const/urls.dart';

Future getFieldsForCreateSalesInvoice() async {
  final uri = Uri.parse(kGetFieldsForCreateSalesInvoiceUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  var p = json.decode(response.body);

  if (response.statusCode == 200) {
    return p['data'];
  } else {
    return [];
  }
}
