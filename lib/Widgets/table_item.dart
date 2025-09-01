import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../const/colors.dart';

class TableItem extends StatelessWidget {
  const TableItem({
    super.key,
    required this.text,
    required this.width,
    this.isDesktop = true,
    this.isCentered = true,
  });
  final String text;
  final double width;
  final bool isDesktop;
  final bool isCentered;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child:
          isCentered
              ? Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: TypographyColor.textTable,
                  ),
                ),
              )
              : Text(
                text,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: TypographyColor.textTable,
                ),
              ),
    );
  }
}
