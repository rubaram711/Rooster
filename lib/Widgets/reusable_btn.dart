import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../const/colors.dart';

class ReusableButtonWithNoColor extends StatelessWidget {
  const ReusableButtonWithNoColor({
    super.key,
    required this.btnText,
    required this.onTapFunction,
    this.width = 100,
    this.height = 45,
  });
  final String btnText;
  final Function onTapFunction;
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapFunction();
      },
      child: Container(
        // padding: EdgeInsets.all(5),
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: Primary.primary),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            btnText,
            style: TextStyle(fontSize: 12, color: Primary.primary),
          ),
        ),
      ),
    );
  }
}

class ReusableButtonWithColor extends StatelessWidget {
  const ReusableButtonWithColor({
    super.key,
    required this.btnText,
    required this.onTapFunction,
    required this.width,
    required this.height,
    this.radius = 4,
    this.isDisable = false,
  });
  final String btnText;
  final Function onTapFunction;
  final double width;
  final double height;
  final double radius;
  final bool isDisable;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          isDisable
              ? null
              : () {
                onTapFunction();
              },
      child: Container(
        // padding: EdgeInsets.all(5),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Primary.primary,
          border: Border.all(color: Primary.p0),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Center(
          child: Text(
            btnText,
            style: TextStyle(fontSize: 12, color: Primary.p0),
          ),
        ),
      ),
    );
  }
}

class ReusableBuildTabChipItem extends StatelessWidget {
  const ReusableBuildTabChipItem({
    super.key,
    required this.name,
    required this.index,
    required this.function,
    required this.isClicked,
    this.isMobile=false,
  });
  final String name;
  final int index;
  final Function function;
  final bool isClicked;
  final bool isMobile;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: ClipPath(
        clipper: const ShapeBorderClipper(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
            ),
          ),
        ),
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.09,
          // height: MediaQuery.of(context).size.height * 0.07,
          padding:   EdgeInsets.symmetric(horizontal: isMobile?5:50, vertical: 10),
          decoration: BoxDecoration(
            color: isClicked ? Primary.p20 : Colors.white,
            border:
                isClicked
                    ? Border(top: BorderSide(color: Primary.primary, width: 3))
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                spreadRadius: 9,
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Primary.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
