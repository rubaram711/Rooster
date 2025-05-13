import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../Backend/RolesAndPermissionsBackend/get_roles.dart';
import '../Backend/RolesAndPermissionsBackend/get_roles_and_permissions.dart';
import '../Models/RolesAndPermissions/roles_and_permissions_model.dart';





class RolesAndPermissionsController extends GetxController {
  int selectedTabIndex = 0;
  bool isItUpdateRole=false;
  bool isRolesFetched = false;
  TextEditingController searchController = TextEditingController();
  TextEditingController searchOnRoleController = TextEditingController();
  List grants=[];
  // List rolesAndPermissionsList = [];
  // List rolesList = [];
  // List permissionsList = [];
  bool isRolesAndPermissionsFetched = false;
  List ratesInRolesLis=[];
  int selectedRolesIndex=0;
  List<RolesAndPermissions> rolesAndPermissionsList=[];
  List<Roles> rolesList=[];
  List<Permissions> permissionsList=[];

  setIsItUpdateRoles(bool value){
    isItUpdateRole=value;
    update();
  }

  addToGrantsList(Map val){
    grants.add(val);
    update();
  }
  removeFromGrant(int roleId,int permissionId){
    final int index = grants.indexWhere((e) => e['roleId'] == roleId && e['permissionId'] == permissionId);
   if(index!=-1){
     grants.removeAt(index);
     update();
   }
  }

  setSelectedRolesIndex(int val){
     selectedRolesIndex=val;
     update();
  }
  setRatesInRolesLis(List newList){
    ratesInRolesLis=newList;
    update();
  }
var p={
  "success": true,
  "data": {
    "rolesAndPermissions": [
      {
        "id": 2,
        "company_id": 1,
        "name": "admin",
        "guard_name": "web",
        "created_at": "2024-09-01T14:02:16.000000Z",
        "updated_at": null,
        "permissions": [
          {
            "id": 66,
            "name": "get single replenishment",
            "display_name": "View replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 66
            }
          },
          {
            "id": 67,
            "name": "create replenishment",
            "display_name": "Create replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 67
            }
          },
          {
            "id": 68,
            "name": "edit replenishment",
            "display_name": "Edit replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 68
            }
          },
          {
            "id": 69,
            "name": "delete replenishment",
            "display_name": "Delete replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 69
            }
          },
          {
            "id": 70,
            "name": "get all transfers",
            "display_name": "View transfer List",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 70
            }
          },
          {
            "id": 91,
            "name": "close cash tray",
            "display_name": "Close Cash Tray",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 91
            }
          }
        ]
      } ,
      {
        "id": 23,
        "company_id": 1,
        "name": "cashier",
        "guard_name": "web",
        "created_at": "2024-09-01T14:02:16.000000Z",
        "updated_at": null,
        "permissions": [
          {
            "id": 66,
            "name": "get single replenishment",
            "display_name": "View replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 66
            }
          },
          {
            "id": 67,
            "name": "create replenishment",
            "display_name": "Create replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 67
            }
          },
          {
            "id": 68,
            "name": "edit replenishment",
            "display_name": "Edit replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 68
            }
          },
          {
            "id": 69,
            "name": "delete replenishment",
            "display_name": "Delete replenishment",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 69
            }
          },
          {
            "id": 70,
            "name": "get all transfers",
            "display_name": "View transfer List",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 70
            }
          },
          {
            "id": 91,
            "name": "close cash tray",
            "display_name": "Close Cash Tray",
            "type": "static",
            "guard_name": "web",
            "created_at": "2024-11-21T07:54:44.000000Z",
            "updated_at": "2024-11-21T07:54:44.000000Z",
            "pivot": {
              "role_id": 23,
              "permission_id": 91
            }
          }
        ]
      }
    ],
    "roles": [
      {
        "id": 2,
        "name": "admin"
      },
      {
        "id": 23,
        "name": "cashier"
      }
    ],
    "permissions": [
      {
        "id": 91,
        "name": "close cash tray"
      },
      {
        "id": 86,
        "name": "create an order"
      },
      {
        "id": 90,
        "name": "create cash tray"
      },
      {
        "id": 62,
        "name": "create category"
      },
      {
        "id": 21,
        "name": "create client"
      },
      {
        "id": 34,
        "name": "create combo"
      },
      {
        "id": 6,
        "name": "create company"
      },
      {
        "id": 26,
        "name": "create item"
      },
      {
        "id": 57,
        "name": "create item group"
      },
      {
        "id": 82,
        "name": "create posTerminal"
      },
      {
        "id": 39,
        "name": "create quotation"
      },
      {
        "id": 67,
        "name": "create replenishment"
      },
      {
        "id": 77,
        "name": "create session"
      },
      {
        "id": 52,
        "name": "create taxation group"
      },
      {
        "id": 72,
        "name": "create transfer"
      },
      {
        "id": 11,
        "name": "create user"
      },
      {
        "id": 16,
        "name": "create warehouse"
      },
      {
        "id": 89,
        "name": "delete an order"
      },
      {
        "id": 64,
        "name": "delete category"
      },
      {
        "id": 23,
        "name": "delete client"
      },
      {
        "id": 36,
        "name": "delete combo"
      },
      {
        "id": 8,
        "name": "delete company"
      },
      {
        "id": 28,
        "name": "delete item"
      },
      {
        "id": 59,
        "name": "delete item group"
      },
      {
        "id": 84,
        "name": "delete posTerminals"
      },
      {
        "id": 41,
        "name": "delete quotation"
      },
      {
        "id": 69,
        "name": "delete replenishment"
      },
      {
        "id": 79,
        "name": "delete session"
      },
      {
        "id": 54,
        "name": "delete taxation group"
      },
      {
        "id": 74,
        "name": "delete transfer"
      },
      {
        "id": 13,
        "name": "delete user"
      },
      {
        "id": 18,
        "name": "delete warehouse"
      },
      {
        "id": 63,
        "name": "edit category"
      },
      {
        "id": 22,
        "name": "edit client"
      },
      {
        "id": 35,
        "name": "edit combo"
      },
      {
        "id": 46,
        "name": "edit combo description in quotation"
      },
      {
        "id": 7,
        "name": "edit company"
      },
      {
        "id": 27,
        "name": "edit item"
      },
      {
        "id": 45,
        "name": "edit item description in combo"
      },
      {
        "id": 42,
        "name": "edit item description in quotation"
      },
      {
        "id": 58,
        "name": "edit item group"
      },
      {
        "id": 44,
        "name": "edit item unit price in combo"
      },
      {
        "id": 43,
        "name": "edit item unit price in quotation"
      },
      {
        "id": 83,
        "name": "edit posTerminal"
      },
      {
        "id": 40,
        "name": "edit quotation"
      },
      {
        "id": 68,
        "name": "edit replenishment"
      },
      {
        "id": 47,
        "name": "edit salesperson cashing method in quotation"
      },
      {
        "id": 49,
        "name": "edit salesperson commission in quotation"
      },
      {
        "id": 48,
        "name": "edit salesperson commission method in quotation"
      },
      {
        "id": 78,
        "name": "edit session"
      },
      {
        "id": 53,
        "name": "edit taxation group"
      },
      {
        "id": 73,
        "name": "edit transfer"
      },
      {
        "id": 12,
        "name": "edit user"
      },
      {
        "id": 17,
        "name": "edit warehouse"
      },
      {
        "id": 87,
        "name": "finish an order"
      },
      {
        "id": 29,
        "name": "get all alternative_codes"
      },
      {
        "id": 31,
        "name": "get all barcodes"
      },
      {
        "id": 60,
        "name": "get all categories"
      },
      {
        "id": 19,
        "name": "get all clients"
      },
      {
        "id": 32,
        "name": "get all combos"
      },
      {
        "id": 4,
        "name": "get all companies"
      },
      {
        "id": 55,
        "name": "get all item groups"
      },
      {
        "id": 24,
        "name": "get all items"
      },
      {
        "id": 85,
        "name": "get all orders"
      },
      {
        "id": 80,
        "name": "get all posTerminals"
      },
      {
        "id": 37,
        "name": "get all quotations"
      },
      {
        "id": 65,
        "name": "get all replenishments"
      },
      {
        "id": 75,
        "name": "get all sessions"
      },
      {
        "id": 30,
        "name": "get all supplier_codes"
      },
      {
        "id": 50,
        "name": "get all taxation groups"
      },
      {
        "id": 70,
        "name": "get all transfers"
      },
      {
        "id": 92,
        "name": "get all trays"
      },
      {
        "id": 9,
        "name": "get all users"
      },
      {
        "id": 14,
        "name": "get all warehouses"
      },
      {
        "id": 61,
        "name": "get single category"
      },
      {
        "id": 20,
        "name": "get single client"
      },
      {
        "id": 33,
        "name": "get single combo"
      },
      {
        "id": 5,
        "name": "get single company"
      },
      {
        "id": 25,
        "name": "get single item"
      },
      {
        "id": 56,
        "name": "get single item group"
      },
      {
        "id": 81,
        "name": "get single posTerminal"
      },
      {
        "id": 38,
        "name": "get single quotation"
      },
      {
        "id": 66,
        "name": "get single replenishment"
      },
      {
        "id": 76,
        "name": "get single session"
      },
      {
        "id": 51,
        "name": "get single taxation group"
      },
      {
        "id": 71,
        "name": "get single transfer"
      },
      {
        "id": 10,
        "name": "get single user"
      },
      {
        "id": 15,
        "name": "get single warehouse"
      },
      {
        "id": 2,
        "name": "impersonate"
      },
      {
        "id": 88,
        "name": "update an order"
      },
      {
        "id": 3,
        "name": "view company"
      },
      {
        "id": 1,
        "name": "view nova"
      }
    ]
  },
  "message": "Roles fetched successfully"
};

  getAllRolesAndPermissionsFromBack() async {
    permissionsList = [];
    rolesAndPermissionsList=[];
      isRolesAndPermissionsFetched = false;
      var p= await getRolesAndPermissions(searchController.text);
      if (p["success"]==true) {
        permissionsList=p['data']['permissions'].map<Permissions>((e) => Permissions.fromJson(e)).toList();
        rolesAndPermissionsList=p['data']['rolesAndPermissions'].map<RolesAndPermissions>((e) => RolesAndPermissions.fromJson(e)).toList();
        isRolesAndPermissionsFetched=true;
      }
      update();

}

reset(){
  grants=[];
  // permissionsList = [];
  // rolesAndPermissionsList=[];
  // isRolesAndPermissionsFetched = false;
  update();
}

  getAllRolesFromBack()async{
    rolesList = [];
    isRolesFetched = false;
    var p= await getRoles(searchOnRoleController.text);
    if (p["success"]==true) {
       rolesList = p['data']['roles'].map<Roles>((e) => Roles.fromJson(e)).toList();
       isRolesFetched=true;
    }
      update();
  }


}
