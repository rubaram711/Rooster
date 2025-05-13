import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import '../Backend/GroupsBackend/get_groups.dart';
import '../Models/Groups/groups_model.dart';
import '../Screens/Configuration/categories_dialog.dart';



class GroupsController extends GetxController {
  int selectedTabIndex = 0;

  setSelectedTabIndex(int newVal){
    selectedTabIndex = newVal;
    update();
  }
  List groupsList = [];
  List<String> groupsNamesList = [];
  List groupsIdsList = [];
  bool isGroupsFetched = false;
  Map selectedCategory={};
  List<String> subGroupsNamesList = [];
  List subGroupsIdsList = [];
  List<String> selectedSubGroups = [];
  List<List<String>> groupBranches = [];
  List<List<int>> groupsIds = [];
  // getBranchForChildren(List list, int topFatherIndex) {
  //   for (int i = 0; i < list.length; i++) {
  //     print('children $i ${list[i]}');
  //       if ('${list[i]['children']}' == '[]') {
  //         if (!groupBranches[topFatherIndex]
  //             .contains(list[i]['show_name'])) {
  //           groupBranches[topFatherIndex]
  //               .add(list[i]['show_name']);
  //           groupsIds[topFatherIndex].add(list[i]['id']);
  //         }
  //       } else {
  //         getBranchForChildren(list[i]['children'], topFatherIndex);
  //       }
  //
  //   }
  // }

  // reformatGroupsForShow() {
  //   for (int i = 0; i < groupsList.length; i++) {
  //     groupBranches.add([]);
  //     groupsIds.add([]);
  //     getBranchForChildren(groupsList[i]['children'], i);
  //   }
  //   print('branches');
  //   print(groupBranches);
  //   print(groupsIds);
  //   // getMenuGroupsNames();
  //
  // }
  addChildren(List list) {
    for (int i = 0; i < list.length; i++) {
      if ('${list[i]['children']}' != '[]') {
        groupsNamesList.add(list[i]['code']??'');
        groupsIdsList.add(list[i]['id']);
      } else {
        groupsNamesList.add(list[i]['code']??'');
        groupsIdsList.add(list[i]['id']);
        addChildren(list[i]['children']);
      }
    }
  }

  reformatGroups() {
    for (int i = 0; i < groupsList.length; i++) {
      groupsNamesList.add(groupsList[i]['code']??'');
      groupsIdsList.add(groupsList[i]['id']);
      addChildren(groupsList[i]['children']);
    }
  }
List<Group> roots=[];
  late TreeController<Group> treeController;
  bool isInitializedController=false;
  getGroupsFromBack() async {
      groupsList = [];
      groupsNamesList=[];
      groupsIdsList=[];
      groupBranches = [];
      groupsIds=[];
      roots=[];
      isGroupsFetched = false;
      var p = await getGroups(searchCategoryController.text);
      if('$p'!='[]'){
        roots = p.map<Group>((e) => Group.fromJson(e)).toList();
      }
        treeController = TreeController<Group>(
          roots: roots,
          childrenProvider: (Group node) => node.children ?? [],
          defaultExpansionState: true
        );

      groupsList.addAll(p);
      reformatGroups();
      // reformatGroupsForShow();
      isGroupsFetched = true;
      update();
  }


  // setSelectedCategory(Map newVal){
  //   selectedSubGroups=[];
  //   subGroupsIdsList=[];
  //   selectedCategory=newVal;
  //   oldCatNameController.text=selectedCategory['groups_name'];
  //   for (var cat in selectedCategory['children']) {
  //     selectedSubGroups.add('${cat['groups_name']}');
  //     subGroupsIdsList.add('${cat['id']}');
  //   }
  //   update();
  // }

  // setSelectedSubGroups(List<String> newList){
  //   selectedSubGroups=newList;
  //   update();
  // }
}
