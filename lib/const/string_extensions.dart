


import 'package:get/get_utils/src/get_utils/get_utils.dart';

extension StringExtensions on String {
  bool get isValidEmail => GetUtils.isEmail(this);
}


