import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future getCashTrayReport(String cashTrayId) async {
  String token = await getAccessTokenFromPref();
  // print('idddoo $cashTrayId');
  // print('iddd $sessionId');


  final uri = Uri.parse(kReportCashTrayUrl);
  var response = await http.post(
      uri,
      headers: {
        "Accept":"application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        'cashTrayId':cashTrayId,
      }

  ) ;
  var p = json.decode(response.body);
  // print('report $p');
  return p;
}
