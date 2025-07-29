import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/TaskBackend/store_task.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Controllers/users_controller.dart';
import 'package:rooster_app/Widgets/reusable_drop_down_menu.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/TaskBackend/update_task.dart';
import '../../Controllers/quotation_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'create_assigned_to_dialog.dart';

class ScheduleTaskDialogContent extends StatefulWidget {
  const ScheduleTaskDialogContent(
      {super.key,
      required this.quotationId,
      required this.isUpdate,
      required this.task});
  final String quotationId;
  final bool isUpdate;
  final Map task;
  @override
  State<ScheduleTaskDialogContent> createState() =>
      _ScheduleTaskDialogContentState();
}

class _ScheduleTaskDialogContentState extends State<ScheduleTaskDialogContent> {
  List<String> taskTypes = ['Email', 'Call', 'Meeting', 'Todo'];
  // List<String> users = [];
  TextEditingController dueDateController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController taskTypeController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  List<String> statusList = ['pending', 'done'];
  final _formKey = GlobalKey<FormState>();
  String startDate = '';

  UsersController usersController = Get.find();
  QuotationController quotationController = Get.find();
  TaskController taskController = Get.find();
  @override
  void initState() {
    startDate = '';
    summaryController.clear();
    noteController.clear();
    dueDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    taskController.assignedToController.clear();
    taskTypeController.clear();
    taskController.assignedToController.text = '';
    taskController.selectedUserId = '';
    usersController.getAllUsersFromBack();
    if (widget.isUpdate) {
      dueDateController.text = widget.task['date'];
      taskTypeController.text = widget.task['taskType'];
      statusController.text = widget.task['status'];
      summaryController.text = widget.task['summary'];
      noteController.text = widget.task['note'] ?? '';
      taskController.assignedToController.text =
          widget.task['assignedToUser']['name'];
      taskController.selectedUserId = '${widget.task['assignedToUser']['id']}';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double rowWidth = MediaQuery.of(context).size.width * 0.3;
    double textFieldWidth = MediaQuery.of(context).size.width * 0.2;
    return GetBuilder<TaskController>(builder: (taskCont) {
      return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.9,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PageTitle(
                      text: widget.isUpdate
                          ? 'update_task'.tr
                          : 'schedule_task'.tr),
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
              gapH70,
              Row(
                children: [
                  ReusableDropDownMenuWithSearch(
                    list: taskTypes,
                    text: '${'task_types'.tr}*',
                    hint: 'todo'.tr,
                    onSelected: (value) {},
                    validationFunc: (value) {
                      if (taskTypeController.text.isEmpty) {
                        return 'select_option'.tr;
                      }
                      return null;
                    },
                    rowWidth: rowWidth,
                    textFieldWidth: textFieldWidth,
                    controller: taskTypeController,
                    clickableOptionText: '',
                    isThereClickableOption: false,
                    onTappedClickableOption: () {},
                  ),
                  gapW70,
                  SizedBox(
                    width: rowWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'due_date'.tr}*',
                        ),
                        DialogDateTextField(
                          onChangedFunc: (value) {},
                          onDateSelected: (value) {
                            startDate = value;
                            dueDateController.text = value;
                          },
                          textEditingController: dueDateController,
                          text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                          textFieldWidth: textFieldWidth,
                          validationFunc: (value) {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              gapH40,
              Row(
                children: [
                  DialogTextField(
                    textEditingController: summaryController,
                    text: '${'summary'.tr}*',
                    rowWidth: rowWidth,
                    textFieldWidth: textFieldWidth,
                    validationFunc: (String value) {
                      if (value.isEmpty) {
                        return 'required_field'.tr;
                      }
                      return null;
                    },
                  ),
                  gapW70,
                  GetBuilder<UsersController>(builder: (userCont) {
                    return ReusableDropDownMenuWithSearch(
                      list: userCont.usersNamesList,
                      text: '${'assigned_to'.tr}*',
                      hint: '',
                      controller: taskCont.assignedToController,
                      onSelected: (val) {
                        var index = userCont.usersNamesList.indexOf(val!);
                        taskCont.setSelectedUserId(
                            '${userCont.usersIdsList[index]}');
                      },
                      validationFunc: (value) {
                        if (taskCont.selectedUserId.isEmpty) {
                          return 'select_option'.tr;
                        }
                        return null;
                      },
                      rowWidth: rowWidth,
                      textFieldWidth: textFieldWidth,
                      clickableOptionText: 'or_create_new_assigned_to'.tr,
                      isThereClickableOption: true,
                      onTappedClickableOption: () {
                        showDialog<String>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(9)),
                                ),
                                elevation: 0,
                                content: CreateAssignedToDialog(
                                  enteredName:
                                      taskCont.assignedToController.text,
                                )));
                      },
                    );
                  }),
                ],
              ),
              gapH40,
              widget.isUpdate
                  ? Row(
                      children: [
                        ReusableDropDownMenuWithSearch(
                          list: statusList,
                          text: '${'status'.tr}*',
                          hint: '',
                          onSelected: (value) {},
                          validationFunc: (value) {
                            if (statusController.text.isEmpty) {
                              return 'select_option'.tr;
                            }
                            return null;
                          },
                          rowWidth: rowWidth,
                          textFieldWidth: textFieldWidth,
                          controller: statusController,
                          clickableOptionText: '',
                          isThereClickableOption: false,
                          onTappedClickableOption: () {},
                        ),
                        gapW70,
                        DialogTextField(
                          textEditingController: noteController,
                          text: '${'note'.tr}*',
                          rowWidth: rowWidth,
                          textFieldWidth: textFieldWidth,
                          validationFunc: (String value) {
                            if (value.isEmpty) {
                              return 'required_field'.tr;
                            }
                            return null;
                          },
                        ),
                      ],
                    )
                  : const SizedBox(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          if (widget.isUpdate) {
                            startDate = '';
                            dueDateController.text = widget.task['date'];
                            taskTypeController.text = widget.task['taskType'];
                            statusController.text = widget.task['status'];
                            summaryController.text = widget.task['summary'];
                            taskController.assignedToController.text =
                                widget.task['assignedToUser']['name'];
                            taskController.setSelectedUserId(
                                '${widget.task['assignedToUser']['id']}');
                          } else {
                            startDate = '';
                            summaryController.clear();
                            dueDateController.text =
                                DateFormat('yyyy-MM-dd').format(DateTime.now());
                            taskCont.assignedToController.clear();
                            taskTypeController.clear();
                            taskCont.setSelectedUserId('');
                          }
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
                        if (_formKey.currentState!.validate()) {
                          if (widget.isUpdate) {
                            var res = await updateTask(
                                '${widget.task['quotationId']}',
                                '${widget.task['id']}',
                                statusController.text,
                                taskTypeController.text,
                                dueDateController.text,
                                summaryController.text,
                                noteController.text,
                                taskController.selectedUserId);
                            if (res['success'] == true) {
                              Get.back();
                              // homeController.selectedTab.value =
                              // 'categories';
                              quotationController.getAllQuotationsWithoutPendingFromBack();
                              taskController.getAllTasksFromBack('');
                              taskCont.searchInTasksController.clear();
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
                            }
                          } else {
                            var res = await storeTask(
                                widget.quotationId,
                                taskCont.selectedUserId,
                                summaryController.text,
                                taskTypeController.text,
                                dueDateController.text);
                            if (res['success'] == true) {
                              Get.back();
                              // homeController.selectedTab.value =
                              // 'categories';
                              quotationController.getAllQuotationsWithoutPendingFromBack();
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
                            }
                          }
                        }
                      },
                      width: 100,
                      height: 35),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
