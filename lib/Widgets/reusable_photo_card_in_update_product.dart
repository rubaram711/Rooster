import 'package:flutter/material.dart';

import '../const/colors.dart';

class ReusablePhotoCard extends StatelessWidget {
  const ReusablePhotoCard({super.key, required this.url});
  final String url;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(
          url,
          // height: 60,
          // width: 60,
          // fit: BoxFit.cover,
          // errorBuilder: (context, error, stackTrace) => loading(error.toString()),
          // loadingBuilder: (context, child, loadingProgress) => loading('laod'),
        ),
      ),
    );
  }
}

class ReusablePhotoCardInUpdateProduct extends StatelessWidget {
  const ReusablePhotoCardInUpdateProduct({
    super.key,
    required this.url,
    required this.func,
  });
  final String url;
  // final int index;
  final Function func;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(
              url,
              // height: 60,
              // width: 60,
              // fit: BoxFit.cover,
              // errorBuilder: (context, error, stackTrace) => loading(error.toString()),
              // loadingBuilder: (context, child, loadingProgress) => loading('laod'),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 10,
          child: InkWell(
            onTap: () {
              func();
            },
            child: CircleAvatar(
              backgroundColor: Primary.p20,
              radius: 10,
              child: Icon(Icons.close, size: 17, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
