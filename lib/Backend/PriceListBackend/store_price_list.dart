
import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future storePriceList({required String title,
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
// print('title $title');
// print('code $code');
// print('vatInclusivePrices $vatInclusivePrices');
// print('derivedPrices $derivedPrices');
// print('pricelistId $pricelistId');
// print('type $type');
// print('adjustmentPercentage $adjustmentPercentage');
// print('convertToCurrencyId $convertToCurrencyId');
// print('roundingMethod $roundingMethod');
// print('roundingPrecision $roundingPrecision');
// print('transactionDisplayMode $transactionDisplayMode');
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    'title': title,
    'code':code,
    'vatInclusivePrices':vatInclusivePrices,
    'derivedPrices':derivedPrices,
    'type':type,
    'adjustmentPercentage':adjustmentPercentage,
    'roundingMethod':roundingMethod,
    'roundingPrecision':roundingPrecision,
    'transactionDisplayMode':transactionDisplayMode
  });



  if(pricelistId!='' ){
    formData.fields.add(MapEntry('pricelistId', pricelistId));
  }

  if(convertToCurrencyId!=''){
    formData.fields.add(MapEntry('convertToCurrencyId', convertToCurrencyId));
  }

  if(singleItemId!='0'){
    formData.fields.add(MapEntry('singleItem', singleItemId));
  }else if(singleItemId=='0' && itemGroups.isEmpty && categories.isEmpty){
    formData.fields.add(MapEntry('allItems', '1'));
  }

  for (int i = 0; i < itemGroups.length; i++) {
    formData.fields.add(MapEntry('itemGroups[$i]', '${itemGroups[i]}'));
  }

  for (int i = 0; i < categories.length; i++) {
    formData.fields.add(MapEntry('categories[$i]', '${categories[i]}'));
  }


  Response response = await Dio().post(
      kPriceListUrl,
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
  // print(response.data['data']);
  return response.data;
  // if(response.data['success'] == true){
  //   return 'success';
  // }else{
  //   return 'error';
  // }
}
