import 'package:shared_preferences/shared_preferences.dart';

saveDefaultWarehouseInfoLocally(String id,String name,String warehouseNumber,String warehouseAddress) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('DefaultWarehouseId', id);
  prefs.setString('DefaultWarehouseName', name);
  prefs.setString('DefaultWarehouseNumber', warehouseNumber);
  prefs.setString('DefaultWarehouseAddress', warehouseAddress);
}

Future<Map> getDefaultWarehouseInfoFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String id = prefs.getString('DefaultWarehouseId') ?? '';
  String name = prefs.getString('DefaultWarehouseName') ?? '';
  String warehouseNumber = prefs.getString('DefaultWarehouseNumber') ?? '';
  String warehouseAddress = prefs.getString('DefaultWarehouseAddress') ?? '';

  return {
    'DefaultWarehouseId':id,
    'DefaultWarehouseName': name,
    'DefaultWarehouseNumber': warehouseNumber,
    'DefaultWarehouseAddress': warehouseAddress,
  };
}



Future<String> getDefaultWarehouseNameFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String name = prefs.getString('DefaultWarehouseName') ?? '';
  return name;
}


Future<String> getDefaultWarehouseIdFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String id = prefs.getString('DefaultWarehouseId') ?? '';
  return id;
}

Future<String> getDefaultWarehouseNumberFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String number = prefs.getString('DefaultWarehouseNumber') ?? '';
  return number;
}
Future<String> getDefaultWarehouseAddressFromPref() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String warehouseAddress = prefs.getString('DefaultWarehouseAddress') ?? '';
  return warehouseAddress;
}


// //{id: 9,
// // company_id: 1,
// // name: JAD,
// // blocked: 0,
// // is_main: 0,
// // active: 1,
// // warehouse_number: WHS0000009,
// // default: 1,
// // address: null,
// // created_at: 2024-07-16T06:32:34.000000Z,
// // updated_at: 2024-07-16T06:32:34.000000Z,
// // deleted_at: null, type: pos warehouse}