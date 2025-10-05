import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Models/Inventory/inventory_model.dart';

import '../../Backend/CategoriesBackend/get_categories.dart';
import '../../Backend/GroupsBackend/get_groups.dart';
import '../../Backend/InventoryBackend/get_inventory_items.dart';
import '../../Backend/ProductsBackend/get_products.dart';

class InventoryController extends GetxController {
  List<InventoryItem> itemsList = [];
  bool isItemsFetched = false;
  String selectedWarehouseId = '';
  TextEditingController warehouseMenuController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  setSelectedWarehouseId(String val) {
    selectedWarehouseId = val;
    update();
  }

  getItemsFromBack() async {
    itemsList = [];
    isItemsFetched = false;
    selectedWarehouseId = '';
    // var p = await getInventory('');
    // if('$p' != '[]'){
    //   itemsList=p;
    //   itemsList=itemsList.reversed.toList();
    // }
    isItemsFetched = true;
    update();
  }

  List<String> itemsNamesList = ['All Items'];
  List itemsIdsList = ['0'];
  bool isItemsMenuFetched = false;
  String selectedItemId = '0';
  TextEditingController itemsController = TextEditingController();

  setSelectedItemId(String newVal) {
    selectedItemId = newVal;
    update();
  }

  getAllProductsFromBack() async {
    itemsNamesList = ['all_items'.tr];
    itemsController.text = itemsNamesList[0];
    itemsIdsList = ['0'];
    isItemsMenuFetched = false;
    selectedItemId = '0';
    var p = await getAllProducts('', '', '',-1);
    for (var item in p) {
      itemsNamesList.add('${item['item_name']}');
      itemsIdsList.add('${item['id']}');
    }
    isItemsMenuFetched = true;
    update();
  }

  List<String> categoriesNameList = ['all_categories'.tr];
  List categoriesIdsList = ['0'];
  List selectedCategoriesIdsList = [];
  bool isCategoriesFetched = false;
  String selectedCategoryId = '0';
  TextEditingController categoryController = TextEditingController();

  setSelectedCategoryId(String newVal) {
    selectedCategoryId = newVal;
    selectedCategoriesIdsList.add(newVal);
    update();
  }

  getCategoriesFromBack() async {
    categoriesNameList = ['all_categories'.tr];
    categoryController.text = categoriesNameList[0];
    categoriesIdsList = ['0'];
    isCategoriesFetched = false;
    selectedCategoryId = '0';
    selectedCategoriesIdsList = [];
    // update();
    var p = await getCategories('');
    for (var cat in p) {
      categoriesNameList.add('${cat['category_name']}');
      categoriesIdsList.add('${cat['id']}');
    }
    isCategoriesFetched = true;
    update();
  }

  // List parentsGroupsList=[];
  // List<List<String>> groupsList=[];
  // List<List<String>> groupsIdsList=[];
  List groupsList = [];
  bool isGroupsFetched = false;
  List<List<String>> childGroupsCodes = [];
  List<List<String>> childGroupsCodesAndNames = [];
  List<List<String>> childGroupsNames = [];
  List<List<String>> groupsMenus = [];
  List<List<int>> groupsIds = [];
  List<int> selectedGroupsIds = [];
  List<List<String>> selectedGroupsNamesForShow = [];
  List<List<String>> selectedGroupsCodesForShow = [];
  List<List<String>> selectedGroupsCodesAndNamesForShow = [];
  List<List<int>> selectedGroupsIdsForShow = [];
  List<TextEditingController> textEditingControllerForGroups = [];
  setSelectedGroupsIds(List<int> newList) {
    selectedGroupsIds = newList;
    update();
  }

  getBranchForChildren(List list, int topFatherIndex) {
    for (int i = 0; i < list.length; i++) {
      if (list[i].containsKey('children')) {
        //todo remove
        if ('${list[i]['children']}' == '[]') {
          if (!childGroupsCodes[topFatherIndex].contains(list[i]['code'])) {
            childGroupsCodes[topFatherIndex].add(list[i]['code']);
            childGroupsNames[topFatherIndex].add(list[i]['name']);
            childGroupsCodesAndNames[topFatherIndex]
                .add('${list[i]['code']}      ${list[i]['name']}');
            groupsIds[topFatherIndex].add(list[i]['id']);
          }
        } else {
          getBranchForChildren(list[i]['children'], topFatherIndex);
        }
      }
    }
  }

  getGroupsFromBack() async {
    groupsList = [];
    childGroupsCodes = [];
    childGroupsCodesAndNames = [];
    childGroupsNames = [];
    groupsMenus = [];
    groupsIds = [];
    selectedGroupsIds = [];
    selectedGroupsNamesForShow = [];
    selectedGroupsCodesForShow = [];
    selectedGroupsCodesAndNamesForShow = [];
    selectedGroupsIdsForShow = [];
    textEditingControllerForGroups = [];
    isGroupsFetched = false;

    var p = await getGroups('');
    for (int i = 0; i < p.length; i++) {
      if (p[i]['parent_id'] == null) {
        groupsList.add(p[i]);
        childGroupsCodes.add([]);
        childGroupsNames.add([]);
        childGroupsCodesAndNames.add([]);
        groupsIds.add([]);
        selectedGroupsNamesForShow.add([]);
        selectedGroupsCodesForShow.add([]);
        selectedGroupsCodesAndNamesForShow.add([]);
        selectedGroupsIdsForShow.add([]);
        textEditingControllerForGroups.add(TextEditingController());
        getBranchForChildren(p[i]['children'], i);
      }
    }
    isGroupsFetched = true;
    update();
  }

  setSelectedGroupsCodesAndNamesForShow(List<List<String>> newList) {
    selectedGroupsCodesAndNamesForShow = newList;
    update();
  }

  setSelectedGroupsCodesForShow(List<List<String>> newList) {
    selectedGroupsCodesForShow = newList;
    update();
  }

  setSelectedGroupsIdsForShow(List<List<int>> newList) {
    selectedGroupsIdsForShow = newList;
    update();
  }

  addIdToSelectedGroupsIdsList(int id) {
    selectedGroupsIds.add(id);
    update();
  }

  addSelectedGroupsNamesForShow(List<String> newList, int index) {
    selectedGroupsNamesForShow[index] = newList;
    update();
  }

  addSelectedGroupsCodesForShow(List<String> newList, int index) {
    selectedGroupsCodesForShow[index] = newList;
    update();
  }

  addSelectedGroupsCodesAndNamesForShow(List<String> newList, int index) {
    selectedGroupsCodesAndNamesForShow[index] = newList;
    update();
  }

  addSelectedGroupsIdsForShow(List<int> newList, int index) {
    selectedGroupsIdsForShow[index] = newList;
    update();
  }

  setSelectedGroupsNamesForShow(List<List<String>> newList) {
    selectedGroupsNamesForShow = newList;
    update();
  }

  List<TextEditingController> physicalQtyControllersList = [];
  List<double> difference = [];
  List<double> physicalCost = [];
  List<double> theoreticalCost = [];
  List<double> quantities = [];
  List<QtyInDefaultPackaging> qtyInDefaultPackagingList=[];
  List<InventoryItem> inventoryData = [];
  bool isInventoryDataFetched=true;
  getInventoryDataFromBack() async {
    isInventoryDataFetched=false;
    inventoryData = [];
    physicalQtyControllersList = [];
    difference = [];
    quantities = [];
    physicalCost = [];
    theoreticalCost = [];
    var res = await getInventoryData(selectedItemId, selectedWarehouseId,
        selectedCategoriesIdsList, selectedGroupsIds);
    if (res['success'] == true) {
      res['data'].sort((a, b) {
        String nameA = (a['item_name'] ?? '').toString().toLowerCase();
        String nameB = (b['item_name'] ?? '').toString().toLowerCase();
        return nameA.compareTo(nameB);
      });
      inventoryData=res['data']
          .map<InventoryItem>((e)=>InventoryItem.fromJson(e)).toList();
      for (int i = 0; i < res['data'].length; i++) {
        physicalQtyControllersList.add(TextEditingController());
        difference.add(0.0);
        physicalCost.add(0.0);
        for(int j=0;j<res['data'][i]['warehouses'].length;j++){
          if('${res['data'][i]['warehouses'][j]['id']}'==selectedWarehouseId){
            qtyInDefaultPackagingList.add(QtyInDefaultPackaging.fromJson(res['data'][i]['warehouses'][j]['qty_in_default_packaging']));
            quantities.add(double.parse(res['data'][i]['warehouses'][j]['qty_on_hand']));
          }
        }
        theoreticalCost.add(double.parse('${res['data'][i]['unitCost']??0.0*quantities[i]}'));
      }
      isInventoryDataFetched=true;
    }
    update();
  }

  setDifference(int index,double val){
      difference[index] = val;
      update();
  }
  setPhysicalCost(int index,double val){
    physicalCost[index] = val;
      update();
  }



  //counting form
  bool isPrintWithQtyChecked = true;
  int selectedValueForPackaging = 1;


  setIsPrintWithQtyChecked(bool val){
    isPrintWithQtyChecked = val;
    update();
  }

  setSelectedValue(int val){
    selectedValueForPackaging = val;
    update();
  }

  setInventoryData(List<InventoryItem> newInventoryData){
    inventoryData = newInventoryData;
    update();
  }
}
