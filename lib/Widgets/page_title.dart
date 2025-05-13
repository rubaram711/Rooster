import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const/colors.dart';

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.text});
final String text;
  @override
  Widget build(BuildContext context) {
    return   Text(text.tr,style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Primary.primary
    ),);
  }
}
