

import 'package:flutter/material.dart';

import '../const/Sizes.dart';




class LoadingDialog extends StatelessWidget {
  const LoadingDialog({super.key, this.text='Wait'});
 final String text;
  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.white,
      width: 50,
      height: 100,
      // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          gapH20,
          Text(text),
        ],
      ),
    );
  }
}










