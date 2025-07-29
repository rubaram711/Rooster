import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../Locale_Memory/save_user_info_locally.dart';
import '../../const/urls.dart';

Future getAllProducts(
  String searchByName,
  String searchByCat,
  String warehouseId,
  int currentPage,
) async {
  Map<String, dynamic> params =
      currentPage == -1
          ? {
            'search': searchByName,
            'searchByCat': searchByCat,
            'isPaginated': '0',
            'warehouseId': warehouseId,
          }
          : {
            'search': searchByName,
            'searchByCat': searchByCat,
            'isPaginated': '1',
            'perPage': '20',
            'page': '$currentPage',
            'warehouseId': warehouseId,
          };

  final uri = Uri.parse(kGetAllProductsUrl).replace(queryParameters: params);
  String token = await getAccessTokenFromPref();
  var response = await http.get(
    uri,
    headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
  );

  var p = json.decode(response.body);
  // print('object 55$p');
  if (response.statusCode == 200) {
    return p['data'];
  } else {
    return [];
  }
}

var s = {
  "id": 4,
  "company": {
    "id": 1,
    "name": "company 1",
    "active": 1,
    "deleted_at": null,
    "created_at": null,
    "updated_at": null,
  },
  "warehouse": null,
  "itemType": {
    "id": 1,
    "name": "Regular",
    "created_at": "2024-02-19T06:45:28.000000Z",
    "updated_at": "2024-02-19T06:45:28.000000Z",
  },
  "mainCode": "1212343",
  "item_name": "Lighter",
  "printMainCode": 1,
  "taxation": 0,
  "lastCurrency": null,
  "subref_id": {
    "id": 1,
    "name": "Serial Number",
    "created_at": "2024-02-19T06:45:28.000000Z",
    "updated_at": "2024-02-19T06:45:28.000000Z",
  },
  "canBeSold": 0,
  "canBePurchased": 0,
  "warranty": 0,
  "lastAllowedPurchaseDate": "24/11/2012",
  "shortDescription": "bla",
  "mainDescription":
      "Forfeited you engrossed bu sometimes explained. Another as studied it to evident. Merry sense given he be arise. Conduct at an replied removal an amongst",
  "secondLanguageDescription": null,
  "supplierCodes": [],
  "alternativeCodes": [],
  "barcode": [
    {
      "id": 1,
      "code": "434563",
      "print_code": 0,
      "company_id": 1,
      "item_id": 4,
      "created_at": "2024-02-21T06:30:34.000000Z",
      "updated_at": "2024-02-21T06:30:34.000000Z",
      "deleted_at": null,
    },
  ],
  "unitCost": 12,
  "decimalCost": 12,
  "currency": {
    "id": 2,
    "company_id": 1,
    "name": "LBP",
    "symbol": "LBP",
    "active": 1,
    "created_at": "2024-03-27T16:48:37.000000Z",
    "updated_at": null,
    "deleted_at": null,
    "latest_rate": "89500.00",
  },
  "priceCurrency": {
    "id": 2,
    "company_id": 1,
    "name": "LBP",
    "symbol": "LBP",
    "active": 1,
    "created_at": "2024-03-27T16:48:37.000000Z",
    "updated_at": null,
    "deleted_at": null,
    "latest_rate": "89500.00",
  },
  "quantity": 200,
  "current_quantity": 105,
  "sold_quantity": "95.00",
  "unitPrice": 900,
  "decimalPrice": 1,
  "lineDiscountLimit": 12,
  "packageType": 1,
  "packageUnitName": "xx",
  "packageUnitQuantity": "11",
  "packageSetName": "xx",
  "packageSetQuantity": "12",
  "packageSupersetName": "xx",
  "packageSupersetQuantity": "12",
  "packagePaletteName": "xx",
  "packagePaletteQuantity": "11",
  "packageContainerName": "xx",
  "packageContainerQuantity": "1",
  "decimalQuantity": 12,
  "active": 1,
  "images": [
    // "$baseImages/items/images/4/CVm5Zc5OTljVkFLyS9c03ib4b4wRRmYe1cSu3tXl.jpg",
  ],
};
