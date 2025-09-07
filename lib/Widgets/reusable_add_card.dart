import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../const/colors.dart';
import '../const/Sizes.dart';

class ReusableAddCard extends StatelessWidget {
  const ReusableAddCard({super.key, required this.text, required this.onTap});
  final String text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Row(
        children: [
          Icon(Icons.add_circle_rounded, color: Primary.primary, size: 25.sp),
          gapW6,
          Text(text, style: TextStyle(color: TypographyColor.textTable)),
        ],
      ),
    );
  }
}
