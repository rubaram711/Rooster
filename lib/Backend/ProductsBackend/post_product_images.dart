import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future addImagesToProduct(String id,List images) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "item_id":id,
    // "images[0]": MultipartFile.fromBytes(content, filename: "image.jpg")
  });

  for (int i = 0; i < images.length; i++) {
      formData.files.addAll([
        MapEntry("images[$i]", MultipartFile.fromBytes(images[i], filename: "image.jpg"))
      ]);
    }

  Response response = await Dio().post(
      kUploadProductImageUrl,
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
    // print(err.response.data);
    return err.response;
  });
  return response.data;
  // if(response.statusCode == 200){
  //   return 'success';
  // }else{
  //   return 'error';
  // }
}

