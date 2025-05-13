// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rooster_app/Backend/CategoriesBackend/delete_category.dart';
// import 'package:rooster_app/const/colors.dart';
// import '../../Controllers/CategoriesController/groups_controller.dart';
// import '../../Widgets/custom_snak_bar.dart';
// import '../../Widgets/page_title.dart';
// import '../../Widgets/reusable_btn.dart';
// import '../../Widgets/reusable_text_field.dart';
// import '../../Widgets/table_item.dart';
// import '../../Widgets/table_title.dart';
// import '../../const/Sizes.dart';
// import 'add_new_category.dart';
// import 'edit_category_dialog.dart';
// TextEditingController searchCategoryController = TextEditingController();
//
// class CategoriesPage extends StatefulWidget {
//   const CategoriesPage({super.key});
//
//   @override
//   State<CategoriesPage> createState() => _CategoriesPageState();
// }
//
// class _CategoriesPageState extends State<CategoriesPage> {
//   CategoriesController categoriesController = Get.find();
//   String searchValue = '';
//   Timer? searchOnStoppedTyping;
//   _onChangeHandler(value) {
//     const duration = Duration(
//         milliseconds:
//         800); // set the duration that you want call search() after that.
//     if (searchOnStoppedTyping != null) {
//       setState(() => searchOnStoppedTyping!.cancel()); // clear timer
//     }
//     setState(
//             () => searchOnStoppedTyping = Timer(duration, () => search(value)));
//   }
//
//   search(value) async {
//     categoriesController.getCategoriesFromBack();
//   }
//   @override
//   void initState() {
//     categoriesController.getCategoriesFromBack();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width * 0.02),
//       child: GetBuilder<CategoriesController>(
//         builder: (cont) {
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     PageTitle(text: 'categories'.tr),
//                     ReusableButtonWithColor(
//                       width: MediaQuery.of(context).size.width * 0.15,
//                       height: 45,
//                       onTapFunction: () {
//                         // productController.clearData();
//                         // productController.getFieldsForCreateProductFromBack();
//                         showDialog<String>(
//                             context: context,
//                             builder: (BuildContext context) => const AlertDialog(
//                                   backgroundColor: Colors.white,
//                                   contentPadding: EdgeInsets.all(0),
//                                   titlePadding: EdgeInsets.all(0),
//                                   actionsPadding: EdgeInsets.all(0),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius:
//                                         BorderRadius.all(Radius.circular(9)),
//                                   ),
//                                   elevation: 0,
//                                   content: CreateCategoryDialogContent(),
//                                 ));
//                       },
//                       btnText: 'create_category'.tr,
//                     ),
//                   ],
//                 ),
//                 gapH16,
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.7,
//                       child: ReusableSearchTextField(
//                         hint: '${"search".tr}...',
//                         textEditingController: searchCategoryController,
//                         onChangedFunc: (val) {
//                           _onChangeHandler(val);
//                         },
//                         validationFunc: (val) {},
//                       ),
//                     ),
//                   ],
//                 ),
//                 gapH32,
//                 cont.isCategoriesFetched
//                     ?
//                 Column(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                                 horizontal:
//                                     MediaQuery.of(context).size.width * 0.01,
//                                 vertical: 15),
//                             decoration: BoxDecoration(
//                                 color: Primary.primary,
//                                 borderRadius:
//                                     const BorderRadius.all(Radius.circular(6))),
//                             child: Row(
//                               children: [
//                                 TableTitle(
//                                   text: 'category_name'.tr,
//                                   width: MediaQuery.of(context).size.width * 0.15,
//                                 ),
//                                 TableTitle(
//                                   text: 'sub_categories'.tr,
//                                   width: MediaQuery.of(context).size.width * 0.15,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             color: Colors.white,
//                             height: MediaQuery.of(context).size.height * 0.5,
//                             child: ListView.builder(
//                               itemCount: cont.categoriesList.length,
//                               itemBuilder: (context, index) =>
//                                   _categoryAsRowInTable(
//                                       cont.categoriesList[index],
//                                       index,
//                                       cont.categoriesList[index]['children']
//                               ),
//                             ),
//                           ),
//                         ],
//                       )
//                     : const Center(child: CircularProgressIndicator()),
//               ],
//             ),
//           );
//         }
//       ),
//     );
//   }
//
//   _categoryAsRowInTable(Map category, int index,List categoriesNameList) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//           horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 10),
//       decoration: BoxDecoration(
//           color: (index % 2 == 0) ? Primary.p10 : Colors.white,
//           borderRadius: const BorderRadius.all(Radius.circular(0))),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               TableItem(
//                 text: '${category['category_name'] ?? ''}',
//                 width: MediaQuery.of(context).size.width * 0.15,
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.15,
//                 child:   DropdownMenu(
//                   width: MediaQuery.of(context).size.width *
//                       0.15,
//                   // requestFocusOnTap: false,
//                   enableSearch: false,
//                   // controller: selectedRootController,
//                   // hintText: '${'search'.tr}...',
//                   menuHeight: 250,
//                   dropdownMenuEntries: categoriesNameList
//                       .map<DropdownMenuEntry>(
//                           ( option) {
//                         return DropdownMenuEntry(
//                           enabled: false,
//                           value: option['category_name'],
//                           label: option['category_name'],
//                         );
//                       }).toList(),
//                   // enableFilter: true,
//                   // onSelected: (String? val) {
//                   //   setState(() {
//                   //     selectedItem = val!;
//                   //     var index =
//                   //     categoriesNameList.indexOf(val);
//                   //     selectedCategoryId =
//                   //     categoriesIdsList[index];
//                   //   });
//                   // },
//                 ),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.05,
//                 child: InkWell(
//                   onTap: () async {
//                     categoriesController.setSelectedCategory(category);
//                     showDialog<String>(
//                         context: context,
//                         builder: (BuildContext context) => const AlertDialog(
//                           backgroundColor: Colors.white,
//                           contentPadding: EdgeInsets.all(0),
//                           titlePadding: EdgeInsets.all(0),
//                           actionsPadding: EdgeInsets.all(0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.all(Radius.circular(9)),
//                           ),
//                           elevation: 0,
//                           content: EditCategoryDialogContent(isMobile: false,),
//                         ));
//                   },
//                   child: Icon(
//                     Icons.mode_edit_outlined,
//                     color: Primary.primary,
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.05,
//                 child: InkWell(
//                   onTap: () async {
//                     var res = await deleteCategory(
//                         '${category['id']}');
//                     if ('${res['success']}' == 'true') {
//                       categoriesController.getCategoriesFromBack();
//                       CommonWidgets.snackBar('Success',
//                           res['message']);
//                     } else {
//                       CommonWidgets.snackBar(
//                           'error',   res['message']);
//                     }
//                   },
//                   child: Icon(
//                     Icons.delete_outline,
//                     color: Primary.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
