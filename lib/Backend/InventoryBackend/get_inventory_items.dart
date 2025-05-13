import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';




Future getInventoryData(
    String singleItemId,
    String warehouseId,
    List categories,
    List itemGroups,
    ) async {
  // print('object $singleItemId');
  // print('object $warehouseId');
  // print('object $categories');
  // print('object $itemGroups');
  Map<String, String> queryParams = {
    'warehouseId': warehouseId,
  };
  if(singleItemId!='0'){
    queryParams['singleItem']=singleItemId;
  }

  for (int i = 0; i < itemGroups.length; i++) {
    queryParams['itemGroups[$i]'] = '${itemGroups[i]}';
  }

  for (int i = 0; i < categories.length; i++) {
    queryParams['categories[$i]'] = '${categories[i]}';
  }


  final uri = Uri.parse(kGetInventoryDataUrl).replace(queryParameters: queryParams);

  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  var p = json.decode(response.body);
  return p;
}

