import 'package:flutter/material.dart';
import '../../../const/colors.dart';

class UnderTitleBtn extends StatelessWidget {
  const UnderTitleBtn({super.key, required this.text, required this.onTap});
  final String text;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        margin:  EdgeInsets.only(
          right: MediaQuery.of(context).size.width * 0.009,
        ),
        decoration: BoxDecoration(
            color: Others.btnBg,
            borderRadius: const BorderRadius.all(Radius.circular(9))),
        child: Text(
          text,
          style: TextStyle(
            color: TypographyColor.titleTable,
          ),
        ),
      ),
    );
  }
}