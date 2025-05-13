// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rooster_app/Widgets/reusable_btn.dart';
// import '../../../Controllers/home_controller.dart';
// import '../../../Controllers/ProductController/products_controller.dart';
// import '../../../const/Sizes.dart';
// import '../../../const/colors.dart';
// import '../../Backend/CategoriesBackend/get_categories.dart';
// import '../../Backend/CategoriesBackend/store_category.dart';
// import '../../Controllers/CategoriesController/groups_controller.dart';
// import '../../Widgets/custom_snak_bar.dart';
// import '../../Widgets/dialog_title.dart';
// import '../../Widgets/reusable_text_field.dart';
//
//
// TextEditingController catNameController = TextEditingController();
// TextEditingController selectedRootController = TextEditingController();
// class CreateCategoryDialogContent extends StatefulWidget {
//   const CreateCategoryDialogContent({super.key});
//
//   @override
//   State<CreateCategoryDialogContent> createState() =>
//       _CreateCategoryDialogContentState();
// }
//
// class _CreateCategoryDialogContentState
//     extends State<CreateCategoryDialogContent> {
//   int selectedTabIndex = 0;
//   final HomeController homeController = Get.find();
//   final CategoriesController categoriesController = Get.find();
//   final ProductController productController = Get.find();
//   bool isYesClicked=false;
//   List<String> categoriesNameList = [];
//   List categoriesIdsList = [];
//   String selectedCategoryId = '';
//   String? selectedItem = '';
//   bool isCategoriesFetched=false;
//   getCategoriesFromBack() async {
//     setState(() {
//       categoriesNameList = [];
//       categoriesIdsList = [];
//       isCategoriesFetched=false;
//       selectedItem = '';
//       selectedCategoryId = '';
//     });
//     var p = await getCategories('');
//     setState(() {
//       for (var cat in p) {
//         categoriesNameList.add('${cat['category_name']}');
//         categoriesIdsList.add('${cat['id']}');
//       }
//       isCategoriesFetched = true;
//     });
//   }
//   final _formKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     catNameController.clear();
//     selectedRootController.clear();
//     getCategoriesFromBack();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       width: MediaQuery.of(context).size.width * 0.8,
//       height: MediaQuery.of(context).size.height * 0.9,
//       margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
//       // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               DialogTitle(text: 'create_category'.tr),
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
//           gapH56,
//           Form(
//             key: _formKey,
//             child: DialogTextField(
//               textEditingController: catNameController,
//               text: '${'category_name'.tr}*',
//               rowWidth:  MediaQuery.of(context).size.width * 0.4,
//               textFieldWidth:  MediaQuery.of(context).size.width * 0.25,
//               validationFunc: (String value){
//                 if(value.isEmpty){
//                   return 'required_field'.tr;
//                 }return null;
//               },
//             ),
//           ),
//           gapH40,
//           Row(
//             children: [
//               Text('is_it_sub'.tr),
//               gapW20,
//               InkWell(
//                 onTap: (){
//                   setState(() {
//                     isYesClicked=true;
//                   });
//                 },
//                 child:Container(
//                   padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
//                   color: isYesClicked?Colors.green:Colors.grey,
//                   child: Text('yes'.tr),
//                 )
//               ) ,
//               gapW12,
//               InkWell(
//                 onTap: (){
//                   setState(() {
//                     isYesClicked=false;
//                   });
//                 },
//                 child:Container(
//                   padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
//                   color: !isYesClicked?Colors.green:Colors.grey,
//                   child: Text('no'.tr),
//                 )
//               )
//             ],
//           ),
//           gapH32,
//           isYesClicked?
//           isCategoriesFetched?SizedBox(
//             width:  MediaQuery.of(context).size.width * 0.4,
//             child: Row(
//               mainAxisAlignment:
//               MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('${'main_category_name'.tr}*'),
//                 DropdownMenu<String>(
//                   width: MediaQuery.of(context).size.width *
//                       0.25,
//                   // requestFocusOnTap: false,
//                   enableSearch: true,
//                   controller: selectedRootController,
//                   // hintText: '${'search'.tr}...',
//                   inputDecorationTheme:
//                   InputDecorationTheme(
//                     // filled: true,
//                     hintStyle: const TextStyle(
//                         fontStyle: FontStyle.italic),
//                     contentPadding:
//                     const EdgeInsets.fromLTRB(
//                         20, 0, 25, 5),
//                     // outlineBorder: BorderSide(color: Colors.black,),
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Primary.primary
//                               .withAlpha((0.2 * 255).toInt()),
//                           width: 1),
//                       borderRadius: const BorderRadius.all(
//                           Radius.circular(9)),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: BorderSide(
//                           color: Primary.primary
//                               .withAlpha((0.4 * 255).toInt()),
//                           width: 2),
//                       borderRadius: const BorderRadius.all(
//                           Radius.circular(9)),
//                     ),
//                   ),
//                   // menuStyle: ,
//                   menuHeight: 250,
//                   dropdownMenuEntries: categoriesNameList
//                       .map<DropdownMenuEntry<String>>(
//                           (String option) {
//                         return DropdownMenuEntry<String>(
//                           value: option,
//                           label: option,
//                         );
//                       }).toList(),
//                   enableFilter: true,
//                   onSelected: (String? val) {
//                     setState(() {
//                       selectedItem = val!;
//                       var index =
//                       categoriesNameList.indexOf(val);
//                       selectedCategoryId =
//                       categoriesIdsList[index];
//                     });
//                   },
//                 ),
//               ],
//             ),
//           ):const CircularProgressIndicator()
//
//               :const SizedBox(),
//           const Spacer(),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               TextButton(
//                   onPressed: (){
//                     setState(() {
//                       catNameController.clear();
//                       selectedRootController.clear();
//                     });
//                   },
//                   child: Text('discard'.tr,style: TextStyle(
//                       decoration: TextDecoration.underline,
//                       color: Primary.primary
//                   ),)),
//               gapW24,
//               ReusableButtonWithColor(btnText: 'save'.tr, onTapFunction: ()async{
//                 if(_formKey.currentState!.validate()) {
//                   var res = await storeCategory(
//                       catNameController.text, selectedCategoryId);
//                   if (res['success'] == true) {
//                     Get.back();
//                     homeController.selectedTab.value =
//                     'categories';
//                     categoriesController.getCategoriesFromBack();
//                     CommonWidgets.snackBar('',
//                         res['message'] );
//                     catNameController.clear();
//                   } else {
//                     CommonWidgets.snackBar('error',
//                         res['message']);
//                   }
//                 }
//               }, width: 100, height: 35),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
//
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
