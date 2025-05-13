import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future getCurrencies() async {
  final uri = Uri.parse(kGetCurrenciesUrl);
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



//  Map<dynamic,dynamic> p={
//   'currencies':
//     [{'id': 1, 'company_id': 1, 'name': 'USD', 'symbol': '/', 'active': 1,
// 'created_at': '2024-02-21T09:18:47.000000Z', 'updated_at': '2024-02-21T09:18:47.000000Z', 'deleted_at': null,
// 'latest_rate': '', 'exchange_rates': []},
// {id: 2, company_id: 1, name: LBP, symbol: LBP, active: 1, created_at: 2024-03-27T16:48:37.000000Z, updated_at: null, deleted_at: null, latest_rate:
// 89500.00, exchange_rates: [{id: 8, currency_id: 2, company_id: 1, start_date: 2020-04-04, exchange_rate: 89500.00, created_at: 2024-03-27T12:30:11.000000Z, updated_at:
// 2024-03-27T12:30:11.000000Z, currency: LBP}]}],
// "discountTypes":[{id: 1, company_id: 1,
// type: complete, discount_value: 100, created_at:
// 2024-03-26T15:08:12.000000Z, updated_at:
// 2024-03-26T15:08:12.000000Z, deleted_at: null, float_discount_value: 100}, {id: 2, company_id: 1, type: half, discount_value: 50, created_at: 2024-03-27T13:14:10.000000Z, updated_at:
// 2024-03-27T13:14:10.000000Z, deleted_at: null, float_discount_value: 50}, {id: 3, company_id: 1, type: EMPLOYEE, discount_value: 20, created_at: 2024-04-28T18:01:02.000000Z,
// updated_at: 2024-04-28T18:01:02.000000Z, deleted_at: null, float_discount_value: 20}],
// 'cachingMethods': [{id: 2, company_id: 1, title: Cash, active: 1, created_at:
// 2024-04-29T07:37:49.000000Z, updated_at: 2024-04-29T07:37:49.000000Z, deleted_at: null},
// {id: 4, company_id: 1, title: Visa, active: 1, created_at: 2024-04-29T07:48:43.000000Z,
// updated_at: 2024-04-29T07:48:43.000000Z, deleted_at: null},
// {id: 5, company_id: 1, title: Master, active: 1,
// created_at: 2024-04-29T07:49:56.000000Z, updated_at:
// 2024-04-29T07:49:56.000000Z, deleted_at: null},
// {id: 6, company_id: 1, title: On Account, active: 1, created_at: 2024-04-29T07:50:51.000000Z, updated_at: 2024-04-29T07:50:51.000000Z,
// deleted_at: null}, {id: 7, company_id: 1, title: Pay Pal,
// active: 0, created_at: 2024-04-29T07:51:14.000000Z, updated_at: 2024-04-29T07:51:14.000000Z, deleted_at: null}]}


