import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import '../../../const/colors.dart';

class ReusableAddPhotoCircle extends StatelessWidget {
  const ReusableAddPhotoCircle({super.key, required this.onTapCircle});
  final Function onTapCircle;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTapCircle();
      },
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Primary.p20,
        child: DottedBorder(
            borderType: BorderType.Circle,
            color: Primary.primary,
            dashPattern: const [5, 10],
            child: Container(
                height: 80,
                width: 80,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    String.fromCharCode(Icons.add_rounded.codePoint),
                    style: TextStyle(
                      inherit: false,
                      color: Primary.primary,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      fontFamily: Icons.space_dashboard_outlined.fontFamily,
                    ),
                  ),
                ) // Icon(Icons.add,color: Primary.primary,),
                )),
      ),
    );
  }
}

class ReusablePhotoCircle extends StatelessWidget {
  const ReusablePhotoCircle({super.key, required this.imageFilePassed});
  final Uint8List imageFilePassed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(
          imageFilePassed,
        ),
      ),
    );
  }
}


class ReusablePhotoCircleInProduct extends StatelessWidget {
  const ReusablePhotoCircleInProduct({super.key, required this.imageFilePassed, required this.func});
  final Uint8List imageFilePassed;
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
            backgroundImage: MemoryImage(
              imageFilePassed,
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
