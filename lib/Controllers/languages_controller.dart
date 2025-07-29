// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class LanguagesController extends GetxController {
  // final storage = GetStorage();

  var language = 'en';

  // @override
  // void onInit() {
  //   super.onInit();
  //
  //   // getLanguageState();
  // }

  // getLanguageState() {
  //   if (storage.read('language') != null) {
  //     return setLanguage(storage.read('language'));
  //   }

  //   setLanguage('en');
  // }

  void setLanguage(String value) {
    language = value;

    Get.updateLocale(value == 'system'
        ? Get.deviceLocale!
        : Locale(value == 'en'
            ? 'en'
            : value == 'ar'
                ? 'ar'
                : 'en'));

    update();
  }
}
