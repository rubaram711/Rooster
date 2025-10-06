
import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future storeProduct(
    List groups,
    String defaultTransactionPackageId,
    int showCurrencyId,
    String categoryId,
    int isBlocked,
    String itemName,
    String showOnPos,
    int warehouseId,
    int itemTypeId,
    String mainCode,
    int taxationGroupId,
    String itemCodesType,
    String itemCodesCode,
    int itemCodesPrint,
    String mainDescription,
    String shortDescription,
    String secondLanguageDescription,
    // String taxationGroupId,
    int subrefId,
    int canBeSold,
    int canBePurchased,
    int warranty,
    String lastAllowedPurchaseDate,//todo:send as date
    double unitCost,
    int decimalCost,
    int currencyId,
    int priceCurrencyId,
    String quantity,
    double unitPrice,
    int decimalPrice,
    double lineDiscountLimit,
    int packageId,
    String packageUnitName,
    String packageUnitQuantity,
    String packageSetName,
    String packageSetQuantity,
    String packageSupersetName,
    String packageSupersetQuantity,
    String packagePaletteName,
    String packagePaletteQuantity,
    String packageContainerName,
    String packageContainerQuantity,
    int decimalQuantity,
    List itemGroups,
    int discontinued,
    List codes,
    ) async {
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    'posCurrencyId':'$showCurrencyId',
    'isBlocked':'$isBlocked',
    'categoryId':categoryId,
    'itemName':itemName==''?mainCode:itemName,
    'showOnPos':showOnPos,
    "itemTypeId": '$itemTypeId',
    "mainCode": mainCode,
    "taxationGroupId": '$taxationGroupId',
    "mainDescription": mainDescription,
    "shortDescription": shortDescription,
    "secondLanguageDescription": secondLanguageDescription,
    "subrefId": '$subrefId',
    "canBeSold": '$canBeSold',
    "canBePurchased": '$canBePurchased',
    "warranty": '$warranty',
    "lastAllowedPurchaseDate": lastAllowedPurchaseDate,
    "unitCost": '$unitCost',
    "decimalCost": '$decimalCost',
    "currencyId": '$currencyId',
    "priceCurrencyId": '$priceCurrencyId',
    "quantity": quantity,
    "unitPrice": '$unitPrice',
    "decimalPrice": '$decimalPrice',
    "lineDiscountLimit": '$lineDiscountLimit',
    "packageId": '$packageId',
    "packageUnitName": packageUnitName.toUpperCase(),
    // "packageUnitQuantity": packageUnitQuantity,
    "packageSetName": packageSetName.toUpperCase(),
    'packageSetQuantity': packageSetQuantity,
    'packageSupersetName': packageSupersetName.toUpperCase(),
    'packageSupersetQuantity': packageSupersetQuantity,
    'packagePaletteName': packagePaletteName.toUpperCase(),
    'packagePaletteQuantity': packagePaletteQuantity,
    'packageContainerName': packageContainerName.toUpperCase(),
    'packageContainerQuantity': packageContainerQuantity,
    'decimalQuantity': '$decimalQuantity',
    // 'itemGroups': groups,
    'discontinued': '$discontinued',
    'defaultTransactionPackageId': defaultTransactionPackageId,
  });


  for (int i = 0; i < groups.length; i++) {
    formData.fields.addAll([
      MapEntry("itemGroups[$i][id]",'${groups[i]}'),
    ]);
  }
  for (int i = 1; i < codes.length; i++) {
    formData.fields.addAll([
      MapEntry("itemCodes[${i-1}][type]",
          codes[i]['type']=='alternative_code'
              ?'alternative'
              :codes[i]['type']=='supplier_code'
          ?'supplier':'barcode'),
      MapEntry("itemCodes[${i-1}][code]",'${codes[i]['code']}'),
      MapEntry("itemCodes[${i-1}][print]",'${codes[i]['print_on_invoice']==true?1:0}'),
    ]);
  }


  Response response = await Dio().post(
      kAddProductUrl,
      data: formData,
      options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }
      )
  )    .catchError((err) {
    // if (err is DioError) {
    //   print(err.response);
    // }
    return err.response;
  });
  // print('lll #%${response.data['data']}');
  return response.data;
  // if(response.data['success'] == true){
  //   return 'success';
  // }else{
  //   return 'error';
  // }
}
