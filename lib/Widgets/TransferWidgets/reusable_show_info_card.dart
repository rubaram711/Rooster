import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';

class ReusableShowInfoCard extends StatelessWidget {
  const ReusableShowInfoCard({
    super.key,
    required this.text,
    required this.width,
    this.isCentered = true,
    this.isResponsive = false,
  });
  final String text;
  final double width;
  final bool isCentered;
  final bool isResponsive;
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return Container(
      width: width,
      height:
          isResponsive
              ? 47
              : homeController.isMobile.value
              ? 55
              : 47,
      // height:homeController.isMobile.value?55: 47,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black.withAlpha((0.1 * 255).toInt()),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child:
          isCentered
              ? Center(child: Text(text))
              : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Text('  $text')],
              ),
    );
  }
}
