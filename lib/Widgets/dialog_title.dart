import 'package:flutter/material.dart';

import '../const/colors.dart';

class DialogTitle extends StatelessWidget {
  const DialogTitle({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          fontWeight: FontWeight.bold,
          color: TypographyColor.titleTable,
          fontSize: 16),
    );
  }
}
