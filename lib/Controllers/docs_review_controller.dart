import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class DocsReviewControllerAbstract extends GetxController {
  getAllFromBackWithSeach(String searchValue);
}

class DocsReviewController extends DocsReviewControllerAbstract {
  TextEditingController searchInComboController = TextEditingController();

  @override
  getAllFromBackWithSeach(String searchValue) {}
}
