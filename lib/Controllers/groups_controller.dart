
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:get/get.dart';
import '../Backend/GroupsBackend/get_groups.dart';
import '../Backend/GroupsBackend/store_group.dart';
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
  RxList<Group> groups = <Group>[].obs;


  void addGroup({Group? parent}) {
    final newGroup = Group(
      id: DateTime.now().millisecondsSinceEpoch,
      code: '',
      name: '',
      children: [],
    );

    if (parent == null) {
      groups.add(newGroup);
    } else {
      parent.children!.add(newGroup);
      groups.refresh();
    }
  }

  void deleteGroup(Group target, [List<Group>? list]) {
    final currentList = list ?? groups;
    currentList.removeWhere((g) {
      if (g.id == target.id) return true;
      if (g.children!.isNotEmpty) deleteGroup(target, g.children);
      return false;
    });
    groups.refresh();
  }

  void updateField(Group group, {String? name, String? code}) {
    if (name != null) group.name = name;
    if (code != null) group.code = code;
    // groups.refresh();
  }

  // --- Send all groups (with children) to backend
  // Future sendToBackend() async {
  //   final data = groups.map((e) => e.toJson()).toList();
  //   print(data); // Here you can call Dio POST request
  //   // await dio.post(kItemGroupsUrl, data: {'groups': data});
  //   final uri = Uri.parse(kStoreGroupUrl);
  //   String token = await getAccessTokenFromPref();
  //   var response = await dio.post(uri, headers: {
  //     "Accept": "application/json",
  //     "Authorization": "Bearer $token"
  //   }, body: {'groups': data});
  //
  //   var p = json.decode(response.body);
  //   return p;
  // }
  Map<String, dynamic> flattenGroups(List<Group> groups, [String prefix = 'groups']) {
    final Map<String, dynamic> result = {};
    for (int i = 0; i < groups.length; i++) {
      final group = groups[i];
      final currentPrefix = '$prefix[$i]';

      if (group.name != null) result['$currentPrefix[name]'] = group.name!;
      if (group.code != null) result['$currentPrefix[code]'] = group.code!;

      if (group.children != null && group.children!.isNotEmpty) {
        result.addAll(flattenGroups(group.children!, '$currentPrefix[children]'));
      }
    }
    return result;
  }

  Future sendToBackend() async {

    try {
      final data = flattenGroups(groups);
      var res=await storeGroup(data);
      return res;
    } catch (e) {
      // print(" Error sending groups: $e");
      // print(s);
      rethrow;
    }
  }

}
