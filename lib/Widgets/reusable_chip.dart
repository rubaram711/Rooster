import 'package:flutter/material.dart';

import '../const/colors.dart';

class ReusableChip extends StatelessWidget {
  const ReusableChip({super.key, required this.name, this.isDesktop = true});
  final String name;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
          width:
          isDesktop
              ? MediaQuery.of(context).size.width * 0.09
              : MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.07,
          // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          decoration: BoxDecoration(
            color: Primary.p20,
            border: Border(top: BorderSide(color: Primary.primary, width: 3)),
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
              name,
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