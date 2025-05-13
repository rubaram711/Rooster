import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/RolesAndPermissionsBackend/update_roles_permissions.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/roles_and_permissions_controller.dart';
import 'package:rooster_app/Models/RolesAndPermissions/roles_and_permissions_model.dart';

import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/loading_dialog.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import 'add_update_role_dialog.dart';

class RolesAndPermissions extends StatefulWidget {
  const RolesAndPermissions({super.key});

  @override
  State<RolesAndPermissions> createState() => _RolesAndPermissionsState();
}

class _RolesAndPermissionsState extends State<RolesAndPermissions> {
  RolesAndPermissionsController rolesAndPermissionsController = Get.find();
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
    setState(() {
      searchValue = value;
    });
    await rolesAndPermissionsController.getAllRolesAndPermissionsFromBack();
  }

  List<Widget> _buildPermissionsCards() {
    return List.generate(
      rolesAndPermissionsController.permissionsList.length,
      (index) => Container(
        alignment: Alignment.center,
        width:homeController.isMobile.value ?150: 300.0,
        height: 60.0,
        color: Colors.white,
        margin: const EdgeInsets.all(2.0),
        child: Text(
          rolesAndPermissionsController.permissionsList[index].name ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  List<Widget> _buildRolesCards() {
    return List.generate(
      rolesAndPermissionsController.rolesAndPermissionsList.length,
      (index) => InkWell(
        onTap: () {
          rolesAndPermissionsController.setIsItUpdateRoles(true);
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
                            '${rolesAndPermissionsController.rolesAndPermissionsList[index].id ?? 0}',
                        name: rolesAndPermissionsController
                                .rolesAndPermissionsList[index].name ??
                            ''),
                  ));
        },
        child: Container(
          alignment: Alignment.center,
          width: 150.0,
          height: 60.0,
          color: Colors.white,
          margin: const EdgeInsets.all(2.0),
          child: Text(
            rolesAndPermissionsController.rolesAndPermissionsList[index].name ?? '',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows() {
    return List.generate(
      rolesAndPermissionsController.permissionsList.length,
      (index1) => Row(
          children: List.generate(
              rolesAndPermissionsController.rolesAndPermissionsList.length, (index2) {
        bool isActive = false;
        // print(rolesAndPermissionsController.rolesAndPermissionsList[index2].permissions![0].name);
        // print(rolesAndPermissionsController.permissionsList[index1].name);
        var existingItem = rolesAndPermissionsController
            .rolesAndPermissionsList[index2].permissions!
            .firstWhere(
                (itemToCheck) =>
                    itemToCheck.name ==
                    rolesAndPermissionsController.permissionsList[index1].name,
                orElse: () => Permissions(id: -1));
        if (existingItem.id != -1) {
          rolesAndPermissionsController.addToGrantsList({
            'permissionId':
                rolesAndPermissionsController.permissionsList[index1].id ?? 0,
            'roleId': rolesAndPermissionsController.rolesAndPermissionsList[index2].id ?? 0
          });
          // setState(() {
          isActive = true;
          // });
        } else {
          rolesAndPermissionsController.removeFromGrant(
              rolesAndPermissionsController.rolesAndPermissionsList[index2].id ?? 0,
              rolesAndPermissionsController.permissionsList[index1].id ?? 0);
        }
        return ReusableCheckBox(
          value: isActive,
          roleId: rolesAndPermissionsController.rolesAndPermissionsList[index2].id ?? 0,
          permissionId:
              rolesAndPermissionsController.permissionsList[index1].id ?? 0,
        );
      })
          //_buildCells(rolesAndPermissionsController.rolesList.length),
          ),
    );
  }

  @override
  void initState() {
    rolesAndPermissionsController.getAllRolesAndPermissionsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RolesAndPermissionsController>(builder: (cont) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05: MediaQuery.of(context).size.width * 0.02),
        height:homeController.isMobile.value ?MediaQuery.of(context).size.height * 0.75: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(text: 'roles_and_permissions'.tr),
                ReusableButtonWithColor(
                  width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                  height: 45,
                  onTapFunction: () {
                    rolesAndPermissionsController.setIsItUpdateRoles(false);
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
            gapH10,
            ReusableSearchTextField(
              hint: '${"search".tr}...',
              textEditingController:
                  rolesAndPermissionsController.searchController,
              onChangedFunc: (val) {
                _onChangeHandler(val);
              },
              validationFunc: (val) {},
            ),
            gapH24,
            cont.isRolesAndPermissionsFetched
                ? SizedBox(
                    height:homeController.isMobile.value ?MediaQuery.of(context).size.height * 0.5: MediaQuery.of(context).size.height * 0.55,
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width:homeController.isMobile.value ?100: 250.0,
                                height: 60.0,
                                // color: Colors.white,
                                margin: const EdgeInsets.all(2.0),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _buildPermissionsCards(),
                              ),
                            ],
                          ),
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: _buildRolesCards(),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildRows(),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : loading(),
            const Spacer(),
            cont.isRolesAndPermissionsFetched
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReusableButtonWithColor(
                        width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                        height: 45,
                        onTapFunction: () async {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) =>
                              const AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(
                                        Radius.circular(9)),
                                  ),
                                  elevation: 0,
                                  content: LoadingDialog()));
                          var res = await updateRolesAndPermissions(
                              rolesAndPermissionsController.grants);
                          Get.back();
                          if (res['success'] == true) {
                            CommonWidgets.snackBar('Success', res['message']);
                            rolesAndPermissionsController.reset();
                            rolesAndPermissionsController
                                .getAllRolesAndPermissionsFromBack();
                          } else {
                            CommonWidgets.snackBar(
                                'error', res['message'] ?? 'error'.tr);
                          }
                        },
                        btnText: 'apply'.tr,
                      ),
                    ],
                  )
                : const SizedBox(),
            gapH10
          ],
        ),
      );
    });
  }
}

// ignore: must_be_immutable
class ReusableCheckBox extends StatefulWidget {
  ReusableCheckBox(
      {super.key,
      required this.value,
      required this.roleId,
      required this.permissionId});
  bool value;
  int roleId;
  int permissionId;
  @override
  State<ReusableCheckBox> createState() => _ReusableCheckBoxState();
}

class _ReusableCheckBoxState extends State<ReusableCheckBox> {
  RolesAndPermissionsController rolesAndPermissionsController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: 150.0,
      height: 60.0,
      color: Colors.white,
      margin: const EdgeInsets.all(2.0),
      child: Checkbox(
        value: widget.value,
        onChanged: (bool? value) {
          // print('permissionId'+'${widget.permissionId}'+'roleId'+ '${widget.roleId}');permissionId94roleId61
          setState(() {
            widget.value = value!;
          });
          if (value == true) {
            rolesAndPermissionsController.grants.add(
                {'permissionId': widget.permissionId, 'roleId': widget.roleId});
          } else {
            final int index = rolesAndPermissionsController.grants.indexWhere(
                (e) =>
                    e['roleId'] == widget.roleId &&
                    e['permissionId'] == widget.permissionId);
            if (index != -1) {
              rolesAndPermissionsController.grants.removeAt(index);
            }
          }
        },
      ),
    );
  }
}
