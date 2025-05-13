// import 'package:shared_preferences/shared_preferences.dart';
//
//
// Future<String> getTabFromPref() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String tab = prefs.getString('tab') ?? 'dashboard_summary';
//   return tab;
// }
//
// Future<bool> getIsOpenedFromPref() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   bool isOpened = prefs.getBool('is_opened') ?? true;
//   return isOpened;
// }
//
// saveHomeInfoLocally(String tab,bool isOpened) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setString('tab', tab);
//   prefs.setBool('is_opened', isOpened);
// }
//
// saveTabLocally(String tab) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setString('tab', tab);
// }
//
// saveIsOpenedLocally(bool isOpened) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   prefs.setBool('is_opened', isOpened);
// }