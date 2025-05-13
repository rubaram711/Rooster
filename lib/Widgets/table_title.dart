import 'package:flutter/material.dart';


class TableTitle extends StatelessWidget {
  const TableTitle({super.key, required this.text, required this.width,  this.isCentered=true});
  final String text;
  final double width;
  final bool isCentered;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child:isCentered? Center(
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ): Padding(
        padding: const EdgeInsets.only(left: 3.0),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

