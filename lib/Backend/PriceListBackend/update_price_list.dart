
import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future updatePriceList({
  required String priceListId,
  required String title,
  required String code,
  required String vatInclusivePrices,
  required String derivedPrices,
  required String pricelistId,
  required String type,
  required String adjustmentPercentage,
  required String convertToCurrencyId,
  required String roundingMethod,
  required String roundingPrecision,
  required String transactionDisplayMode,
  required List categories,
  required List itemGroups,
  required String singleItemId,}
    ) async {

  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    'title': title,
    'code':code,
    'vatInclusivePrices':vatInclusivePrices,
    'derivedPrices':derivedPrices,
    'pricelistId':pricelistId,
    'type':type,
    'adjustmentPercentage':adjustmentPercentage,
    'convertToCurrencyId':convertToCurrencyId,
    'roundingMethod':roundingMethod,
    'roundingPrecision':roundingPrecision,
    'transactionDisplayMode':transactionDisplayMode,
  });

  if(singleItemId!='0'){
    formData.fields.add(MapEntry('singleItem', singleItemId));
  }

  for (int i = 0; i < itemGroups.length; i++) {
    formData.fields.add(MapEntry('itemGroups[$i]', '${itemGroups[i]}'));
  }

  for (int i = 0; i < categories.length; i++) {
    formData.fields.add(MapEntry('categories[$i]', '${categories[i]}'));
  }


  Response response = await Dio().post(
      '$kUpdatePriceListUrl/$priceListId',
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )    .catchError((err) {
    // print(100);
    // print(err.response);
    return err.response;
  });
  return response.data;
  // if(response.data['success'] == true){
  //   return 'success';
  // }else{
  //   return 'error';
  // }
}
