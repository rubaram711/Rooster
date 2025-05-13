// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rooster_app/Widgets/reusable_btn.dart';
// import '../../../Controllers/home_controller.dart';
// import '../../../const/Sizes.dart';
// import '../../../const/colors.dart';
// import '../../Backend/CategoriesBackend/edit_category.dart';
// import '../../Controllers/CategoriesController/groups_controller.dart';
// import '../../Widgets/custom_snak_bar.dart';
// import '../../Widgets/dialog_title.dart';
// import '../../Widgets/reusable_text_field.dart';
//
// TextEditingController oldCatNameController = TextEditingController();
//
// class EditCategoryDialogContent extends StatefulWidget {
//   const EditCategoryDialogContent({super.key, required this.isMobile});
//   final bool isMobile;
//   @override
//   State<EditCategoryDialogContent> createState() =>
//       _EditCategoryDialogContentState();
// }
//
// class _EditCategoryDialogContentState extends State<EditCategoryDialogContent> {
//   final HomeController homeController = Get.find();
//   final CategoriesController categoriesController = Get.find();
//
//   final _formKey = GlobalKey<FormState>();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<CategoriesController>(
//       builder: (cont) {
//         return Container(
//           color: Colors.white,
//           height: 250,
//           // width: MediaQuery.of(context).size.width * 0.8,
//           // height: MediaQuery.of(context).size.height * 0.9,
//           // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DialogTitle(text: 'edit_category'.tr),
//                   InkWell(
//                     onTap: () {
//                       Get.back();
//                     },
//                     child: CircleAvatar(
//                       backgroundColor: Primary.primary,
//                       radius: 15,
//                       child: const Icon(
//                         Icons.close_rounded,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   )
//                 ],
//               ),
//               gapH32,
//               Form(
//                 key: _formKey,
//                 child: DialogTextField(
//                   textEditingController: oldCatNameController,
//                   text: '${'category_name'.tr}*',
//                   // rowWidth: MediaQuery.of(context).size.width * 0.4,
//                   // textFieldWidth: MediaQuery.of(context).size.width * 0.25,
//                   textFieldWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.2 : MediaQuery.of(context).size.width * 0.15,
//                   rowWidth:widget.isMobile?  MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.25,
//                   validationFunc: (String value) {
//                     if (value.isEmpty) {
//                       return 'This field is required';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               // gapH20,
//               // SizedBox(
//               //   width: MediaQuery.of(context).size.width * 0.4,
//               //   child: Row(
//               //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //       children: [
//               //     Text('check_children'.tr),
//               //     SizedBox(
//               //       width: MediaQuery.of(context).size.width * 0.25,
//               //       child: DropDownMultiSelect(
//               //         onChanged: (List<String> val) {
//               //           setState(() {
//               //             cont.setSelectedSubCategories(val);
//               //           });
//               //         },
//               //         options: categoriesController.categoriesNameList,
//               //         selectedValues: cont.selectedSubCategories,
//               //         decoration:   InputDecoration(
//               //           contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
//               //           // outlineBorder: BorderSide(color: Colors.black,),
//               //           enabledBorder: OutlineInputBorder(
//               //             borderSide:
//               //             BorderSide(color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
//               //             borderRadius: const BorderRadius.all(Radius.circular(9)),
//               //           ),
//               //           focusedBorder: OutlineInputBorder(
//               //             borderSide:
//               //             BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
//               //             borderRadius: const BorderRadius.all(Radius.circular(9)),
//               //           ),
//               //         ),
//               //       ),
//               //     ),
//               //   ]),
//               // ),
//               const Spacer(),
//               ReusableButtonWithColor(
//                   btnText: 'apply'.tr,
//                   radius: 9,
//                   onTapFunction: () async {
//                     if(_formKey.currentState!.validate()) {
//                       var res = await editCategory(oldCatNameController.text, '${categoriesController.selectedCategory['id']}');
//                       Get.back();
//                       if ('${res['success']}' == 'true') {
//                         categoriesController.getCategoriesFromBack();
//                         CommonWidgets.snackBar(
//                             'Success', res['message']);
//                       } else {
//                         CommonWidgets.snackBar('error', res['message']);
//                       }
//                     }
//                   },
//                   width: MediaQuery.of(context).size.width * 0.25,
//                   height: 50)
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.end,
//               //   children: [
//               //     TextButton(
//               //         onPressed: () {
//               //           setState(() {
//               //             oldCatNameController.clear();
//               //           });
//               //         },
//               //         child: Text(
//               //           'discard'.tr,
//               //           style: TextStyle(
//               //               decoration: TextDecoration.underline,
//               //               color: Primary.primary),
//               //         )),
//               //     gapW24,
//               //     ReusableButtonWithColor(
//               //         btnText: 'save'.tr,
//               //         onTapFunction: () async {
//               //           if (_formKey.currentState!.validate()) {
//               //             // var res = await editCategory(
//               //             //     oldCatNameController.text, categoriesController.selectedCategory['id']);
//               //             // if (res['success'] == true) {
//               //             //   Get.back();
//               //             //   homeController.selectedTab.value = 'categories';
//               //             //   categoriesController.getCategoriesFromBack();
//               //             //   CommonWidgets.snackBar(
//               //             //       'success', 'Category Created Successfully');
//               //             //   oldCatNameController.clear();
//               //             // } else {
//               //             //   CommonWidgets.snackBar(
//               //             //       'error', res['message']);
//               //             // }
//               //           }
//               //         },
//               //         width: 100,
//               //         height: 35),
//               //   ],
//               // )
//             ],
//           ),
//         );
//       }
//     );
//   }
//
//
// }
//
//
