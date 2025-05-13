import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';


Future updateImagesInProduct(String id,List images) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    "item_id":id,
  });

  for (int i = 0; i < images.length; i++) {
    formData.files.addAll([
      MapEntry("images[$i]", MultipartFile.fromBytes(images[i], filename: "image[$i].jpg"))
    ]);
  }

  Response response = await Dio().post(
      kUpdateProductImageUrl,
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

  if(response.statusCode == 200){
    return 'success';
  }else{
    return 'error';
  }
}

