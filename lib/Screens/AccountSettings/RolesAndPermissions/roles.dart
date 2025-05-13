import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/const/colors.dart';
import '../../../Backend/RolesAndPermissionsBackend/delete_role.dart';
import '../../../Controllers/roles_and_permissions_controller.dart';
import '../../../Models/RolesAndPermissions/roles_and_permissions_model.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../Widgets/table_item.dart';
import '../../../Widgets/table_title.dart';
import '../../../const/Sizes.dart';
import 'add_update_role_dialog.dart';

TextEditingController searchCategoryController = TextEditingController();

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  RolesAndPermissionsController rolesController = Get.find();
  HomeController homeController = Get.find();
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
        800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
            () => searchOnStoppedTyping = Timer(duration, () => search(value)));
  }

  search(value) async {
    rolesController.getAllRolesFromBack();
  }
  @override
  void initState() {
    rolesController.getAllRolesFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05:MediaQuery.of(context).size.width * 0.02),
      child: GetBuilder<RolesAndPermissionsController>(
          builder: (cont) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(text: 'roles'.tr),
                      ReusableButtonWithColor(
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                        height: 45,
                        onTapFunction: () {
                          cont.setIsItUpdateRoles(false);
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => const AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(9)),
                                ),
                                elevation: 0,
                                content: AddNewRoleDialog(
                                  id: '',
                                  name: '',
                                ),
                              ));
                        },
                        btnText: 'add_new_role'.tr,
                      ),
                    ],
                  ),
                  gapH16,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.9: MediaQuery.of(context).size.width * 0.7,
                        child: ReusableSearchTextField(
                          hint: '${"search".tr}...',
                          textEditingController: cont.searchOnRoleController,
                          onChangedFunc: (val) {
                            _onChangeHandler(val);
                          },
                          validationFunc: (val) {},
                        ),
                      ),
                    ],
                  ),
                  gapH32,
                  cont.isRolesFetched
                      ?
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: homeController.isMobile.value ?MediaQuery.of(context).size.width :MediaQuery.of(context).size.width * 0.32,
                        padding: EdgeInsets.symmetric(
                            horizontal:
                            MediaQuery.of(context).size.width * 0.01,
                            vertical: 15),
                        decoration: BoxDecoration(
                            color: Primary.primary,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(6))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            TableTitle(
                              text: 'name'.tr,
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5: MediaQuery.of(context).size.width * 0.2,
                            ),
                            // TableTitle(
                            //   text: 'sub_categories'.tr,
                            //   width: MediaQuery.of(context).size.width * 0.15,
                            // ),
                            SizedBox(
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                            ),
                            SizedBox(
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                            )
                          ],
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        height:homeController.isMobile.value ? MediaQuery.of(context).size.height * 0.57:MediaQuery.of(context).size.height * 0.5,
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width : MediaQuery.of(context).size.width * 0.32,
                        child: ListView.builder(
                          itemCount: cont.rolesList.length,
                          itemBuilder: (context, index) =>
                              _roleAsRowInTable(
                                  cont.rolesList[index] ,
                                  index,
                              ),
                        ),
                      ),
                    ],
                  )
                      : const Center(child: CircularProgressIndicator()),
                ],
              ),
            );
          }
      ),
    );
  }

  _roleAsRowInTable(Roles role, int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: role.name ?? '',
            width: homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.5:MediaQuery.of(context).size.width * 0.2,
          ),
          Row(
            children: [
              SizedBox(
                width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    rolesController.setIsItUpdateRoles(true);
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(9)),
                          ),
                          elevation: 0,
                          content: AddNewRoleDialog(
                              id:
                              '${role.id ?? 0}',
                              name: role.name ??
                                  ''),
                        ));
                  },
                  child: Icon(
                    Icons.mode_edit_outlined,
                    color: Primary.primary,
                  ),
                ),
              ),
              SizedBox(
                width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.1: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    var res = await deleteRole(
                        '${role.id}');
                    if ('${res['success']}' == 'true') {
                      rolesController.getAllRolesFromBack();
                      CommonWidgets.snackBar('Success',
                          res['message']);
                    } else {
                      CommonWidgets.snackBar(
                          'error',   res['message']);
                    }
                  },
                  child: Icon(
                    Icons.delete_outline,
                    color: Primary.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

