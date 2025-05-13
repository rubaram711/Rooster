//
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rooster_app/Backend/ProductsBackend/edit_quantity_of_product.dart';
// // ignore: depend_on_referenced_packages
// import 'package:intl/intl.dart';
// import '../../Controllers/ProductController/products_controller.dart';
// import '../../Widgets/custom_snak_bar.dart';
// import '../../Widgets/dialog_title.dart';
// import '../../Widgets/reusable_btn.dart';
// import '../../Widgets/reusable_text_field.dart';
// import '../../const/colors.dart';
// import '../../const/sizes.dart';
//
//
//
// class EditQuantityDialog extends StatefulWidget {
//   const EditQuantityDialog({super.key, required this.id, this.isMobile=false});
// final String id;
// final bool isMobile;
//   @override
//   State<EditQuantityDialog> createState() =>
//       _EditQuantityDialogState();
// }
//
// class _EditQuantityDialogState extends State<EditQuantityDialog> {
//   TextEditingController quantityController = TextEditingController();
//   ProductController productController = Get.find();
//
//   @override
//   Widget build(BuildContext context) {
//     return  Container(
//       color: Colors.white,
//       // width: Sizes.deviceWidth*0.2,
//       height: 250,
//       // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
//       // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               DialogTitle(text: 'edit_quantity'.tr),
//               InkWell(
//                 onTap: () {
//                   Get.back();
//                 },
//                 child: CircleAvatar(
//                   backgroundColor: Primary.primary,
//                   radius: 15,
//                   child: const Icon(
//                     Icons.close_rounded,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//               )
//             ],
//           ),
//           gapH40,
//           ReusableInputNumberField(
//             controller: quantityController,
//             textFieldWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.2 : MediaQuery.of(context).size.width * 0.15,
//             rowWidth:widget.isMobile?  MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.25,
//             onChangedFunc: (val){},
//             validationFunc: (val){},
//             text: 'new_quantity'.tr,),
//           gapH32,
//           ReusableButtonWithColor(
//               btnText: 'apply'.tr,
//               radius: 9,
//               onTapFunction: () async {
//                 var now = DateTime.now();
//                 var formatter = DateFormat('yyyy-MM-dd');
//                 String formattedDate = formatter.format(now);
//                 if(quantityController.text.isNotEmpty) {
//                   var res = await editQuantityOfProduct(
//                       formattedDate, quantityController.text, widget.id);
//                   Get.back();
//                   if ('${res['success']}' == 'true') {
//                     productController.getAllProductsFromBack();
//                     CommonWidgets.snackBar(
//                         'Success', res['message']);
//                   } else {
//                     CommonWidgets.snackBar('error', res['message']);
//                   }
//                 }
//               },
//               width: MediaQuery.of(context).size.width * 0.25,
//               height: 50)
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
//
//
//
//
//
//
