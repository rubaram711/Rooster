import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multiselect/multiselect.dart';
import 'package:rooster_app/Backend/UsersBackend/delete_user.dart';
import 'package:rooster_app/Controllers/users_controller.dart';
import '../../../Backend/UsersBackend/update_user.dart';
import '../../../Controllers/home_controller.dart';
// import '../../Controllers/PosController/inventory_controller.dart';
import '../../../Locale_Memory/save_user_info_locally.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/loading.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../Widgets/table_item.dart';
import '../../../Widgets/table_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final HomeController homeController = Get.find();

  // double generalListViewLength = 100;
  // double transactionListViewLength = 100;
  // String selectedNumberOfRowsInGeneralTab = '10';
  // int selectedNumberOfRowsInGeneralTabAsInt = 10;
  // String selectedNumberOfRowsInTransactionsTab = '10';
  // int selectedNumberOfRowsInTransactionsTabAsInt = 10;
  int startInGeneral = 1;
  bool isArrowBackClickedInGeneral = false;
  bool isArrowForwardClickedInGeneral = false;
  int startInTransactions = 1;
  bool isArrowBackClickedInTransactions = false;
  bool isArrowForwardClickedInTransactions = false;

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
    await usersController.getAllUsersFromBack();
  }

  UsersController usersController = Get.find();
  @override
  void initState() {
    usersController.getAllUsersFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UsersController>(builder: (cont) {
      return Container(
        padding: EdgeInsets.symmetric(
            horizontal:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.05: MediaQuery.of(context).size.width * 0.02),
        height:homeController.isMobile.value ?MediaQuery.of(context).size.height*0.78: MediaQuery.of(context).size.height * 0.85,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageTitle(text: 'list_of_users'.tr),
                  ReusableButtonWithColor(
                    width: homeController.isMobile.value ? MediaQuery.of(context).size.width * 0.35:MediaQuery.of(context).size.width * 0.15,
                    height: 45,
                    onTapFunction: () {
                      homeController.selectedTab.value = 'create_users';
                    },
                    btnText: 'add_new_user'.tr,
                  ),
                ],
              ),
              gapH24,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    // width:homeController.isMobile.value ?MediaQuery.of(context).size.width * 0.9: MediaQuery.of(context).size.width * 0.7,
                    child: ReusableSearchTextField(
                      hint: '${"search".tr}...',
                      textEditingController: cont.searchController,
                      onChangedFunc: (val) {
                        _onChangeHandler(val);
                      },
                      validationFunc: (val) {},
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ),
              homeController.isMobile.value ?
              SizedBox(
                // height: MediaQuery.of(context).size.height * 0.4,
                child:cont.isUsersFetched?  SingleChildScrollView(
                  child: Row(
                    children: [
                      Flexible(
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child:Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 15),
                                  decoration: BoxDecoration(
                                      color: Primary.primary,
                                      borderRadius:
                                      const BorderRadius.all(
                                          Radius.circular(6))),
                                  child: Row(
                                    children: [
                                      TableTitle(
                                        text: 'name'.tr,
                                        width:150,
                                      ),
                                      TableTitle(
                                        text: 'email',
                                        width: 250,
                                      ),
                                      TableTitle(
                                        text: 'pos'.tr,
                                        width: 150,
                                      ),
                                      TableTitle(
                                        text: 'role'.tr,
                                        width: 150,
                                      ),
                                      TableTitle(
                                        text: 'active'.tr,
                                        width: 150,
                                      ),
                                      const SizedBox(
                                          width: 100)
                                    ],
                                  ),
                                ),
                                Container(
                                    color: Colors.white,
                                    child:Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children:  List.generate(
                                          cont.usersList.length,
                                            (index) => UserAsRowInTable(
                                              isDesktop: false,
                                              info: cont.usersList[index],
                                              index: index,
                                            ),
                                      ),
                                    )
                                ),
                              ],
                            )
                        ),
                      ),
                    ],
                  ),
                ):const Center(child:CircularProgressIndicator()),
              ):
              Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                    decoration: BoxDecoration(
                        color: Primary.primary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TableTitle(
                          text: 'name'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'email',
                          width: MediaQuery.of(context).size.width * 0.2,
                        ),
                        // TableTitle(
                        //   text: 'password'.tr,
                        //   width: MediaQuery.of(context).size.width * 0.09,
                        // ),
                        TableTitle(
                          text: 'pos'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'role'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: 'active'.tr,
                          width: MediaQuery.of(context).size.width * 0.1,
                        ),
                        TableTitle(
                          text: '',
                          width: MediaQuery.of(context).size.width * 0.03,
                        ),
                      ],
                    ),
                  ),
                  cont.isUsersFetched
                      ? Container(
                          color: Colors.white,
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView.builder(
                            itemCount: cont.usersList.length,
                            itemBuilder: (context, index) => Column(
                              children: [
                                UserAsRowInTable(
                                  info: cont.usersList[index],
                                  index: index,
                                ),
                                const Divider()
                              ],
                            ),
                          ),
                        )
                      : const CircularProgressIndicator(),
                  // cont.usersList.isNotEmpty?Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     Text(
                  //       '${'rows_per_page'.tr}:  ',
                  //       style: const TextStyle(
                  //           fontSize: 13, color: Colors.black54),
                  //     ),
                  //     Container(
                  //       width: 60,
                  //       height: 30,
                  //       decoration: BoxDecoration(
                  //           borderRadius: BorderRadius.circular(6),
                  //           border:
                  //           Border.all(color: Colors.black, width: 2)),
                  //       child: Center(
                  //         child: DropdownButtonHideUnderline(
                  //           child: DropdownButton<String>(
                  //             borderRadius: BorderRadius.circular(0),
                  //             items: ['10', '20', '50', 'all'.tr]
                  //                 .map((String value) {
                  //               return DropdownMenuItem<String>(
                  //                 value: value,
                  //                 child: Text(
                  //                   value,
                  //                   style: const TextStyle(
                  //                       fontSize: 12, color: Colors.grey),
                  //                 ),
                  //               );
                  //             }).toList(),
                  //             value: selectedNumberOfRowsInGeneralTab,
                  //             onChanged: (val) {
                  //               setState(() {
                  //                 selectedNumberOfRowsInGeneralTab = val!;
                  //                 if (val == '10') {
                  //                   generalListViewLength =
                  //                   cont.usersList.length < 10
                  //                       ? Sizes.deviceHeight *
                  //                       (0.09 *  cont.usersList.length)
                  //                       : Sizes.deviceHeight *
                  //                       (0.09 * 10);
                  //                   selectedNumberOfRowsInGeneralTabAsInt =
                  //                   cont.usersList.length < 10
                  //                       ?  cont.usersList.length
                  //                       : 10;
                  //                 }
                  //                 if (val == '20') {
                  //                   generalListViewLength =
                  //                   cont.usersList.length < 20
                  //                       ? Sizes.deviceHeight *
                  //                       (0.09 *  cont.usersList.length)
                  //                       : Sizes.deviceHeight *
                  //                       (0.09 * 20);
                  //                   selectedNumberOfRowsInGeneralTabAsInt =
                  //                   cont.usersList.length < 20
                  //                       ?  cont.usersList.length
                  //                       : 20;
                  //                 }
                  //                 if (val == '50') {
                  //                   generalListViewLength =
                  //                   cont.usersList.length < 50
                  //                       ? Sizes.deviceHeight *
                  //                       (0.09 *  cont.usersList.length)
                  //                       : Sizes.deviceHeight *
                  //                       (0.09 * 50);
                  //                   selectedNumberOfRowsInGeneralTabAsInt =
                  //                   cont.usersList.length < 50
                  //                       ?  cont.usersList.length
                  //                       : 50;
                  //                 }
                  //                 if (val == 'all'.tr) {
                  //                   generalListViewLength =
                  //                       Sizes.deviceHeight *
                  //                           (0.09 *  cont.usersList.length);
                  //                   selectedNumberOfRowsInGeneralTabAsInt =
                  //                       cont.usersList.length;
                  //                 }
                  //               });
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //     gapW16,
                  //     Text(
                  //         '$startInGeneral-$selectedNumberOfRowsInGeneralTab of ${ cont.usersList.length}',
                  //         style: const TextStyle(
                  //             fontSize: 13, color: Colors.black54)),
                  //     gapW16,
                  //     InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             isArrowBackClickedInGeneral =
                  //             !isArrowBackClickedInGeneral;
                  //             isArrowForwardClickedInGeneral = false;
                  //           });
                  //         },
                  //         child: Row(
                  //           children: [
                  //             Icon(
                  //               Icons.skip_previous,
                  //               color: isArrowBackClickedInGeneral
                  //                   ? Colors.black87
                  //                   : Colors.grey,
                  //             ),
                  //             Icon(
                  //               Icons.navigate_before,
                  //               color: isArrowBackClickedInGeneral
                  //                   ? Colors.black87
                  //                   : Colors.grey,
                  //             ),
                  //           ],
                  //         )),
                  //     gapW10,
                  //     InkWell(
                  //         onTap: () {
                  //           setState(() {
                  //             isArrowForwardClickedInGeneral =
                  //             !isArrowForwardClickedInGeneral;
                  //             isArrowBackClickedInGeneral = false;
                  //           });
                  //         },
                  //         child: Row(
                  //           children: [
                  //             Icon(
                  //               Icons.navigate_next,
                  //               color: isArrowForwardClickedInGeneral
                  //                   ? Colors.black87
                  //                   : Colors.grey,
                  //             ),
                  //             Icon(
                  //               Icons.skip_next,
                  //               color: isArrowForwardClickedInGeneral
                  //                   ? Colors.black87
                  //                   : Colors.grey,
                  //             ),
                  //           ],
                  //         )),
                  //     gapW40,
                  //   ],
                  // ):const SizedBox()
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}

class UserAsRowInTable extends StatefulWidget {
  const UserAsRowInTable(
      {super.key,
      required this.info,
      required this.index,
      this.isDesktop = true});
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<UserAsRowInTable> createState() => _UserAsRowInTableState();
}

class _UserAsRowInTableState extends State<UserAsRowInTable> {
  bool isActive = false;
  UsersController usersController=Get.find();
  HomeController homeController=Get.find();
  String roles='';
  getRolesAsString(){
    for(var r in widget.info['roles']){
      setState(() {
        roles=roles!=''?'$roles ,\n${r['name']}':r['name'];
      });
    }
  }
  @override
  void initState() {
    getRolesAsString();
    isActive =  widget.info['active'] ;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onDoubleTap: (){
        showDialog<String>(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                    backgroundColor:
                    Colors.white,
                    shape:
                    const RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.all(
                          Radius.circular(
                              9)),
                    ),
                    elevation: 0,
                    content: UpdateUserDialog(index:widget.index,)));
      },
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: widget.isDesktop ? 5 : 0, vertical: 10),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TableItem(
              text: '${widget.info['name'] ?? ''}',
              width: widget.isDesktop
                  ? MediaQuery.of(context).size.width * 0.1
                  : 150,
            ),
            TableItem(
              text: '${widget.info['email'] ?? ''}',
              width: widget.isDesktop
                  ? MediaQuery.of(context).size.width * 0.2
                  : 250,
            ),
            // TableItem(
            //   text: '${widget.info['password'] ?? ''}',
            //   width:widget.isDesktop? MediaQuery.of(context).size.width * 0.09:140,
            // ),
            TableItem(
              text: widget.info['posTerminal'] != null
                  ? '${widget.info['posTerminal']['name'] ?? ''}'
                  : '',
              width: widget.isDesktop
                  ? MediaQuery.of(context).size.width * 0.1
                  : 150,
            ),
            TableItem(
              text: roles,
              width: widget.isDesktop
                  ? MediaQuery.of(context).size.width * 0.1
                  : 150,
            ),
            SizedBox(
              width: widget.isDesktop
                  ? MediaQuery.of(context).size.width * 0.1
                  : 150,
              child: Checkbox(
                value: isActive,
                onChanged: (bool? value) async {
                  // setState(() {
                  //   isActive = value!;
                  // });
                  // String companyId=await getCompanyIdFromPref();
                  // var res = await updateUser(
                  //     '${usersController.usersList[widget.index]['id']}',
                  //     companyId,
                  //     '${widget.info['name'] ?? ''}',
                  //     '${widget.info['email'] ?? ''}',
                  //     'passwordController',//todo
                  //     'confirmPasswordController',//todo
                  //     isActive?'1':'0',
                  //     '${widget.info['role']['id']}',//todo
                  //     '${widget.info['posTerminal']['id']}'
                  // );
                  // if (res['success'] == true) {
                  //   Get.back();
                  //   usersController.getAllUsersFromBack();
                  //   usersController.setSelectedRoleId('');
                  //   usersController.setSelectedPosId('');
                  //   CommonWidgets.snackBar('Success',
                  //       res['message'] );
                  // } else {
                  //   CommonWidgets.snackBar(
                  //       'error', res['message'] );
                  // }
                },
              ),
            ),
            SizedBox(
              width: widget.isDesktop?MediaQuery.of(context).size.width *
                  0.03:100,
              child: InkWell(
                onTap: () async {
                  var res = await deleteUser(
                      '${usersController.usersList[widget.index]['id']}');
                  var p = json.decode(res.body);
                  if (res.statusCode == 200) {
                    CommonWidgets.snackBar(
                        'Success', p['message']);
                    usersController.getAllUsersFromBack();
                  } else {
                    CommonWidgets.snackBar(
                        'error', p['message']);
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
      ),
    );
  }
}


class UpdateUserDialog extends StatefulWidget {
  const UpdateUserDialog({super.key, required this.index});
  final int index;

  @override
  State<UpdateUserDialog> createState() =>
      _UpdateUserDialogState();
}

class _UpdateUserDialogState extends State<UpdateUserDialog> {
  bool isMobile=false;
  final UsersController usersController=Get.find();
  final HomeController homeController = Get.find();
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController selectedPosController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  String selectedPosId = '';
  // String selectedRoleId = '';
  bool isActiveInChecked = false;
  List<String> selectedRolesNamesList=[];
  @override
  void initState() {
    isMobile=homeController.isMobile.value;
    usersController.getFieldsForCreateUserFromBack();
    nameController.text='${usersController.usersList[widget.index]['name'] ?? ''}';
    emailController.text='${usersController.usersList[widget.index]['email'] ?? ''}';
    selectedPosController.text=usersController.usersList[widget.index]['posTerminal']!=null?'${usersController.usersList[widget.index]['posTerminal']['name'] ?? ''}':'';
    // // roleController.text='${usersController.usersList[widget.index]['role'][0]['name'] ?? ''}';
    for(var r in usersController.usersList[widget.index]['roles']){
      selectedRolesNamesList.add(r['name']);
    }
    selectedPosId=usersController.usersList[widget.index]['posTerminal']!=null?'${usersController.usersList[widget.index]['posTerminal']['id'] ?? ''}':'';
    isActiveInChecked=usersController.usersList[widget.index]['active'];
    // // usersController.selectedRoleId='${usersController.usersList[widget.index]['role'][0]['id']}';
    // usersController.selectedRoleId=usersController.usersList[widget.index]['posTerminal']!=null?'${usersController.usersList[widget.index]['posTerminal']['id'] ?? ''}':'';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<UsersController>(
        builder: (userCont) {
        return Container(
            color: Colors.white,
            // height: 700,
            child: Form(
              key: _formKey,
              child:SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PageTitle(text: 'update_user'.tr),
                    gapH32,
                    DialogTextField(
                      textEditingController: nameController,
                      text: '${'name'.tr}*',
                      rowWidth:isMobile? MediaQuery.of(context).size.width * 0.65 :MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth:isMobile? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.3,
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
                      rowWidth: isMobile? MediaQuery.of(context).size.width * 0.65 :MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth:isMobile? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.3,
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
                      rowWidth:isMobile? MediaQuery.of(context).size.width * 0.65 : MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth:isMobile? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.3,
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
                      rowWidth: isMobile? MediaQuery.of(context).size.width * 0.65 :MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth: isMobile? MediaQuery.of(context).size.width * 0.4 :MediaQuery.of(context).size.width * 0.3,
                      validationFunc: (value) {
                        if(value.isEmpty){
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH12,
                      SizedBox(
                      width:isMobile? MediaQuery.of(context).size.width * 0.65 : MediaQuery.of(context).size.width * 0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('pos'.tr),
                          userCont.isPossFetched? DropdownMenu<String>(
                            width:isMobile? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.3,
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
                              userCont.setSelectedPosId('${userCont.posIdsList[index]}');
                              setState(() {
                                selectedPosId ='${userCont.posIdsList[index]}';
                              });

                            },
                          ):loading(),
                        ],
                      ),
                    ),
                    gapH12,
                    SizedBox(
                      width:isMobile? MediaQuery.of(context).size.width * 0.65 : MediaQuery.of(context).size.width * 0.4,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'role'.tr} *'),
                            SizedBox(
                              width:isMobile? MediaQuery.of(context).size.width * 0.4 : MediaQuery.of(context).size.width * 0.3,
                              child: DropDownMultiSelect(
                                onChanged: (List<String> val) {
                                  setState(() {
                                    selectedRolesNamesList=val;
                                  });
                                },
                                options:  userCont.rolesNamesList,
                                selectedValues: selectedRolesNamesList,
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
                   // SizedBox(
                   //    width:isMobile? MediaQuery.of(context).size.width * 0.9 : MediaQuery.of(context).size.width * 0.4,
                   //    child: Row(
                   //      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   //      children: [
                   //        Text('${'role'.tr} *'),
                   //        userCont.isRolesFetched? DropdownMenu<String>(
                   //          width:isMobile? MediaQuery.of(context).size.width * 0.6 : MediaQuery.of(context).size.width * 0.3,
                   //          // requestFocusOnTap: false,
                   //          enableSearch: true,
                   //          controller: roleController,
                   //          hintText: '',
                   //          inputDecorationTheme: InputDecorationTheme(
                   //            // filled: true,
                   //            hintStyle: const TextStyle(
                   //                fontStyle: FontStyle.italic),
                   //            contentPadding:
                   //            const EdgeInsets.fromLTRB(20, 0, 25, 5),
                   //            // outlineBorder: BorderSide(color: Colors.black,),
                   //            enabledBorder: OutlineInputBorder(
                   //              borderSide: BorderSide(
                   //                  color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                   //                  width: 1),
                   //              borderRadius: const BorderRadius.all(
                   //                  Radius.circular(9)),
                   //            ),
                   //            focusedBorder: OutlineInputBorder(
                   //              borderSide: BorderSide(
                   //                  color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                   //                  width: 2),
                   //              borderRadius: const BorderRadius.all(
                   //                  Radius.circular(9)),
                   //            ),
                   //          ),
                   //          menuHeight: 250,
                   //          dropdownMenuEntries: userCont.rolesNamesList
                   //              .map<DropdownMenuEntry<String>>(
                   //                  (String option) {
                   //                return DropdownMenuEntry<String>(
                   //                  value: option,
                   //                  label: option,
                   //                );
                   //              }).toList(),
                   //          enableFilter: true,
                   //          onSelected: (String? val) {
                   //            int index=userCont.rolesNamesList.indexOf(val!);
                   //            userCont.setSelectedRoleId(userCont.rolesIdsList[index]);
                   //            setState(() {
                   //              selectedRoleId = userCont.rolesIdsList[index];
                   //            });
                   //          },
                   //        ):loading(),
                   //      ],
                   //    ),
                   //  ),
                    gapH12,
                    SizedBox(
                        width: 300,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width:isMobile? MediaQuery.of(context).size.width * 0.3:MediaQuery.of(context).size.width * 0.1,
                              child: Text('active'.tr,
                                  style: const TextStyle(
                                      fontSize: 12)),
                            ),
                            Checkbox(
                              // checkColor: Colors.white,
                              // fillColor: MaterialStateProperty.resolveWith(getColor),
                              value: isActiveInChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  isActiveInChecked =
                                  value!;
                                });
                              },
                            ),
                          ],
                        )),
                    // const Spacer(),
                    isMobile?gapH2:gapH64,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () {
                              setState(() {
                                nameController.text='${usersController.usersList[widget.index]['name'] ?? ''}';
                                emailController.text='${usersController.usersList[widget.index]['email'] ?? ''}';
                                selectedPosController.text=usersController.usersList[widget.index]['posTerminal']!=null?'${usersController.usersList[widget.index]['posTerminal']['name'] ?? ''}':'';
                                roleController.text='${usersController.usersList[widget.index]['role'][0]['name'] ?? ''}';
                                // selectedRoleId='${usersController.usersList[widget.index]['role'][0]['id'] ?? ''}';
                                selectedRolesNamesList=[];
                                selectedPosId=usersController.usersList[widget.index]['posTerminal']!=null?'${usersController.usersList[widget.index]['posTerminal']['id'] ?? ''}':'';
                                isActiveInChecked=usersController.usersList[widget.index]['active'];
                                usersController.selectedRoleId='${usersController.usersList[widget.index]['role'][0]['id']}';
                                usersController.selectedRoleId=usersController.usersList[widget.index]['posTerminal']!=null?'${usersController.usersList[widget.index]['posTerminal']['id'] ?? ''}':'';
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
                              // print('posIdsList ${userCont.posIdsList}');
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
                                String companyId=await getCompanyIdFromPref();
                                for(int i=0;i<selectedRolesNamesList.length;i++){
                                  int index=userCont.rolesNamesList.indexOf(selectedRolesNamesList[i]);
                                  userCont.addToSelectedRolesIds(userCont.rolesIdsList[index]);
                                }
                                var res = await updateUser(
                                    '${usersController.usersList[widget.index]['id']}',
                                    companyId,
                                    nameController.text,
                                    emailController.text,
                                    passwordController.text,
                                    confirmPasswordController.text,
                                    isActiveInChecked?'1':'0',
                                    userCont.selectedRolesIdsList,
                                    selectedPosId
                                );
                                if (res['success'] == true) {
                                  Get.back();
                                  usersController.getAllUsersFromBack();
                                  usersController.setSelectedRoleId('');
                                  usersController.setSelectedPosId('');
                                  CommonWidgets.snackBar('Success',
                                      res['message'] );
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
            )
        );
      }
    );
  }
}