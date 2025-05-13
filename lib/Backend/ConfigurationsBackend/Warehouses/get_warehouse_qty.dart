import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../const/urls.dart';




Future getQTyOfItemInWarehouse(
    String itemId, String warehouseId,
    ) async {
  final uri = Uri.parse(kGetQTyOfItemInWarehouseUrl);
  String token = await getAccessTokenFromPref();
  var response = await http.post(
      uri,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token"
      },
      body: {
        "itemId":itemId,
        "warehouseId":warehouseId,
      }
  );

  var p = json.decode(response.body);
  if(response.statusCode==200) {
    return p['data']['quantitiesInWarehouse'];
  }else {
    return [];
  }
}


// var p={
//   quantitiesInWarehouse: {qtyOnHand: 2.00,
// qtyOnHandPackages: null,
// item: {id: 87,
// company: {id: 1, name: company 1, active: 1, deleted_at: null, created_at: null, updated_at: null},
// warehouse: {id: 2, company_id: 1, name: w1, blocked: 0, is_main: 0, active: 1, created_at: 2024-02-25T17:15:10.000000Z,
// updated_at: 2024-02-25T17:15:10.000000Z, deleted_at: null, type: pos warehouse}, itemType: {id: 1, name: Regular, created_at: 2024-02-19T06:45:28.000000Z, updated_at: 2024-02-19T06:45:28.000000Z}, mainCode: okay, item_name: eyelashes, show_on_pos: 1, category: {id: 1, company_id: 1, category_name: Household items, _lft: 1, _rgt: 8, parent_id: null, deleted_at: null, created_at: 2024-02-22T15:42:54.000000Z, updated_at: 2024-02-22T15:42:54.000000Z}, printMainCode: 1, taxation: 11, lastCurrency: null, subref_id: {id: 1, name: Serial Number, created_at: 2024-02-19T06:45:28.000000Z, updated_at: 2024-02-19T06:45:28.000000Z}, canBeSold: 0, canBePurchased: 0, warranty: 0, lastAllowedPurchaseDate: null, shortDescription: null, mainDescription: main, secondLanguageDescription: null, supplierCodes: [], alternativeCodes: [], barcode: [], unitCost: 20, decimalCost: 0, currency: {id: 1, company_id: 1, name: USD, symbol: $, active: 1, created_at: 2024-02-21T09:18:47.000000Z, updated_at: 2024-02-21T09:18:47.000000Z, deleted_at: null, latest_rate: }, priceCurrency: {id: 1, company_id: 1, name: USD, symbol: $, active: 1, created_at: 2024-02-21T09:18:47.000000Z, updated_at: 2024-02-21T09:18:47.000000Z, deleted_at: null, latest_rate: }, posCurrency: {id: 1, company_id: 1, name: USD, symbol: $, active: 1, created_at: 2024-02-21T09:18:47.000000Z, updated_at: 2024-02-21T09:18:47.000000Z, deleted_at: null, latest_rate: }, quantity: 34, current_quantity: 28, sold_quantity: 6.00, unitPrice: 30, decimalPrice: 0, lineDiscountLimit: 0, packageType: 1, defaultTransactionPackageType: null, packageUnitName: rr, packageUnitQuantity: 3, packageSetName: null, packageSetQuantity: null, packageSupersetName: null, packageSupersetQuantity: null, packagePaletteName: null, packagePaletteQuantity: null, packageContainerName: null, packageContainerQuantity: null, decimalQuantity: 0, active: 1, images: []}}}