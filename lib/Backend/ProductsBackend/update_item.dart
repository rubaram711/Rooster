import 'package:dio/dio.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future updateProduct(
    List groups,
    String id,
    // String defaultTransactionPackageId,
    int showCurrencyId,
    int isBlocked,
    String transferDate,
    String startDate,
    String categoryId,
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
    int subrefId,
    int canBeSold,
    int canBePurchased,
    int warranty,
    String lastAllowedPurchaseDate,
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
    List codes) async {
  // print('mainDescription $mainDescription');
  // print('SelectedProductId $id');
  // print('shown $showCurrencyId');
  // print('shown $packageId');
  // print('posCurrencyId $showCurrencyId');
  // print('isBlocked $isBlocked');
  // print('categoryId $categoryId');
  // print('itemName $itemName');
  // print('showOnPos $showOnPos');
  // print("itemTypeId $itemTypeId");
  // print("mainCode $mainCode");
  // print("taxationGroupId $taxationGroupId");
  // print("subrefId $subrefId");
  // print("canBeSold $canBeSold");
  // print("canBePurchased $canBePurchased");
  // print("warranty $warranty");
  // print("lastAllowedPurchaseDate $lastAllowedPurchaseDate");
  // print("unitCost $unitCost");
  // print("decimalCost $decimalCost");
  // print("currencyId $currencyId");
  // print("priceCurrencyId $priceCurrencyId");
  // print("quantity $quantity");
  // print("unitPrice $unitPrice");
  // print("decimalPrice  $decimalPrice");
  // print('lineDiscountLimit $lineDiscountLimit');
  // print("packageId $packageId");
  // print("packageUnitName $packageUnitName");
  // print("packageSetName ${packageSetName.toUpperCase()}");
  // print('packageSetQuantity $packageSetQuantity');
  // print('packageSupersetName $packageSupersetName');
  // print('packageSupersetQuantity $packageSupersetQuantity');
  // print('packagePaletteName ${packagePaletteName.toUpperCase()}');
  // print('packagePaletteQuantity $packagePaletteQuantity');
  // print('packageContainerName ${packageContainerName.toUpperCase()}');
  // print('packageContainerQuantity $packageContainerQuantity');
  // print('decimalQuantity$decimalQuantity');
  // print('discontinued$discontinued');
  String token = await getAccessTokenFromPref();
  FormData formData = FormData.fromMap({
    'itemId': id,
    'posCurrencyId': '$showCurrencyId',
    'isBlocked': '$isBlocked',
    'categoryId': categoryId,
    'itemName': itemName == '' ? mainCode : itemName,
    'showOnPos': showOnPos,
    //  "warehouseId": '1', //todo '$warehouseId',
    "itemTypeId": '$itemTypeId', //todo ???
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
    "quantity": 0,
    // "unitPrice": '$unitPrice',
    "updatedPrice": '$unitPrice',
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
    // 'itemGroups': '[1]',
    'discontinued': '$discontinued',
    // 'defaultTransactionPackageId': defaultTransactionPackageId,
  });
  for (int i = 0; i < groups.length; i++) {
    formData.fields.addAll([
      MapEntry("itemGroups[$i][id]", '${groups[i]}'),
    ]);
  }
  for (int i = 1; i < codes.length; i++) {
    if (codes[i]['type'] == 'barcode') {
      formData.fields.addAll([
        MapEntry("barcodes[${i - 1}]", '${codes[i]['code']}'),
      ]);
    } else if (codes[i]['type'] == 'alternative_code') {
      formData.fields.addAll([
        MapEntry("alternativeCodes[${i - 1}]", '${codes[i]['code']}'),
      ]);
    } else if (codes[i]['type'] == 'supplier_code') {
      formData.fields.addAll([
        MapEntry("supplierCodes[${i - 1}]", '${codes[i]['code']}'),
      ]);
    }
    // formData.fields.addAll([
    //   MapEntry("itemCodes[${i - 1}][type]", '${codes[i]['type']}'),
    //   MapEntry("itemCodes[${i - 1}][code]", '${codes[i]['code']}'),
    //   MapEntry("itemCodes[${i - 1}][print]",
    //       '${codes[i]['print_on_invoice'] == true ? 1 : 0}'),
    // ]);
  }
  Response response = await Dio()
      .post(kUpdateItemUrl,
          data: formData,
          options: Options(headers: {
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
            "Authorization": "Bearer $token"
          }))
      .catchError((err) {
    // if (err is DioError) {
    //   print('err.responseup');
    //   print(err.response);
    // }
    return err.response;

  });
  return response.data;
  // if(response.data['success'] == true){
  //     return 'success';
  // }else{
  //     return 'error';
  // }
}
