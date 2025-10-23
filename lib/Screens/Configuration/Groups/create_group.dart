import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/Widgets/reusable_text_field.dart';
import '../../../Controllers/groups_controller.dart';
import '../../../Models/Groups/groups_model.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';

class GroupFormView extends StatelessWidget {
 final GroupsController controller = Get.find();

  GroupFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.65,
      child: SingleChildScrollView(
        child:    Obx(
    () =>Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
          Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...controller.groups
                      .map(
                        (g) => GroupFormNode(group: g),
                      )
                      ,
                  const SizedBox(height: 20),
                  controller.groups.isEmpty
                      ? ReusableAddCard(text: 'Add Group', onTap: () {
                              controller.addGroup();
                            },)
                      : SizedBox.shrink(),
                ],
              ),
            // Spacer(),
            controller.groups.isEmpty? SizedBox.shrink(): ReusableButtonWithColor(
              btnText: 'save'.tr,
              onTapFunction: () async {
                var res =await controller.sendToBackend();
                if (res['success'] == true) {
                  // Get.back();
                  // categoriesController.getCategoriesFromBack();
                  controller.getGroupsFromBack();
                  controller.setSelectedTabIndex(0);
                  CommonWidgets.snackBar('Success', res['message']);
                  // groupCodeController.clear();
                  // groupNameController.clear();
                } else {
                  CommonWidgets.snackBar('error', res['message']);
                }
              },
              width: 100,
              height: 35,
            ),
            // ElevatedButton(
            //   onPressed: controller.sendToBackend,
            //   child: const Text('Save / Update'),
            // ),
          ],
        ),
      ),
    ));
  }
}

class GroupFormNode extends StatelessWidget {
  final Group group;
  // final GroupsController controller;
  final double indent;

  const GroupFormNode({
    super.key,
    required this.group,
    // required this.controller,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: group.name ?? '');
    final codeController = TextEditingController(text: group.code ?? '');
    GroupsController controller = Get.find();

    return Container(
      margin: EdgeInsets.only(left: indent, top: 8, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.teal.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child:
    Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title Row
          Row(
            children: [
              // Text(
              //   (group.name?.isEmpty ?? true)
              //       ? ""
              //       : "${group.name} (${group.code ?? ''})",
              //   style: const TextStyle(
              //     fontWeight: FontWeight.bold,
              //     fontSize: 16,
              //   ),
              // ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.green),
                onPressed: () => controller.addGroup(parent: group),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.deleteGroup(group),
              ),
            ],
          ),

          // --- Inputs
          ReusableTextField(
              onChangedFunc: (val) => controller.updateField(group, name: val),
              validationFunc: (value){},
              hint: 'Name',
              isPasswordField: false,
              textEditingController: nameController),
          gapH2,
          ReusableTextField(
              onChangedFunc: (val) => controller.updateField(group, code: val),
              validationFunc: (value){},
              hint: 'Code',
              isPasswordField: false,
              textEditingController: codeController),
          // TextFormField(
          //   controller: nameController,
          //   textDirection: TextDirection.ltr,
          //   textAlign: TextAlign.left,
          //   decoration: const InputDecoration(labelText: 'Name'),
          //   onChanged: (val) => controller.updateField(group, name: val),
          // ),
          // TextFormField(
          //   controller: codeController,
          //   textDirection: TextDirection.ltr,
          //   textAlign: TextAlign.left,
          //   decoration: const InputDecoration(labelText: 'Code'),
          //   onChanged: (val) => controller.updateField(group, code: val),
          // ),

          // --- Nested children
          ...group.children!
              .map(
                (child) => GroupFormNode(
                  group: child,
                  // controller: controller,
                  indent: indent + 24,
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
