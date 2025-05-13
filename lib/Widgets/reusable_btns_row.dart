import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import '../../const/colors.dart';
import '../const/Sizes.dart';

// class ReusableBTNsRow extends StatefulWidget {
//   const ReusableBTNsRow(
//       {super.key,
//         required this.onDiscardClicked,
//         required this.onNextClicked,
//         required this.onSaveClicked,
//         this.isTheLastTab = false,
//         required this.onBackClicked,
//         this.isTheFirstTab = false});
//   final Function onDiscardClicked;
//   final Function onNextClicked;
//   final Function onSaveClicked;
//   final Function onBackClicked;
//   final bool isTheLastTab;
//   final bool isTheFirstTab;
//   @override
//   State<ReusableBTNsRow> createState() => _ReusableBTNsRowState();
// }
//
// class _ReusableBTNsRowState extends State<ReusableBTNsRow> {
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         widget.isTheFirstTab == false
//             ? InkWell(
//           onTap: () {
//             widget.onBackClicked();
//           },
//           child: Container(
//             // padding: EdgeInsets.all(5),
//             width: 100,
//             height: 35,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border.all(
//                 color: Primary.primary,
//               ),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Center(
//               child: Text(
//                 'back'.tr,
//                 style: TextStyle(fontSize: 12, color: Primary.primary),
//               ),
//             ),
//           ),
//         )
//             : const SizedBox(),
//         gapW24,
//         widget.isTheLastTab
//             ? InkWell(
//           onTap: () {
//             widget.onSaveClicked();
//           },
//           onDoubleTap: () {},
//           child: Container(
//             // padding: EdgeInsets.all(5),
//             width: 100,
//             height: 35,
//             decoration: BoxDecoration(
//               color: Primary.primary,
//               border: Border.all(
//                 color: Primary.p0,
//               ),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Center(
//               child: Text(
//                 'save'.tr,
//                 style: TextStyle(fontSize: 12, color: Primary.p0),
//               ),
//             ),
//           ),
//         )
//             : ReusableButtonWithColor(
//             btnText: 'next'.tr,
//             onTapFunction: () {
//               widget.onNextClicked();
//             },
//             width: 100,
//             height: 35),
//         gapW24,
//         TextButton(
//             onPressed: () {
//               widget.onDiscardClicked();
//             },
//             child: Text(
//               'discard'.tr,
//               style: TextStyle(
//                   decoration: TextDecoration.underline, color: Primary.primary),
//             )),
//       ],
//     );
//   }
// }

class ReusableBTNsRow extends StatefulWidget {
  const ReusableBTNsRow(
      {super.key,
        required this.onDiscardClicked,
        required this.onNextClicked,
        required this.onSaveClicked,
        this.isTheLastTab = false,
        required this.onBackClicked,
        this.isTheFirstTab = false});
  final Function onDiscardClicked;
  final Function onNextClicked;
  final Function onSaveClicked;
  final Function onBackClicked;
  final bool isTheLastTab;
  final bool isTheFirstTab;
  @override
  State<ReusableBTNsRow> createState() => _ReusableBTNsRowState();
}

class _ReusableBTNsRowState extends State<ReusableBTNsRow> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // widget.isTheFirstTab == false
            //     ? InkWell(
            //   onTap: () {
            //     widget.onBackClicked();
            //   },
            //   child: Container(
            //     // padding: EdgeInsets.all(5),
            //     width: 100,
            //     height: 35,
            //     decoration: BoxDecoration(
            //       color: Colors.white,
            //       border: Border.all(
            //         color: Primary.primary,
            //       ),
            //       borderRadius: BorderRadius.circular(4),
            //     ),
            //     child: Center(
            //       child: Text(
            //         'back'.tr,
            //         style: TextStyle(fontSize: 12, color: Primary.primary),
            //       ),
            //     ),
            //   ),
            // )
            //     : const SizedBox(),
            gapW24,
            // widget.isTheLastTab
            //     ?
            InkWell(
              onTap: () {
                cont.validationFunction(context);
              },
              onDoubleTap: () {},
              child: Container(
                // padding: EdgeInsets.all(5),
                width: 100,
                height: 35,
                decoration: BoxDecoration(
                  color: Primary.primary,
                  border: Border.all(
                    color: Primary.p0,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'save'.tr,
                    style: TextStyle(fontSize: 12, color: Primary.p0),
                  ),
                ),
              ),
            ),
                // : ReusableButtonWithColor(
                // btnText: 'next'.tr,
                // onTapFunction: () {
                //   widget.onNextClicked();
                // },
                // width: 100,
                // height: 35),
            gapW24,
            TextButton(
                onPressed: () {
                  widget.onDiscardClicked();
                },
                child: Text(
                  'discard'.tr,
                  style: TextStyle(
                      decoration: TextDecoration.underline, color: Primary.primary),
                )),
          ],
        );
      }
    );
  }
}