import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/GroupsBackend/store_group.dart';
import 'package:rooster_app/Backend/GroupsBackend/update_group.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../../const/Sizes.dart';
import '../../../../const/colors.dart';
import '../../../Backend/GroupsBackend/delete_group.dart';
import '../../../Controllers/groups_controller.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Models/Groups/groups_model.dart';
import '../../../Widgets/custom_snak_bar.dart';
import '../../../Widgets/dialog_title.dart';
import '../../../Widgets/reusable_text_field.dart';
import 'create_group.dart';

List tabsList = ['groups', 'create_group'];

List tabsContent = [const GroupsView(),  GroupFormView()];

class GroupsDialogContent extends StatefulWidget {
  const GroupsDialogContent({super.key});

  @override
  State<GroupsDialogContent> createState() => _GroupsDialogContentState();
}

class _GroupsDialogContentState extends State<GroupsDialogContent> {
  HomeController homeController = Get.find();
  GroupsController groupsController = Get.find();
  @override
  void initState() {
    groupsController.setSelectedTabIndex(0);
    groupsController.getGroupsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: EdgeInsets.symmetric(
            horizontal: homeController.isMobile.value ? 10 : 50,
            vertical: 30,
          ),
          // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(text: 'groups'.tr),
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
              gapH24,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 0.0,
                    direction: Axis.horizontal,
                    children:
                        tabsList
                            .map(
                              (element) => _buildTabChipItem(
                                element,
                                tabsList.indexOf(element),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
              tabsContent[cont.selectedTabIndex],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<GroupsController>(
      builder: (cont) {
        return GestureDetector(
          onTap: () {
            setState(() {
              cont.groups.value=[];
              cont.setSelectedTabIndex(index);
            });
          },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
            ),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.09,
              // height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              decoration: BoxDecoration(
                color:
                    cont.selectedTabIndex == index ? Primary.p20 : Colors.white,
                border:
                    cont.selectedTabIndex == index
                        ? Border(
                          top: BorderSide(color: Primary.primary, width: 3),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                    spreadRadius: 9,
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Primary.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

TextEditingController groupNameController = TextEditingController();
TextEditingController groupCodeController = TextEditingController();
TextEditingController selectedRootController = TextEditingController();

class CreateGroupTab extends StatefulWidget {
  const CreateGroupTab({super.key});

  @override
  State<CreateGroupTab> createState() => _CreateGroupTabState();
}

class _CreateGroupTabState extends State<CreateGroupTab> {
  int selectedTabIndex = 0;
  final HomeController homeController = Get.find();
  final GroupsController groupsController = Get.find();

  bool isYesClicked = false;

  String selectedGroupId = '';
  String? selectedItem = '';

  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    groupNameController.clear();
    groupCodeController.clear();
    selectedRootController.clear();
    // groupsController.getGroupsFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gapH32,
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    DialogTextField(
                      textEditingController: groupNameController,
                      text: '${'group_name'.tr}*',
                      rowWidth:
                          homeController.isMobile.value
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                      validationFunc: (String value) {
                        if (value.isEmpty) {
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH16,
                    DialogTextField(
                      textEditingController: groupCodeController,
                      text: '${'code'.tr}*',
                      rowWidth:
                          homeController.isMobile.value
                              ? MediaQuery.of(context).size.width * 0.6
                              : MediaQuery.of(context).size.width * 0.4,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                      validationFunc: (String value) {
                        if (value.isEmpty) {
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              gapH40,
              Wrap(
                children: [
                  Text('is_it_sub_group'.tr),
                  gapW20,
                  InkWell(
                    onTap: () {
                      setState(() {
                        isYesClicked = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 8,
                      ),
                      color: isYesClicked ? Colors.green : Colors.grey,
                      child: Text('yes'.tr),
                    ),
                  ),
                  gapW12,
                  InkWell(
                    onTap: () {
                      setState(() {
                        isYesClicked = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 8,
                      ),
                      color: !isYesClicked ? Colors.green : Colors.grey,
                      child: Text('no'.tr),
                    ),
                  ),
                ],
              ),
              gapH32,
              isYesClicked
                  ? cont.isGroupsFetched
                      ? SizedBox(
                        width:
                            homeController.isMobile.value
                                ? MediaQuery.of(context).size.width * 0.6
                                : MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'main_group'.tr}*'),
                            DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.25,
                              enableSearch: true,
                              controller: selectedRootController,
                              inputDecorationTheme: InputDecorationTheme(
                                hintStyle: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                                contentPadding: const EdgeInsets.fromLTRB(
                                  20,
                                  0,
                                  25,
                                  5,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Primary.primary.withAlpha(
                                      (0.2 * 255).toInt(),
                                    ),
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(9),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Primary.primary.withAlpha(
                                      (0.4 * 255).toInt(),
                                    ),
                                    width: 2,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(9),
                                  ),
                                ),
                              ),
                              // menuStyle: ,
                              menuHeight: 250,
                              dropdownMenuEntries:
                                  cont.groupsNamesList
                                      .map<DropdownMenuEntry<String>>((
                                        String option,
                                      ) {
                                        return DropdownMenuEntry<String>(
                                          value: option,
                                          label: option,
                                        );
                                      })
                                      .toList(),
                              enableFilter: true,
                              onSelected: (String? val) {
                                setState(() {
                                  selectedItem = val!;
                                  var index = cont.groupsNamesList.indexOf(val);
                                  selectedGroupId =
                                      '${cont.groupsIdsList[index]}';
                                });
                              },
                            ),
                          ],
                        ),
                      )
                      : const CircularProgressIndicator()
                  : const SizedBox(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        groupNameController.clear();
                        groupCodeController.clear();
                        selectedRootController.clear();
                      });
                    },
                    child: Text(
                      'discard'.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Primary.primary,
                      ),
                    ),
                  ),
                  gapW24,
                  ReusableButtonWithColor(
                    btnText: 'save'.tr,
                    onTapFunction: () async {
                      if (_formKey.currentState!.validate()) {
                        var res = await oldStoreGroup(
                          groupNameController.text,
                          groupCodeController.text,
                          selectedGroupId,
                        );
                        if (res['success'] == true) {
                          // Get.back();
                          // categoriesController.getCategoriesFromBack();
                          cont.getGroupsFromBack();
                          cont.setSelectedTabIndex(0);
                          CommonWidgets.snackBar('Success', res['message']);
                          groupCodeController.clear();
                          groupNameController.clear();
                        } else {
                          CommonWidgets.snackBar('error', res['message']);
                        }
                      }
                    },
                    width: 100,
                    height: 35,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class GroupsView extends StatefulWidget {
  const GroupsView({super.key});

  @override
  State<GroupsView> createState() => _GroupsViewState();
}

class _GroupsViewState extends State<GroupsView> {
  GroupsController groupsController = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      builder: (cont) {
        return cont.isGroupsFetched
            ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: TreeView<Group>(
                treeController: cont.treeController,
                nodeBuilder: (BuildContext context, TreeEntry<Group> entry) {
                  return MyTreeTile(
                    key: ValueKey(entry.node),
                    entry: entry,
                    onTap:
                        () => cont.treeController.toggleExpansion(entry.node),
                  );
                },
              ),
            )
            : const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyTreeTile extends StatelessWidget {
  const MyTreeTile({super.key, required this.entry, required this.onTap});

  final TreeEntry<Group> entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return InkWell(
      // onTap: onTap,
      child: TreeIndentation(
        entry: entry,
        guide: const IndentGuide.connectingLines(indent: 48),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
          child: InkWell(
            onTap: () {
              showDialog<String>(
                context: context,
                builder:
                    (BuildContext context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                      ),
                      elevation: 0,
                      content: ClickedGroupDialog(group: entry.node),
                    ),
              );
            },
            child: Row(
              children: [
                Icon(
                  entry.hasChildren ? Icons.circle : Icons.circle_outlined,
                  size: 18,
                  color: Primary.primary,
                ),
                gapW6,
                homeController.isMobile.value
                    ? Expanded(
                      child: Wrap(
                        children: [
                          Text('${entry.node.code ?? ''}     '),
                          Text('(${entry.node.name ?? ''})'),
                        ],
                      ),
                    )
                    : Text(
                      '${entry.node.code ?? ''}      (${entry.node.name ?? ''})',
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ClickedGroupDialog extends StatefulWidget {
  const ClickedGroupDialog({
    super.key,
    this.isMobile = false,
    required this.group,
  });
  final bool isMobile;
  final Group group;
  @override
  State<ClickedGroupDialog> createState() => _ClickedGroupDialogState();
}

class _ClickedGroupDialogState extends State<ClickedGroupDialog> {
  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  // TextEditingController selectedRootController = TextEditingController();

  bool isEditClicked = false;
  final _formKey = GlobalKey<FormState>();
  GroupsController groupsController = Get.find();
  HomeController homeController = Get.find();
  // String selectedGroupId = '';
  // String? selectedItem = '';
  // List<String> groupsNamesListForThisNode = [];
  // List groupsIdsListForThisNode  = [];
  @override
  void initState() {
    // groupsNamesListForThisNode=groupsController.groupsNamesList;
    // groupsIdsListForThisNode=groupsController.groupsIdsList;
    // groupsNamesListForThisNode.remove(widget.group.name);
    // groupsIdsListForThisNode.remove(widget.group.id);
    // codeController.text = widget.group.code ?? '';
    // nameController.text = widget.group.name ?? '';
    // selectedGroupId = widget.group.parentId ?? '';
    // // print('groupsIdsList ${widget.group.parentId}');
    // print('groupsIdsList $groupsIdsListForThisNode');
    // // print(
    // //     'groupsIdsList ${groupsController.groupsIdsList.indexOf(int.parse(selectedGroupId))}');
    // print('groupsIdsList $groupsNamesListForThisNode');
    // if (widget.group.parentId != '') {
    //   var index =
    //       groupsIdsListForThisNode.indexOf(int.parse(selectedGroupId));
    //   selectedItem = groupsNamesListForThisNode[index];
    //   selectedRootController.text = groupsNamesListForThisNode[index];
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GroupsController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          // width: Sizes.deviceWidth*0.2,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DialogTitle(
                    text: '${widget.group.code}${widget.group.name}'.tr,
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
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width:
                      homeController.isMobile.value
                          ? MediaQuery.of(context).size.width * 0.65
                              : MediaQuery.of(context).size.width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('code'.tr),
                          SizedBox(
                            width:
                            homeController.isMobile.value
                                    ? MediaQuery.of(context).size.width * 0.3
                                    : MediaQuery.of(context).size.width * 0.15,
                            child: ReusableTextField(
                              isEnable: isEditClicked,
                              onChangedFunc: (value) {},
                              validationFunc: (value) {},
                              hint: widget.group.code ?? '',
                              isPasswordField: false,
                              textEditingController: codeController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    gapH16,
                    SizedBox(
                      width:
                      homeController.isMobile.value
                              ? MediaQuery.of(context).size.width * 0.65
                              : MediaQuery.of(context).size.width * 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('name'.tr),
                          SizedBox(
                            width:
                            homeController.isMobile.value
                                    ? MediaQuery.of(context).size.width * 0.3
                                    : MediaQuery.of(context).size.width * 0.15,
                            child: ReusableTextField(
                              isEnable: isEditClicked,
                              onChangedFunc: (value) {},
                              validationFunc: (value) {},
                              hint: widget.group.name ?? '',
                              isPasswordField: false,
                              textEditingController: nameController,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // gapH16,
                    // SizedBox(
                    //   width: widget.isMobile
                    //       ? MediaQuery.of(context).size.width * 0.5
                    //       : MediaQuery.of(context).size.width * 0.25,
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text('${'main_group'.tr}*'),
                    //       DropdownMenu<String>(
                    //         enabled: isEditClicked,
                    //         width: widget.isMobile
                    //             ? MediaQuery.of(context).size.width * 0.2
                    //             : MediaQuery.of(context).size.width * 0.15,
                    //         enableSearch: true,
                    //         controller: selectedRootController,
                    //         inputDecorationTheme: InputDecorationTheme(
                    //           hintStyle:
                    //               const TextStyle(fontStyle: FontStyle.italic),
                    //           contentPadding:
                    //               const EdgeInsets.fromLTRB(20, 0, 25, 5),
                    //           enabledBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //                 color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    //                 width: 1),
                    //             borderRadius:
                    //                 const BorderRadius.all(Radius.circular(9)),
                    //           ),
                    //           focusedBorder: OutlineInputBorder(
                    //             borderSide: BorderSide(
                    //                 color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                    //                 width: 2),
                    //             borderRadius:
                    //                 const BorderRadius.all(Radius.circular(9)),
                    //           ),
                    //         ),
                    //         // menuStyle: ,
                    //         menuHeight: 250,
                    //         dropdownMenuEntries: groupsNamesListForThisNode
                    //             .map<DropdownMenuEntry<String>>((String option) {
                    //           return DropdownMenuEntry<String>(
                    //             value: option,
                    //             label: option,
                    //           );
                    //         }).toList(),
                    //         enableFilter: true,
                    //         onSelected: (String? val) {
                    //           setState(() {
                    //             selectedItem = val!;
                    //             var index = groupsNamesListForThisNode.indexOf(val);
                    //             selectedGroupId = '${groupsIdsListForThisNode[index]}';
                    //           });
                    //         },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    gapH32,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        !isEditClicked
                            ? ReusableButtonWithColor(
                              btnText: 'edit'.tr,
                              radius: 9,
                              onTapFunction: () async {
                                setState(() {
                                  isEditClicked = true;
                                });
                              },
                              width:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.13,
                              height: 50,
                            )
                            : ReusableButtonWithColor(
                              btnText: 'apply'.tr,
                              radius: 9,
                              onTapFunction: () async {
                                // if (_formKey.currentState!.validate()) {
                                var res = await updateGroup(
                                  '${widget.group.id}',
                                  codeController.text == ''
                                      ? '${widget.group.code}'
                                      : codeController.text,
                                  nameController.text == ''
                                      ? '${widget.group.name}'
                                      : nameController.text,
                                );
                                Get.back();
                                if ('${res['success']}' == 'true') {
                                  cont.getGroupsFromBack();
                                  CommonWidgets.snackBar(
                                    'Success',
                                    res['message'],
                                  );
                                } else {
                                  CommonWidgets.snackBar(
                                    'error',
                                    res['message'],
                                  );
                                }
                                // }
                              },
                              width: MediaQuery.of(context).size.width * 0.13,
                              height: 50,
                            ),
                        InkWell(
                          onTap: () async {
                            var res = await deleteGroup('${widget.group.id}');
                            Get.back();
                            // Get.back();
                            if ('${res['success']}' == 'true') {
                              cont.getGroupsFromBack();
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              // Get.back();
                              CommonWidgets.snackBar('error', res['message']);
                            }
                            // Get.back();
                          },
                          child: Container(
                            // padding: EdgeInsets.all(5),
                            width:homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.13,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              border: Border.all(color: Primary.p0),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Center(
                              child: Text(
                                'delete_group'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Primary.p0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
