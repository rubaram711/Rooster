import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiselect/multiselect.dart';
import 'package:rooster_app/Backend/UsersBackend/add_user.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Controllers/users_controller.dart';
import '../../../Controllers/home_controller.dart';

import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

class AddNewUser extends StatefulWidget {
  const AddNewUser({super.key, this.isItDialog=false, this.enteredName=''});
  final bool isItDialog;
  final String enteredName;
  @override
  State<AddNewUser> createState() => _AddNewUserState();
}

class _AddNewUserState extends State<AddNewUser> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController selectedPosController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  final HomeController homeController = Get.find();
  final TaskController taskController = Get.find();
  // Map data = {};
  //
  // getFieldsForCreateClientsFromBack() async {
  //   var p = await getFieldsForCreateClient();
  //   if ('$p' != '[]') {
  //     setState(() {
  //       data.addAll(p);
  //       isClientsInfoFetched = true;
  //     });
  //   }
  // }

  // List<String> roles = [''];
  String selectedPosId = '';
  String selectedRole = '';
  bool isActiveInChecked = false;
  final _formKey = GlobalKey<FormState>();

  bool isMobile=false;
  final UsersController usersController=Get.find();
  @override
  void initState() {
    isMobile=homeController.isMobile.value;
    // getFieldsForCreateClientsFromBack();
    if(widget.isItDialog){
      nameController.text=widget.enteredName;
    }
    usersController.getFieldsForCreateUserFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<UsersController>(
      builder: (userCont) {
        return Container(
              padding: EdgeInsets.symmetric(
              horizontal:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05: MediaQuery.of(context).size.width * 0.02),
              height:isMobile? MediaQuery.of(context).size.height * 0.8: MediaQuery.of(context).size.height * 0.85,
              child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PageTitle(text: widget.isItDialog?'create_assigned_to'.tr:'create_new_user'.tr),
                        widget.isItDialog
                            ?InkWell(
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
                        ):const SizedBox(),
                      ],
                    ),
                    // gapH32,
                    // const AddPhotoCircle(),
                    gapH32,
                    //
                    // Text(
                    //   '${data['clientNumber'] ?? ''}',
                    //   style: const TextStyle(
                    //       fontSize: 36, fontWeight: FontWeight.bold),
                    // ),

                    DialogTextField(
                      textEditingController: nameController,
                      text: '${'name'.tr}*',
                      rowWidth:isMobile? MediaQuery.of(context).size.width * 0.9 :MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                      validationFunc: (value) {
                        if(value.isEmpty){
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH12,
                    DialogTextField(
                      textEditingController: emailController,
                      text: '${'email'.tr}*',
                      rowWidth: isMobile? MediaQuery.of(context).size.width * 0.9 :MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                      validationFunc: (value) {
                        if(value.isEmpty){
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH12,
                    DialogTextField(
                      textEditingController: passwordController,
                      text: '${'password'.tr}*',
                        isPassword:true,
                      rowWidth:isMobile? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                      validationFunc: (value) {
                        if(value.isEmpty){
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH12,
                    DialogTextField(
                      textEditingController: confirmPasswordController,
                      text: '${'confirm_password'.tr}*',
                      isPassword:true,
                      rowWidth: isMobile? MediaQuery.of(context).size.width * 0.9 :MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth: isMobile? MediaQuery.of(context).size.width * 0.6 :MediaQuery.of(context).size.width * 0.3,
                      validationFunc: (value) {
                        if(value.isEmpty){
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH12,
                    SizedBox(
                      width:isMobile? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('pos'.tr),
                          userCont.isPossFetched? DropdownMenu<String>(
                            width:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                            // requestFocusOnTap: false,
                            enableSearch: true,
                            controller: selectedPosController,
                            hintText: '',
                            inputDecorationTheme: InputDecorationTheme(
                              // filled: true,
                              hintStyle: const TextStyle(
                                  fontStyle: FontStyle.italic),
                              contentPadding:
                              const EdgeInsets.fromLTRB(20, 0, 25, 5),
                              // outlineBorder: BorderSide(color: Colors.black,),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                                    width: 1),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                                    width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(9)),
                              ),
                            ),
                            menuHeight: 250,
                            dropdownMenuEntries: userCont.posNamesList
                                .map<DropdownMenuEntry<String>>(
                                    (String option) {
                                  return DropdownMenuEntry<String>(
                                    value: option,
                                    label: option,
                                  );
                                }).toList(),
                            enableFilter: true,
                            onSelected: (String? val) {
                              var index =
                              userCont.posNamesList.indexOf(val!);
                              setState(() {
                                selectedPosId ='${userCont.posIdsList[index]}';
                              });
                            },
                          ):loading(),
                        ],
                      ),
                    ),
                    // gapH12,
                    // SizedBox(
                    //   width:isMobile? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.4,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text('${'role'.tr} *'),
                    //       DropdownMenu<String>(
                    //         width:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                    //         // requestFocusOnTap: false,
                    //         enableSearch: true,
                    //         controller: roleController,
                    //         hintText: '',
                    //         inputDecorationTheme: InputDecorationTheme(
                    //           // filled: true,
                    //           hintStyle: const TextStyle(
                    //               fontStyle: FontStyle.italic),
                    //           contentPadding:
                    //           const EdgeInsets.fromLTRB(20, 0, 25, 5),
                    //           // outlineBorder: BorderSide(color: Colors.black,),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //                 color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    //                 width: 1),
                    //             borderRadius: const BorderRadius.all(
                    //                 Radius.circular(9)),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //                 color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                    //                 width: 2),
                    //             borderRadius: const BorderRadius.all(
                    //                 Radius.circular(9)),
                    //           ),
                    //         ),
                    //         menuHeight: 250,
                    //         dropdownMenuEntries: userCont.rolesNamesList
                    //             .map<DropdownMenuEntry<String>>(
                    //                 (String option) {
                    //               return DropdownMenuEntry<String>(
                    //                 value: option,
                    //                 label: option,
                    //               );
                    //             }).toList(),
                    //         enableFilter: true,
                    //         onSelected: (String? val) {
                    //           setState(() {
                    //             selectedRole = val!;
                    //           });
                    //           int index=userCont.rolesNamesList.indexOf(val!);
                    //           userCont.setSelectedRoleId(userCont.rolesIdsList[index]);
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    gapH12,
                    SizedBox(
                      width:isMobile? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.4,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'role'.tr} *'),
                        SizedBox(
                          width:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                          child: DropDownMultiSelect(
                            onChanged: (List<String> val) {
                                userCont.setSelectedRolesNames(val);
                            },
                            options:  userCont.rolesNamesList,
                            selectedValues: userCont.selectedRolesNamesList,
                            decoration:   InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                              // outlineBorder: BorderSide(color: Colors.black,),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                                borderRadius: const BorderRadius.all(Radius.circular(9)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                                borderRadius: const BorderRadius.all(Radius.circular(9)),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                    gapH12,
                    SizedBox(
                      width: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.1,
                              child: Text('active'.tr,
                              style: const TextStyle(
                                  fontSize: 12)),
                            ),
                            Checkbox(
                              // checkColor: Colors.white,
                              // fillColor: MaterialStateProperty.resolveWith(getColor),
                              value:widget.isItDialog?true: isActiveInChecked,
                              onChanged:widget.isItDialog?null: (bool? value) {
                                setState(() {
                                  isActiveInChecked =
                                  value!;
                                });
                              },
                            ),
                          ],
                        )),
                 // const Spacer(),
                    isMobile?gapH40:gapH64,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                selectedRole = '';
                                isActiveInChecked = false;
                                nameController.clear();
                                emailController.clear();
                                passwordController.clear();
                                confirmPasswordController.clear();
                                selectedPosController.clear();
                                roleController.clear();
                              });
                            },
                            child: Text(
                              'discard'.tr,
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Primary.primary),
                            )),
                        gapW24,
                        ReusableButtonWithColor(
                            btnText: 'save'.tr,
                            onTapFunction: () async {
                              // if (userCont.selectedPosId == '') {
                              //   CommonWidgets.snackBar(
                              //       'error', 'you must choose Pos first');
                              // } else if (userCont.posIdsList
                              //     .contains(userCont.selectedPosId) ==
                              //     false) {
                              //   CommonWidgets.snackBar('error',
                              //       'you must choose an existing Pos');
                              // }   if (userCont.selectedRoleId == '') {
                              //   CommonWidgets.snackBar(
                              //       'error', 'you must choose Role first');
                              // } else if (userCont.rolesIdsList
                              //     .contains(userCont.selectedRoleId) ==
                              //     false) {
                              //   CommonWidgets.snackBar('error',
                              //       'you must choose an existing Role');
                              // }else
                                if (_formKey.currentState!.validate()) {
                                  for(int i=0;i<userCont.selectedRolesNamesList.length;i++){
                                    int index=userCont.rolesNamesList.indexOf(userCont.selectedRolesNamesList[i]);
                                    userCont.addToSelectedRolesIds(userCont.rolesIdsList[index]);
                                  }
                                  // print('object ${userCont.selectedRolesIdsList}');
                                String companyId=await getCompanyIdFromPref();
                                var res = await addUser(
                                    companyId,
                                    nameController.text,
                                    emailController.text,
                                    passwordController.text,
                                    confirmPasswordController.text,
                                    isActiveInChecked?'1':'0',
                                    // userCont.selectedRoleId,
                                    selectedPosId,
                                    userCont.selectedRolesIdsList
                                );
                                if (res['success'] == true) {
                                  if(widget.isItDialog){
                                    Get.back();
                                    // change selected user in add task
                                    CommonWidgets.snackBar('Success',
                                        res['message'] );
                                    taskController.assignedToController.text=nameController.text;
                                    taskController.setSelectedUserId('${res['data']['id']}');
                                    usersController.getAllUsersFromBack();
                                  }else{
                                    CommonWidgets.snackBar('Success',
                                        res['message'] );
                                    homeController.selectedTab.value =
                                    'users';}
                                } else {
                                  CommonWidgets.snackBar(
                                      'error', res['message'] );
                                }
                              }
                            },
                            width: 100,
                            height: 35),
                      ],
                    ),
                    gapH40,
                  ],
                ),
              ),
            ),
            );
      }
    );
  }


}






