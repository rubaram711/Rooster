import 'package:shared_preferences/shared_preferences.dart';

saveMenuState(bool isMenuOpened) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool('isMenuOpened', isMenuOpened);
}


Future<bool> getMenuState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isMenuOpened = prefs.getBool('isMenuOpened') ?? true;
  return isMenuOpened;
}