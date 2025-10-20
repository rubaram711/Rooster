import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../AccountSettings/Users/create_user.dart';

class CreateAssignedToDialog extends StatefulWidget {
  const CreateAssignedToDialog({super.key, required this.enteredName});
final String enteredName;
  @override
  State<CreateAssignedToDialog> createState() =>
      _CreateAssignedToDialogState();
}

class _CreateAssignedToDialogState extends State<CreateAssignedToDialog> {
  List<String> nameList = [];
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  // final _formKey = GlobalKey<FormState>();
  late Uint8List imageFile;
  bool imageSelected=false;
  String selectedPhoneCode = '', selectedMobileCode = '';
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // double rowWidth=  MediaQuery.of(context).size.width * 0.3;
    // double textFieldWidth=  MediaQuery.of(context).size.width * 0.2;
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      child:   AddNewUser(isItDialog: true,enteredName: widget.enteredName,),
      // child: Form(
      //   key: _formKey,
      //   child: Column(
      //     children: [
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Row(
      //             children: [
      //               InkWell(
      //                 onTap: () {
      //                   Get.back();
      //                 },
      //                 child: Icon(Icons.arrow_back,
      //                     size: 22,
      //                     // color: Colors.grey,
      //                     color: Primary.primary),
      //               ),
      //               gapW10,
      //               PageTitle(text: 'create_assigned_to'.tr),
      //             ],
      //           ),
      //           InkWell(
      //             onTap: () {
      //               Get.back();
      //             },
      //             child: CircleAvatar(
      //               backgroundColor: Primary.primary,
      //               radius: 15,
      //               child: const Icon(
      //                 Icons.close_rounded,
      //                 color: Colors.white,
      //                 size: 20,
      //               ),
      //             ),
      //           )
      //         ],
      //       ),
      //       gapH70,
      //       Row(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           imageSelected==false ?
      //           ReusableAddPhotoCircle(
      //               onTapCircle: () async {
      //                 final image = await ImagePickerWeb.getImageAsBytes();
      //                 setState(() {
      //                   imageSelected=true;
      //                   imageFile = image!;
      //                 });
      //               }
      //           )
      //               :ReusablePhotoCircle(imageFilePassed: imageFile),
      //           gapW70,
      //           Column(
      //             children: [
      //               ReusableDropDownMenuWithSearch(
      //                 list: nameList,
      //                 text: '${'name'.tr}*',
      //                 hint: 'todo'.tr,
      //                 onSelected: (value) {},
      //                 validationFunc: (value) {
      //                   if (value == null || value.isEmpty) {
      //                     return 'select_option'.tr;
      //                   }
      //                   return null;
      //                 },
      //                 rowWidth: rowWidth,
      //                 textFieldWidth:  textFieldWidth,
      //                 controller: nameController,
      //                 clickableOptionText: '',
      //                 isThereClickableOption: false,
      //                 onTappedClickableOption: (){
      //                 },
      //               ),
      //               gapH32,
      //               DialogTextField(
      //                 textEditingController: emailController,
      //                 text: '${'email'.tr}*',
      //                 rowWidth: rowWidth,
      //                 textFieldWidth:  textFieldWidth,
      //                 validationFunc: (String value){
      //                   if(value.isEmpty){
      //                     return 'required_field'.tr;
      //                   }return null;
      //                 },
      //               ),
      //               gapH32,
      //               PhoneTextField(
      //                 textEditingController: phoneController,
      //                 text: 'phone'.tr,
      //                 rowWidth: rowWidth,
      //                 textFieldWidth: textFieldWidth,
      //                 validationFunc: (String val) {
      //                   if(val.isNotEmpty && val.length<7){
      //                     return '6_digits'.tr;
      //                   }return null;
      //                 },
      //                 onCodeSelected: (value) {
      //                   setState(() {
      //                     selectedPhoneCode = value;
      //                   });
      //                 },
      //                 onChangedFunc: (value) {
      //                   setState(() {
      //                     // mainDescriptionController.text=value;
      //                   });
      //                 },
      //               ),
      //               gapH32,
      //               PhoneTextField(
      //                 textEditingController: mobileController,
      //                 text: 'mobile'.tr,
      //                 rowWidth: rowWidth,
      //                 textFieldWidth: textFieldWidth,
      //                 validationFunc: (val) {
      //                   if(val.isNotEmpty && val.length<9){
      //                     return '6_digits'.tr;
      //                   }return null;
      //                 },
      //                 onCodeSelected: (value) {
      //                   setState(() {
      //                     selectedMobileCode = value;
      //                   });
      //                 },
      //                 onChangedFunc: (value) {
      //                   setState(() {
      //                     // mainDescriptionController.text=value;
      //                   });
      //                 },
      //               ),
      //             ],
      //           )
      //
      //         ],
      //       ),
      //       const Spacer(),
      //       Row(
      //         mainAxisAlignment: MainAxisAlignment.end,
      //         children: [
      //           TextButton(
      //               onPressed: (){
      //                 setState(() {
      //                   emailController.clear();
      //                   phoneController.clear();
      //                   mobileController.clear();
      //                   nameController.clear();
      //                 });
      //               },
      //               child: Text('discard'.tr,style: TextStyle(
      //                   decoration: TextDecoration.underline,
      //                   color: Primary.primary
      //               ),)),
      //           gapW24,
      //           ReusableButtonWithColor(btnText: 'save'.tr, onTapFunction: ()async{
      //             if(_formKey.currentState!.validate()) {
      //               // var res = await storeCategory(
      //               //     catNameController.text, selectedCategoryId);
      //               // if (res['success'] == true) {
      //               //   Get.back();
      //               //   // homeController.selectedTab.value =
      //               //   // 'categories';
      //               //   categoriesController.getCategoriesFromBack();
      //               //   CommonWidgets.snackBar('Success',
      //               //       res['message'] );
      //               //   catNameController.clear();
      //               // } else {
      //               //   CommonWidgets.snackBar('error',
      //               //       res['message']);
      //               // }
      //             }
      //           }, width: 100, height: 35),
      //         ],
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}
