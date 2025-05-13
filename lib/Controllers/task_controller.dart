import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/TaskBackend/get_tasks.dart';




class TaskController extends GetxController {
  TextEditingController assignedToController = TextEditingController();
  String selectedUserId = '';

  setSelectedUserId(String val){
    selectedUserId = val;
    update();
  }


  TextEditingController searchInTasksController = TextEditingController();
  List tasksList = [];
  bool isTasksFetched = false;
  getAllTasksFromBack(String search) async {
    tasksList = [];
    isTasksFetched = false;
    update();
    var p = await getAllTasks(search);
    if (p['success']==true) {
      tasksList = p['data'];
      tasksList = tasksList.reversed.toList();
      isTasksFetched = true;
    }
    update();
  }

}
