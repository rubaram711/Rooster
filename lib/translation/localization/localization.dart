// ignore_for_file: unused_local_variable
import 'package:get/get.dart';

import '../languages/ar.dart';
import '../languages/en.dart';


class AppLocalization implements Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {'en': en,'ar': ar};
}
