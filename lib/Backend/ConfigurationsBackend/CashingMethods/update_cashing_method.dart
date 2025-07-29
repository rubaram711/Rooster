import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';

import 'dart:typed_data';


import 'package:dio/dio.dart';

Future oldUpdateCashingMethod(
    String id,
    String title,
    String active,
    ) async {
  String token = await getAccessTokenFromPref();
  final http.Response response = await http.put(
      Uri.parse('$kUpdateCashingMethodUrl/$id'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "title": title,
        "active": active,
      }
  );
  var p = json.decode(response.body);
  return p;
}





Future updateCashingMethod(
    String id,
    String title,
    String active,Uint8List? image) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "title": title,
    "active": active,
  });

  if(image !=null) {
    formData.files.addAll([
      MapEntry("image", MultipartFile.fromBytes(image, filename: "image.jpg"))
    ]);
  }


  Response response = await Dio().post(
      '$kUpdateCashingMethodUrl/$id',
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )   .catchError((err) {
    // print('err.response');
    // print(err.response);
    return err.response;
  });

  return response.data;
  // if(response.statusCode == 200){
  //   return 'success';
  // }else{
  //   return 'error';
  // }
}

