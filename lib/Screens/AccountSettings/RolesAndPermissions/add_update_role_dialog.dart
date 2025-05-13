

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/roles_and_permissions_controller.dart';

import '../../../Backend/RolesAndPermissionsBackend/add_role.dart';
import '../../../Backend/RolesAndPermissionsBackend/edit_role.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/dialog_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';




class AddNewRoleDialog extends StatefulWidget {
  const AddNewRoleDialog({super.key, required this.id, required this.name});
final String id;
final String name;
  @override
  State<AddNewRoleDialog> createState() =>
      _AddNewRoleDialogState();
}

class _AddNewRoleDialogState extends State<AddNewRoleDialog> {
  TextEditingController nameController = TextEditingController();
  RolesAndPermissionsController rolesAndPermissionsController = Get.find();
  HomeController homeController=Get.find();
@override
  void initState() {
   if(rolesAndPermissionsController.isItUpdateRole){
     nameController.text=widget.name;
   }else{
     nameController.text='';
   }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Container(
      color: Colors.white,
      // width: Sizes.deviceWidth*0.2,
      height: 250,
      // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogTitle(text: rolesAndPermissionsController.isItUpdateRole
                  ?'edit_role'.tr
                  : 'add_new_role'.tr),
              InkWell(
                onTap: () {
                  Get.back();
                },
                child: CircleAvatar(
                  backgroundColor: Primary.primary,
                  radius: 15,
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              )
            ],
          ),
          gapH40,
          DialogTextField(
            textEditingController: nameController,
            textFieldWidth:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3 : MediaQuery.of(context).size.width * 0.15,
            rowWidth:homeController.isMobile.value?  MediaQuery.of(context).size.width * 0.55 : MediaQuery.of(context).size.width * 0.25,
            validationFunc: (val){},
            text:'${'role_name'.tr}*'),
          gapH32,
          ReusableButtonWithColor(
              btnText: rolesAndPermissionsController.isItUpdateRole
                  ?'update'.tr
                  :'apply'.tr,
              radius: 9,
              onTapFunction: () async {
                if(nameController.text.isNotEmpty) {
                  // ignore: prefer_typing_uninitialized_variables
                  var res ;
                  if(!rolesAndPermissionsController.isItUpdateRole){
                    res = await addRole(nameController.text);
                   }else{
                   res = await editRole(widget.id,nameController.text);
                  }
                  Get.back();
                  if ('${res['success']}' == 'true') {
                    rolesAndPermissionsController.getAllRolesAndPermissionsFromBack();
                    CommonWidgets.snackBar(
                        'Success', res['message']);
                  } else {
                    CommonWidgets.snackBar('error', res['message']);
                  }
                }else{
                CommonWidgets.snackBar('error', 'Role name is required');
                }
              },
              width: MediaQuery.of(context).size.width * 0.25,
              height: 50)
        ],
      ),
    );
  }
}










