import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import '../../../Widgets/dialog_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

class AddGarageAttributeDialog extends StatefulWidget {
  const AddGarageAttributeDialog({super.key, required this.text});
  final String text;
  @override
  State<AddGarageAttributeDialog> createState() => _AddGarageAttributeDialogState();
}

class _AddGarageAttributeDialogState extends State<AddGarageAttributeDialog> {
  TextEditingController textController = TextEditingController();
  HomeController homeController = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              DialogTitle(
                text:
                    widget.text == 'color'
                        ? 'add_new_color'.tr
                        : widget.text == 'model'
                        ? 'add_new_model'.tr
                        : widget.text == 'technician'
                        ? 'add_new_technician'.tr
                        : 'add_new_brand'.tr,
              ),
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
              ),
            ],
          ),
          gapH40,
          DialogTextField(
            textEditingController: textController,
            textFieldWidth:
                homeController.isMobile.value
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.15,
            rowWidth:
                homeController.isMobile.value
                    ? MediaQuery.of(context).size.width * 0.55
                    : MediaQuery.of(context).size.width * 0.25,
            validationFunc: (val) {},
            text: '${widget.text.tr}*',
          ),
          gapH32,
          ReusableButtonWithColor(
            btnText: 'save'.tr,
            radius: 9,
            onTapFunction: () async {
              // if (textController.text.isNotEmpty) {
              //   // ignore: prefer_typing_uninitialized_variables
              //   var res;
              //   if (!rolesAndPermissionsController.isItUpdateRole) {
              //     res = await addRole(textController.text);
              //   } else {
              //     res = await editRole(widget.id, textController.text);
              //   }
              //   Get.back();
              //   if ('${res['success']}' == 'true') {
              //     rolesAndPermissionsController
              //         .getAllRolesAndPermissionsFromBack();
              //     CommonWidgets.snackBar('Success', res['message']);
              //   } else {
              //     CommonWidgets.snackBar('error', res['message']);
              //   }
              // } else {
              //   CommonWidgets.snackBar('error', 'Role name is required');
              // }
            },
            width: MediaQuery.of(context).size.width * 0.25,
            height: 50,
          ),
        ],
      ),
    );
  }
}
