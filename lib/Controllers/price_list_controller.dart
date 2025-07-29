import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../Backend/CategoriesBackend/get_categories.dart';
import '../../Backend/GroupsBackend/get_groups.dart';
import '../../Backend/PriceListBackend/get_prices_lists.dart';
import '../../Backend/ProductsBackend/get_products.dart';

class PriceListController extends GetxController {
  bool isAddNewPriceListClicked = false;
  setIsAddNewPriceListClicked(bool val) {
    isAddNewPriceListClicked = val;
    update();
  }

  int selectedTabIndex = 0;
  setSelectedTabIndex(int val) {
    selectedTabIndex = val;
    update();
  }

  TextEditingController codeController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController adjustmentPercentageController = TextEditingController();
  TextEditingController currencyController = TextEditingController();
  TextEditingController roundMethodController = TextEditingController();
  TextEditingController roundValueController = TextEditingController();
  TextEditingController methodController = TextEditingController();
  TextEditingController commissionsPaymentController = TextEditingController();
  TextEditingController derivedPriceListController = TextEditingController();
  String selectedCommissionsPayment = 'global percentage';
  String selectedMethod = 'MINUS';
  String selectedRoundingMethod = 'up';
  bool isVatInclusivePricesChecked = false;
  bool isDerivedPricesChecked = false;
  bool isPricesListFetched = false;
  int selectedDisplayModeRadio = 1;
  List<String> priceListsNames = [];
  List<String> priceListsIds = [];
  List<String> priceListsCods = [];
  String selectedAnotherPriceListName = '';
  String selectedAnotherPriceListId = '';
  String selectedAnotherPriceListCode = '';
  String selectedCurrencyName = '';
  String selectedCurrencyId = '';
  String selectedCurrencySymbol = '';

  List priceLists = [
    // {'code': 'STANDARD', 'name': 'Standard Price List'},
  ];

  String selectedPriceListIdForUpdate = '';
  Map selectedPriceListObjectForUpdate = {};
  setSelectedPriceListObjectForUpdate(Map map) {
    selectedPriceListObjectForUpdate = map;
    update();
  }

  setSelectedPriceListForUpdate(String val) {
    selectedPriceListIdForUpdate = val;
    update();
  }

  initialValues() {
    selectedTabIndex=0;
    selectedPriceListIdForUpdate = '';
    isAddNewPriceListClicked = false;
    selectedMethod = 'MINUS';
    methodController.text = 'MINUS';
    codeController.clear();
    nameController.clear();
    currencyController.clear();
    adjustmentPercentageController.text = '0';
    roundValueController.text = '0';
    roundMethodController.text = 'up';
    selectedCommissionsPayment = 'global percentage';
    commissionsPaymentController.text = 'global percentage';
    selectedRoundingMethod = 'up';
    isVatInclusivePricesChecked = false;
    isDerivedPricesChecked = false;
    selectedDisplayModeRadio = 1;
    derivedPriceListController.clear();
    selectedAnotherPriceListName = '';
    selectedAnotherPriceListId = '';
    selectedAnotherPriceListCode = '';
    selectedCurrencyName = '';
    selectedCurrencyId = '';
    selectedCurrencySymbol = '';
    selectedGroupsIds = [];
    selectedGroupsNamesForShow = [];
    selectedGroupsCodesForShow = [];
    selectedGroupsCodesAndNamesForShow = [];
    selectedGroupsIdsForShow = [];
    selectedCategoriesIdsList = [];
    getGroupsFromBack();
    selectedItemId = '0';
    itemsController.text = 'All Items';
    categoryController.text = categoriesNameList[0];
  }


  resetValues() {
    selectedPriceListIdForUpdate = '';
    isAddNewPriceListClicked = false;
    selectedMethod = 'MINUS';
    methodController.text = 'MINUS';
    codeController.clear();
    nameController.clear();
    currencyController.clear();
    adjustmentPercentageController.text = '0';
    roundValueController.text = '0';
    roundMethodController.text = 'up';
    selectedCommissionsPayment = 'global percentage';
    commissionsPaymentController.text = 'global percentage';
    selectedRoundingMethod = 'up';
    isVatInclusivePricesChecked = false;
    isDerivedPricesChecked = false;
    selectedDisplayModeRadio = 1;
    derivedPriceListController.clear();
    selectedAnotherPriceListName = '';
    selectedAnotherPriceListId = '';
    selectedAnotherPriceListCode = '';
    selectedCurrencyName = '';
    selectedCurrencyId = '';
    selectedCurrencySymbol = '';
    selectedGroupsIds = [];
    selectedGroupsNamesForShow = [];
    selectedGroupsCodesForShow = [];
    selectedGroupsCodesAndNamesForShow = [];
    selectedGroupsIdsForShow = [];
    selectedCategoriesIdsList = [];
    getGroupsFromBack();
    selectedItemId = '0';
    itemsController.text = 'All Items';
    categoryController.text = categoriesNameList[0];
    update();
  }


  setValues(Map info) {
    nameController.text = info['title'];
    codeController.text = info['code'];
    selectedPriceListIdForUpdate = '${info['id']}';
    isAddNewPriceListClicked = false;
    selectedMethod = info['operation']=='minus'?'MINUS':'PLUS';
    methodController.text = selectedMethod;
    currencyController.text=info['convertToCurrencyId']!=null?info['convertToCurrencyId']['name']:'';
    adjustmentPercentageController.text = '${info['adjustmentPercentage']??'0'}';
    roundValueController.text = '${info['roundingPrecision']}';
    roundMethodController.text = info['roundingMethod'];
    selectedCommissionsPayment = 'global percentage';
    commissionsPaymentController.text = 'global percentage';
    selectedRoundingMethod = info['roundingMethod'];
    isVatInclusivePricesChecked =info['vatInclusivePrices']==1? true:false;
    isDerivedPricesChecked = info['derivedPrices']==1? true:false;
    selectedDisplayModeRadio = info['transactionDisplayMode']=='net'?1:2;
    selectedAnotherPriceListId = info['pricelistId']!=null?'${info['pricelistId']??''}':'';
    var index=priceListsIds.indexOf(selectedAnotherPriceListId);
    selectedAnotherPriceListName = info['pricelistId']!=null?priceListsNames[index]:'';
    selectedAnotherPriceListCode =info['pricelistId']!=null?priceListsCods[index]: '';
    derivedPriceListController.text =info['pricelistId']!=null?priceListsCods[index]: '';
    selectedCurrencyName = info['convertToCurrencyId']!=null?info['convertToCurrencyId']['name']:'';
    selectedCurrencyId = info['convertToCurrencyId']!=null?'${info['convertToCurrencyId']['id']}':'';
    selectedCurrencySymbol = info['convertToCurrencyId']!=null?info['convertToCurrencyId']['symbol']:'';
    // selectedGroupsIds = [];
    // selectedGroupsNamesForShow = [];
    // selectedGroupsCodesForShow = [];
    // selectedGroupsCodesAndNamesForShow = [];
    // selectedGroupsIdsForShow = [];
    // selectedCategoriesIdsList = [];
    // selectedItemId = '0';
    // itemsController.text = 'All Items';
    // categoryController.text = categoriesNameList[0];
    update();
  }


  getAllPricesListFromBack() async {
    priceLists=[];
    priceListsNames = [];
    priceListsIds = [];
    priceListsCods = [];
    isPricesListFetched = false;
    var p = await getPricesLists();
    if ('$p' != '[]') {
      priceLists.addAll(p);
      for (var item in p) {
        priceListsNames.add('${item['title']}');
        priceListsIds.add('${item['id']}');
        priceListsCods.add('${item['code']}');
      }
      isPricesListFetched = true;
      update();
    }
  }

  setSelectedRadio(int val) {
    selectedDisplayModeRadio = val;
    update();
  }

  setSelectedCommissionsPayment(String val) {
    selectedCommissionsPayment = val;
    update();
  }

  setSelectedMethod(String val) {
    selectedMethod = val;
    update();
  }

  setSelectedRoundingMethod(String val) {
    selectedRoundingMethod = val;
    update();
  }

  setSelectedAnotherPriceList(String id, String name, String code) {

    selectedAnotherPriceListId = id;
    selectedAnotherPriceListName = name;
    selectedAnotherPriceListCode = code;
    update();
  }

  setIs1Checked(bool val) {
    isVatInclusivePricesChecked = val;
    update();
  }

  setIs2Checked(bool val) {
    isDerivedPricesChecked = val;
    update();
  }

  setCurrency(String id, String name, String symbol) {
    selectedCurrencyName = name;
    selectedCurrencyId = id;
    selectedCurrencySymbol = symbol;
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
    var p = await getAllProducts('', '', '', -1);
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
            childGroupsCodesAndNames[topFatherIndex].add(
              '${list[i]['code']}      ${list[i]['name']}',
            );
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
}
