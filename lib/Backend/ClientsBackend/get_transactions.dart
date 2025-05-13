import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future getClientsTransactions(String search,String clientId) async {
  final uri = Uri.parse('$kClientsTransactionsUrl/$clientId').replace(queryParameters: {
    'search': search,
    'isPaginated':'0',
    'cashCustomers':'1',
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

