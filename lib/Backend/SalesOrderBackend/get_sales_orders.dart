import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future getAllSalesOrder(String search) async {
  final uri = Uri.parse(kGetAllSalesOrderUrl).replace(
    queryParameters: {
      'search': search,
      'isPaginated': '0',
      'exceptStatus': 'pending',
    },
  );
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

Future getAlllSlaesOrderWithoutExcept(String search) async {
  final uri = Uri.parse(
    kGetAllSalesOrderUrl,
  ).replace(queryParameters: {'search': search, 'isPaginated': '0'});
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


// List quotationsList=[
//  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//    'order':'0001'
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Cancelled',
//     'order':'0002'
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Quotation Sent',
//     'order':'0003'
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Cancelled',
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Quotation Sent',
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Cancelled',
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Quotation Sent',
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Pending',
//   },
//   {
//     'number':'Q230000019',
//     'creation':'29/11/2023',
//     'customer':'QUASAR',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Cancelled',
//   },  {
//     'number':'Q230000017',
//     'creation':'27/11/2023',
//     'customer':'Nahhouli',
//     'salesperson':'',
//     'task':'No Records',
//     'total':'166.50',
//     'status':'Quotation Sent',
//   }
//
//
// ];