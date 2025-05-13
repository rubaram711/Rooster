import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/UsersBackend/create_user.dart';
import 'package:rooster_app/Backend/UsersBackend/get_user.dart';




class UsersController extends GetxController {
  List usersList = [];
  List<String> usersNamesList = [];
  List usersIdsList = [];
  List rolesList=[];
  List<String> rolesNamesList=[];
  List<String> selectedRolesNamesList=[];
  List rolesIdsList=[];
  List selectedRolesIdsList=[];
  List<String> posNamesList=[];
  List posIdsList=[];
  bool isUsersFetched = false;
  bool isRolesFetched = false;
  bool isPossFetched = false;
  int selectedUserIndex=0;
  String selectedRoleId='0';
  String selectedPosId='0';


  setSelectedUserIndex(int val){
     selectedUserIndex=val;
     update();
  }
  setSelectedRoleId(String val){
    selectedRoleId=val;
     update();
  }
  setSelectedPosId(String val){
    selectedPosId=val;
     update();
  }
  setSelectedRolesIds(List<String> val){
    selectedRolesIdsList=val;
     update();
  }
  setSelectedRolesNames(List<String> val){
    selectedRolesNamesList=val;
     update();
  }
addToSelectedRolesIds(String val){
  selectedRolesIdsList.add(val);
  update();
}

  getFieldsForCreateUserFromBack() async {
    rolesList=[];
    rolesNamesList=[];
    rolesIdsList=[];
    selectedRolesNamesList=[];
    selectedRolesIdsList=[];
    posNamesList=[];
    posIdsList=[];
    isRolesFetched=false;
    isPossFetched=false;
    var p = await getFieldsForCreateUser();
    if('$p' != '[]'){
      rolesList=p['roles'];//todo check names
      for (var c in p['roles'] ) { //todo check names
        rolesNamesList.add('${c['name']}');
        rolesIdsList.add('${c['id']}');
      }
      for (var c in p['posTerminals'] ) { //todo check names
        posNamesList.add('${c['name']}');
        posIdsList.add('${c['id']}');
      }
      isPossFetched = true;
      isRolesFetched=true;
    }
    update();
  }

  TextEditingController searchController=TextEditingController();
  getAllUsersFromBack() async {
      usersList = [];
      usersNamesList = [];
      usersIdsList = [];
      isUsersFetched = false;
      var p= await getAllUsers(searchController.text);
      if ('$p' != '[]') {
        usersList=p;
        usersList=usersList.reversed.toList();
        for (var user in p) {
          usersNamesList.add('${user['name']}');
          usersIdsList.add('${user['id']}');
        }
        // update();
      }
      isUsersFetched = true;
      update();
  }



}
