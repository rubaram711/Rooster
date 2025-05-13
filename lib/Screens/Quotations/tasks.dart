import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Screens/Quotations/schedule_task_dialog.dart';
import '../../Backend/TaskBackend/delete_task.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/task_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/colors.dart';
// ignore: depend_on_referenced_packages
// import 'package:intl/intl.dart';


class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  GlobalKey accMoreKey = GlobalKey();
  final HomeController homeController = Get.find();
  final TaskController taskController = Get.find();


  @override
  void initState() {
    taskController.searchInTasksController.text='';
    taskController.getAllTasksFromBack('');
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TaskController>(
        builder: (cont) {
          return Column(
            children: [
              Container(
                //   padding:
                //       const EdgeInsets.symmetric(vertical: 15),
                padding: const EdgeInsets.symmetric(
                    horizontal: 5, vertical: 15),
                decoration: BoxDecoration(
                    color: Primary.primary,
                    borderRadius:
                    const BorderRadius.all(Radius.circular(6))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TableTitle(
                      text: 'task_types'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    TableTitle(
                      text: 'date'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    TableTitle(
                      text: 'summary'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    TableTitle(
                      text: 'assigned_to'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    TableTitle(
                      text: 'status'.tr,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    TableTitle(
                      text: 'more_options'.tr,
                      width: MediaQuery.of(context).size.width * 0.11,
                    ),
                  ],
                ),
              ),
              cont.isTasksFetched
                  ?Container(
                color: Colors.white,
                // height: listViewLength,
                height:MediaQuery.of(context).size.height*0.4,//listViewLength
                child: ListView.builder(
                  itemCount:  cont.tasksList.length ,
                  // itemCount:  cont.quotationsList.length>9?selectedNumberOfRowsAsInt:cont.quotationsList.length,
                  itemBuilder: (context, index) => Column(
                    children: [
                      TaskAsRowInTable(
                        info: cont.tasksList[index],
                        index: index,
                      ),
                      const Divider()
                    ],
                  ),
                ),
              ):const CircularProgressIndicator(),
            ],
          );
        }
    );
  }

  String hoverTitle = '';
  String clickedTitle = '';
  bool isClicked = false;
  tableTitleWithOrderArrow(String text, double width, Function onClickedFunc) {
    return SizedBox(
      width: width,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              clickedTitle = text;
              hoverTitle = '';
              isClicked = !isClicked;
              onClickedFunc();
            });
          },
          onHover: (val) {
            if (val) {
              setState(() {
                hoverTitle = text;
              });
            } else {
              setState(() {
                hoverTitle = '';
              });
            }
          },
          child: clickedTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text.length>8?'${text.substring(0,8)}...':text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              isClicked
                  ? const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              )
                  : const Icon(
                Icons.arrow_drop_up,
                color: Colors.white,
              )
            ],
          )
              : hoverTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${text.length>7?text.substring(0,6):text}...',
                  style: TextStyle(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withAlpha((0.5 * 255).toInt()),
              )
            ],
          )
              : Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class ReusableChip extends StatelessWidget {
  const ReusableChip({super.key, required this.name, this.isDesktop=true});
  final String name;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: ClipPath(
        clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9)))),
        child: Container(
          width:isDesktop? MediaQuery.of(context).size.width * 0.09: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.07,
          // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          decoration: BoxDecoration(
              color: Primary.p20,
              border: Border(
                top: BorderSide(color: Primary.primary, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                )
              ]),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Primary.primary),
            ),
          ),
        ),
      ),
    );
  }
}


class TaskAsRowInTable extends StatefulWidget {
  const TaskAsRowInTable(
      {super.key, required this.info, required this.index,  this.isDesktop=true});
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<TaskAsRowInTable> createState() => _TaskAsRowInTableState();
}

class _TaskAsRowInTableState extends State<TaskAsRowInTable> {
  final HomeController homeController = Get.find();
  final TaskController taskController = Get.find();


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric( vertical: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TableItem(
            text: '${widget.info['taskType'] ?? ''}',
            width: widget.isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          TableItem(
            text: '${widget.info['date'] ?? ''}',
            width: widget.isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          TableItem(
            text: '${widget.info['summary'] ?? ''}',
            width: widget.isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          TableItem(
            text: '${widget.info['assignedToUser']['name'] ?? ''}',
            width: widget.isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          SizedBox(
            width:widget.isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
            child: Center(
              child: Container(
                width: '${widget.info['status']}'.length * 12.0,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                    color:widget.info['status'] == 'pending'
                        ? Others.orangeStatusColor
                        : widget.info['status'] == 'done'
                        ? Others.greenStatusColor
                        : Colors.blue,
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                    child: Text(
                      '${widget.info['status'] ?? ''}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
              ),
            ),
          ),
          // SizedBox(
          //   width:widget.isDesktop? MediaQuery.of(context).size.width * 0.085 :150,
          //   // width:MediaQuery.of(context).size.width * 0.08,
          //   child: ReusableMore(itemsList: [
          //     PopupMenuItem<String>(
          //       value: '1',
          //       onTap: () async {
          //
          //       },
          //       child: Text('update'.tr),
          //     ),
          //   ]),
          // ),

          SizedBox(
            width: MediaQuery.of(context).size.width *
                0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () async {
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) =>
                            AlertDialog(
                                backgroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(9)),
                                ),
                                elevation: 0,
                                content:ScheduleTaskDialogContent(
                                  quotationId: '${widget.info['id']}',
                                  task: widget.info,
                                  isUpdate: true,
                                )
                                // UpdateScheduleTaskDialogContent(taskId: '${widget.info['id']}',task: widget.info,)
                            ));
                  },
                  child: Icon(
                    Icons.edit,
                    color: Primary.primary,
                  ),
                ),
                InkWell(
                  onTap: () async {
                    var res = await deleteTask('${taskController.tasksList[widget.index]['id']}');
                    var p = json.decode(res.body);
                    if (res.statusCode == 200) {
                      CommonWidgets.snackBar(
                          'Success', p['message']);
                      taskController.getAllTasksFromBack('');
                      taskController.searchInTasksController.clear();
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// class UpdateScheduleTaskDialogContent extends StatefulWidget {
//   const UpdateScheduleTaskDialogContent({super.key, required this.taskId, required this.task});
//   final String taskId;
//   final Map task;
//   @override
//   State<UpdateScheduleTaskDialogContent> createState() =>
//       _UpdateScheduleTaskDialogContentState();
// }
//
// class _UpdateScheduleTaskDialogContentState extends State<UpdateScheduleTaskDialogContent> {
//   List<String> taskTypes = ['Email','Call','Meeting','Todo'];
//   List<String> statusList = ['pending','done'];
//   TextEditingController dueDateController = TextEditingController();
//   TextEditingController taskTypeController = TextEditingController();
//   TextEditingController statusController = TextEditingController();
//   TextEditingController summaryController = TextEditingController();
//
//   final _formKey = GlobalKey<FormState>();
//   String startDate = '';
//
//
//   QuotationController quotationController=Get.find();
//   TaskController taskController=Get.find();
//   @override
//   void initState() {
//     startDate = '';
//     dueDateController.text=widget.task['date'];
//     taskTypeController.text=widget.task['taskType'];
//     statusController.text=widget.task['status'];
//     summaryController.text=widget.task['summary'];
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     double rowWidth=  MediaQuery.of(context).size.width * 0.3;
//     double textFieldWidth=  MediaQuery.of(context).size.width * 0.2;
//     return GetBuilder<TaskController>(
//         builder: (taskCont) {
//           return Container(
//             color: Colors.white,
//             width: MediaQuery.of(context).size.width * 0.8,
//             height: MediaQuery.of(context).size.height * 0.9,
//             margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       PageTitle(text: 'update_task'.tr),
//                       InkWell(
//                         onTap: () {
//                           Get.back();
//                         },
//                         child: CircleAvatar(
//                           backgroundColor: Primary.primary,
//                           radius: 15,
//                           child: const Icon(
//                             Icons.close_rounded,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   gapH70,
//                   Row(
//                     children: [
//                       ReusableDropDownMenuWithSearch(
//                         list: taskTypes,
//                         text: '${'task_types'.tr}*',
//                         hint: '',
//                         onSelected: (value) {},
//                         validationFunc: (value) {
//                           if (taskTypeController.text.isEmpty) {
//                             return 'select_option'.tr;
//                           }
//                           return null;
//                         },
//                         rowWidth: rowWidth,
//                         textFieldWidth:  textFieldWidth,
//                         controller: taskTypeController,
//                         clickableOptionText: '',
//                         isThereClickableOption: false,
//                         onTappedClickableOption: (){},
//                       ),
//                       gapW70,
//                       SizedBox(
//                         width:rowWidth,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               '${'due_date'.tr}*',
//                             ),
//                             DialogDateTextField(
//                               onChangedFunc: (value) {},
//                               onDateSelected: (value) {
//                                 startDate=value;
//                                 dueDateController.text=value;
//                               },
//                               textEditingController: dueDateController,
//                               text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
//                               textFieldWidth:  textFieldWidth,
//                               validationFunc: (value) {},
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   gapH40,
//                   Row(
//                     children: [
//                       DialogTextField(
//                         textEditingController: summaryController,
//                         text: '${'summary'.tr}*',
//                         rowWidth: rowWidth,
//                         textFieldWidth:  textFieldWidth,
//                         validationFunc: (String value){
//                           if(value.isEmpty){
//                             return 'required_field'.tr;
//                           }return null;
//                         },
//                       ),
//                       gapW70,
//                       ReusableDropDownMenuWithSearch(
//                         list: statusList,
//                         text: '${'status'.tr}*',
//                         hint: '',
//                         onSelected: (value) {},
//                         validationFunc: (value) {
//                           if (statusController.text.isEmpty) {
//                             return 'select_option'.tr;
//                           }
//                           return null;
//                         },
//                         rowWidth: rowWidth,
//                         textFieldWidth:  textFieldWidth,
//                         controller: statusController,
//                         clickableOptionText: '',
//                         isThereClickableOption: false,
//                         onTappedClickableOption: (){},
//                       ),
//                     ],
//                   ),
//                   const Spacer(),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                           onPressed: (){
//                             setState(() {
//                               startDate = '';
//                               dueDateController.text=widget.task['date'];
//                               taskTypeController.text=widget.task['taskType'];
//                               statusController.text=widget.task['status'];
//                               summaryController.text=widget.task['summary'];
//                             });
//                           },
//                           child: Text('discard'.tr,style: TextStyle(
//                               decoration: TextDecoration.underline,
//                               color: Primary.primary
//                           ),)),
//                       gapW24,
//                       ReusableButtonWithColor(btnText: 'save'.tr, onTapFunction: ()async{
//                         if(_formKey.currentState!.validate()) {
//                           var res = await updateTask('${widget.task['quotationId']}',widget.taskId, statusController.text, taskTypeController.text, dueDateController.text, summaryController.text);
//                           if (res['success'] == true) {
//                             Get.back();
//                             // homeController.selectedTab.value =
//                             // 'categories';
//                             quotationController.getAllQuotationsFromBack();
//                             taskController.getAllTasksFromBack('');
//                             taskCont.searchInTasksController.clear();
//                             CommonWidgets.snackBar('Success',
//                                 res['message'] );
//                           } else {
//                             CommonWidgets.snackBar('error',
//                                 res['message']);
//                           }
//                         }
//                       }, width: 100, height: 35),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           );
//         }
//     );
//   }
// }