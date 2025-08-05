import 'dart:typed_data';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ProductsBackend/delete_image.dart';
import 'package:rooster_app/Screens/Products/CreateProductDialog/procurement_tab_content.dart';
import 'package:rooster_app/Screens/Products/products_page.dart';
import 'package:rooster_app/const/urls.dart';
import '../Backend/ProductsBackend/get_item_quantities.dart';
import '../Backend/ProductsBackend/get_product_create_info.dart';
import '../Backend/ProductsBackend/get_products.dart';
import '../Backend/ProductsBackend/post_product_images.dart';
import '../Backend/ProductsBackend/store_product.dart';
import '../Backend/ProductsBackend/update_item.dart';
import '../Screens/Products/CreateProductDialog/general_tab_content.dart';
import '../Screens/Products/CreateProductDialog/grouping_tab_content.dart';
import '../Screens/Products/CreateProductDialog/pos_tab_content.dart';
import '../Screens/Products/CreateProductDialog/pricing_tab_content.dart';
import '../Screens/Products/CreateProductDialog/quantities_tab_content.dart';
import '../Screens/Products/CreateProductDialog/shipping_tab_content.dart';
import '../Widgets/custom_snak_bar.dart';
import '../Widgets/loading_dialog.dart';
import '../Widgets/reusable_photo_card_in_update_product.dart';
import 'home_controller.dart';

class ProductController extends GetxController {
  List itemGroups = [];
  List groupsList = [];
  List<TextEditingController> textEditingControllerForGroups = [];
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
  setSelectedGroupsIds(List<int> newList) {
    selectedGroupsIds = newList;
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

  reformatGroups() {
    for (int i = 0; i < groupsList.length; i++) {
      childGroupsCodes.add([]);
      childGroupsNames.add([]);
      childGroupsCodesAndNames.add([]);
      groupsIds.add([]);
      selectedGroupsNamesForShow.add([]);
      selectedGroupsCodesForShow.add([]);
      selectedGroupsCodesAndNamesForShow.add([]);
      selectedGroupsIdsForShow.add([]);
      textEditingControllerForGroups.add(TextEditingController());
      getBranchForChildren(groupsList[i]['children'], i);
    }
    if (isItUpdateProduct) {
      reformatGroupsForUpdate();
    }
    // getMenuGroupsNames();
  }

  reformatGroupsForUpdate() {
    for (int i = 0; i < childGroupsCodes.length; i++) {
      for (int j = 0; j < childGroupsCodes[i].length; j++) {
        for (int k = 0; k < itemGroups.length; k++) {
          if (itemGroups[k]['code'] == childGroupsCodes[i][j]) {
            // var index = groupBranches[i].indexOf(itemGroups[k]['show_name']);
            addIdToSelectedGroupsIdsList(itemGroups[k]['id']);
            addSelectedGroupsIdsForShow([itemGroups[k]['id']], i);
            addSelectedGroupsNamesForShow([itemGroups[k]['name']], i);
            addSelectedGroupsCodesForShow([itemGroups[k]['code']], i);
            addSelectedGroupsCodesForShow([itemGroups[k]['code']], i);
            break;
          }
        }
      }
    }
  }

  // getMenuGroupsNames() {
  //   for (int i = 0; i < groupsList.length; i++) {
  //     groupsMenus.add([]);
  //     for (int j = 0; j < childGroupsCodes.length; j++) {
  //       if (childGroupsCodes[j][0] == '${groupsList[i]['code']}'&& childGroupsCodes[j].length>1) {
  //         groupBranches[j].removeAt(0);
  //         groupsMenus[i].add(convertListToString(groupBranches[j]));
  //       }
  //     }
  //   }
  // }

  final isGrid = true.obs;
  toggleIsGridValue() {
    isGrid.value = !isGrid.value;
    update();
  }

  bool isItUpdateProduct = false;
  setIsItUpdateProduct(bool val) {
    isItUpdateProduct = val;
    update();
  }

  bool isProductsPageIsLastPage = false;
  setProductsPageIsLastPage(bool val) {
    isProductsPageIsLastPage = val;
    update();
  }


  int selectedTabIndex = 0;
  setSelectedTabIndex(int val) {
    selectedTabIndex = val;
    update();
  }

  List altCodesList = [
    {
      'print_on_invoice': true,
      'creation_date': '01/06/2023',
      'type': 'code',
      'code': '',
    },
  ];
  addToAltCodesList(Map p) {
    altCodesList.add(p);
    update();
  }

  removeFromAltCodesList(int index) {
    altCodesList.removeAt(index);
    update();
  }

  resetAltCodesList() {
    altCodesList = [
      {
        'print_on_invoice': true,
        'creation_date': '',
        'type': 'code',
        'code': '',
      },
    ];
    update();
  }

  changePrintCheckInAltCodes(bool value, int index) {
    altCodesList[index]['print_on_invoice'] = value;
    update();
  }

  changeCodeInAltCodes(String value, int index) {
    altCodesList[index]['code'] = value;
    update();
  }

  bool isProductsInfoFetched = false;
  Map data = {};
  List<String> itemTypesNames = [];
  List itemTypesIds = [];
  String selectedItemTypesId = '1';
  List<String> taxationGroupsNames = [];
  List taxationGroupsIds = [];
  String selectedTaxationGroupsId = '1';
  List<String> categoriesNames = [];
  List categoriesIds = [];
  String selectedCategoryId = '1';
  // int selectedCategoryIndex=0;
  List<String> currenciesNames = [];
  List currenciesIds = [];
  String selectedCurrencyId = '';
  String selectedShownCurrencyId = '';
  String selectedPriceCurrencyId = '';
  List<String> packagesNames = [];
  List packagesIds = [];
  String selectedPackageId = '1';
  String selectedDefaultTransactionPackageId = '1';
  List<String> subrefsNames = [''];
  List subrefsIds = [0];
  int selectedSubrefsId = 1;

  // List<Widget> photosWidgetsList = [];
  Map<int, Widget> photosWidgetsMap = {};
  double photosListWidth = 0;
  List photosFilesList = [];
  List imagesUrlsToRemove = [];

  String totalQty = '';
  List warehousesList = [];

  // addImageToPhotosWidgetsList(Widget widget) {
  //   photosWidgetsList.add(widget);
  //   update();
  // }

  addImageToPhotosWidgetsMap(int index, Widget widget) {
    photosWidgetsMap[index] = widget;
    counterForImages++;
    update();
  }

  addImageToPhotosFilesList(Uint8List imageFile) {
    photosFilesList.add(imageFile);
    update();
  }

  removeImageFromPhotosFilesList(Uint8List imageFile) {
    photosFilesList.remove(imageFile);
    update();
  }

  resetPhotosFilesList() {
    photosFilesList = [];
    update();
  }

  addImageToImagesUrlsToRemoveList(String imageUrl) {
    imagesUrlsToRemove.add(imageUrl);
    update();
  }

  removeImageFromImagesUrlsToRemoveList(String imageUrl) {
    imagesUrlsToRemove.remove(imageUrl);
    update();
  }

  resetImagesUrlsToRemoveList() {
    imagesUrlsToRemove = [];
    update();
  }

  setPhotosListWidth(double val) {
    photosListWidth = val;
    update();
  }

  // resetPhotosWidgetsList() {
  //   photosWidgetsList = [];
  //   update();
  // }

  resetPhotosWidgetsMap() {
    photosWidgetsMap = {};
    update();
  }

  getFieldsForCreateProductFromBack() async {
    isProductsInfoFetched = false;
    counterForImages = 1;
    resetAltCodesList();
    data = {};
    groupsList = [];
    childGroupsCodes = [];
    childGroupsNames = [];
    childGroupsCodesAndNames = [];
    groupsIds = [];
    selectedGroupsIdsForShow = [];
    selectedGroupsNamesForShow = [];
    selectedGroupsCodesForShow = [];
    selectedGroupsCodesAndNamesForShow = [];
    textEditingControllerForGroups = [];
    selectedGroupsIds = [];
    photosFilesList = [];
    imagesUrlsToRemove = [];
    photosListWidth = 0;
    // photosWidgetsList = [];
    photosWidgetsMap = {};
    itemTypesNames = [];
    itemTypesIds = [];
    taxationGroupsNames = [];
    categoriesNames = [];
    taxationGroupsIds = [];
    categoriesIds = [];
    currenciesNames = [];
    currenciesIds = [];
    packagesNames = [];
    packagesIds = [];
    subrefsNames = [''];
    subrefsIds = [0];
    selectedSubrefsId = 1;
    selectedPackageId = '1';
    selectedDefaultTransactionPackageId = '1';
    selectedCurrencyId = '';
    selectedShownCurrencyId = '';
    selectedPriceCurrencyId = '';
    selectedTaxationGroupsId = '1';
    selectedCategoryId = '1';
    selectedItemTypesId = '1';
    isCanBeSoldChecked = false;
    isCanBePurchasedChecked = false;
    isWarrantyChecked = false;
    isDiscontinuedChecked = false;
    isBlockedChecked = false;
    packageController.clear();
    defaultTransactionPackageController.clear();
    // update();
    var p = await getFieldsForCreateProduct();
    if ('$p' != '[]') {
      data.addAll(p);
      for (var item in p['itemTypes']) {
        itemTypesNames.add('${item['name']}');
        itemTypesIds.add('${item['id']}');
        update();
      }
      for (var item in p['taxationGroups']) {
        taxationGroupsNames.add('${item['code']}');
        taxationGroupsIds.add('${item['id']}');
        update();
      }
      for (var item in p['categories']) {
        categoriesNames.add('${item['name']}');
        categoriesIds.add('${item['id']}');
        update();
      }
      // for (var item in p['itemGroups']) {
      //   groupsList=p['itemGroups'];
      //   // categoriesNames.add('${item['name']}');
      //   // categoriesIds.add('${item['id']}');
      //   update();
      // }
      for (var item in p['currencies']) {
        currenciesNames.add('${item['name']}');
        currenciesIds.add('${item['id']}');
        update();
      }
      for (var item in p['packages']) {
        packagesNames.add('${item['name']}');
        packagesIds.add('${item['id']}');
        update();
      }
      for (var item in p['subrefs']) {
        subrefsNames.add('${item['name']}');
        subrefsIds.add(item['id']);
        update();
      }
      if (codeController.text.isEmpty) {
        codeController.text = p['mainCode'];
      }
      groupsList = p['itemGroups'];
      reformatGroups();
      if (selectedItemTypesId == '1') {
        selectedItemTypesId = '${itemTypesIds[0]}';
      }
      if (selectedTaxationGroupsId == '1') {
        selectedTaxationGroupsId = '${taxationGroupsIds[0]}';
      }
      if (selectedCategoryId == '1') {
        selectedCategoryId = '${categoriesIds[0]}';
      }
      if (selectedCurrencyId.isEmpty) {
        selectedCurrencyId = currenciesIds[0];
      }
      if (selectedShownCurrencyId.isEmpty) {
        selectedShownCurrencyId = currenciesIds[0];
      }
      if (selectedPriceCurrencyId.isEmpty) {
        selectedPriceCurrencyId = currenciesIds[0];
      }
      if (selectedShownCurrencyId.isEmpty) {
        selectedShownCurrencyId = currenciesIds[0];
      }
      // defaultTransactionPackageController.text =packagesNames[int.parse(selectedPackageId)-1];
      if (selectedDefaultTransactionPackageId == '1') {
        selectedDefaultTransactionPackageId = packagesIds[0];
      }
      // packageController.text =packagesNames[int.parse(selectedPackageId)-1];
      if (selectedPackageId == '1') {
        selectedPackageId = packagesIds[0];
      }
      isProductsInfoFetched = true;
      update();
    }
  }

  setSelectedItemTypesId(String newVal) {
    selectedItemTypesId = newVal;
    update();
  }

  setSelectedTaxationGroupsId(String newVal) {
    selectedTaxationGroupsId = newVal;
    update();
  }

  setSelectedCategoryId(String newVal) {
    selectedCategoryId = newVal;
    update();
  }

  setSelectedCurrencyId(String newVal) {
    selectedCurrencyId = newVal;
    update();
  }

  setSelectedShownCurrencyId(String newVal) {
    selectedShownCurrencyId = newVal;
    update();
  }

  setSelectedPriceCurrencyId(String newVal) {
    selectedPriceCurrencyId = newVal;
    update();
  }

  setSelectedPackageId(String newVal) {
    selectedPackageId = newVal;
    update();
  }

  setSelectedDefaultTransactionPackageId(String newVal) {
    selectedDefaultTransactionPackageId = newVal;
    update();
  }

  setSelectedSubrefsId(int newVal) {
    selectedSubrefsId = newVal;
    update();
  }

  bool isCanBeSoldChecked = false;
  bool isCanBePurchasedChecked = false;
  bool isWarrantyChecked = false;
  bool isDiscontinuedChecked = false;
  bool isBlockedChecked = false;
  bool isActiveInPosChecked = false;
  setIsCanBeSoldChecked(bool newVal) {
    isCanBeSoldChecked = newVal;
    update();
  }

  setIsCanBePurchasedChecked(bool newVal) {
    isCanBePurchasedChecked = newVal;
    update();
  }

  setIsWarrantyChecked(bool newVal) {
    isWarrantyChecked = newVal;
    update();
  }

  setIsDiscontinuedChecked(bool newVal) {
    isDiscontinuedChecked = newVal;
    update();
  }

  setIsBlockedChecked(bool newVal) {
    isBlockedChecked = newVal;
    update();
  }

  setIsActiveInPosChecked(bool newVal) {
    isActiveInPosChecked = newVal;
    update();
  }

  clearData() {
    selectedTabIndex = 0;
    groupsIds = [];
    selectedGroupsIdsForShow = [];
    selectedGroupsNamesForShow = [];
    selectedGroupsCodesForShow = [];
    selectedGroupsCodesAndNamesForShow = [];
    textEditingControllerForGroups = [];
    isProductsInfoFetched = false;
    counterForImages = 1;
    update();
    data = {};
    update();
    photosFilesList = [];
    imagesUrlsToRemove = [];
    update();
    itemTypesNames = [];
    update();
    itemTypesIds = [];
    update();
    taxationGroupsNames = [];
    update();
    categoriesNames = [];
    update();
    taxationGroupsIds = [];
    update();
    categoriesIds = [];
    update();
    currenciesNames = [];
    update();
    currenciesIds = [];
    update();
    packagesNames = [];
    update();
    packagesIds = [];
    update();
    subrefsNames = [''];
    update();
    subrefsIds = [0];
    update();
    selectedSubrefsId = 1;
    update();
    selectedPackageId = '1';
    update();
    selectedDefaultTransactionPackageId = '1';
    update();
    selectedTaxationGroupsId = '1';
    update();
    selectedCategoryId = '1';
    update();
    selectedItemTypesId = '1';
    update();
    isCanBeSoldChecked = false;
    update();
    isCanBePurchasedChecked = false;
    update();
    isWarrantyChecked = false;
    update();
    isDiscontinuedChecked = false;
    update();
    isBlockedChecked = false;
    quantityController.clear();
    itemNameController.clear();
    isActiveInPosChecked = false;
    typeController.clear();
    taxationController.clear();
    categoryController.clear();
    // resetPhotosWidgetsList();
    resetPhotosWidgetsMap();
    resetPhotosFilesList();
    resetImagesUrlsToRemoveList();
    setPhotosListWidth(0);
    dateController.clear();
    codeController.clear();
    mainDescriptionController.clear();
    shortDescriptionController.clear();
    secondLanguageController.clear();
    setSelectedSubrefsId(1);
    setIsCanBeSoldChecked(false);
    setIsCanBePurchasedChecked(false);
    setIsWarrantyChecked(false);
    setIsDiscontinuedChecked(false);
    setIsBlockedChecked(false);
    // setSelectedItemTypesId('${itemTypesIds[0]}');
    // setSelectedTaxationGroupsId('${taxationGroupsIds[0]}');
    // setSelectedCategoryId('${categoriesIds[0]}');
    unitCostController.text = '0';
    decimalCostController.text = '0';
    costCurrencyController.clear();
    unitPriceController.text = '0';
    decimalPriceController.text = '0';
    priceCurrencyController.clear();
    discLineLimitController.clear();
    unitsSuffix.clear();
    setsSuffix.clear();
    setsQuantity.clear();
    supersetSuffix.clear();
    paletteSuffix.clear();
    containerSuffix.clear();
    unitsQuantity.clear();
    supersetQuantity.clear();
    paletteQuantity.clear();
    containerQuantity.clear();
    decimalQuantityController.text = '0';
    update();
  }

  final productsList = [].obs;
  // final isProductsFetched = false.obs;
  final isLoading = false.obs;
  var hasMore = true;
  final currentPage=1.obs;

  final selectedCategoryIdInProductPage = '0'.obs;
  getAllProductsFromBack() async {
    if(isLoading.value || !hasMore) return;
    isLoading.value=true;
    var p = await getAllProducts(
      searchControllerInProductsPage.text,
      selectedCategoryIdInProductPage.value == '0'
          ? ''
          : selectedCategoryIdInProductPage.value,
      '',
        currentPage.value
    );
    if('$p'!='[]'){
      productsList.addAll(p);
      currentPage.value=currentPage.value+1;
    }else{
      hasMore=false;
    }
    isLoading.value=false;

    // productsList.addAll(p);
    // isProductsFetched.value = true;
    update();
  }

  getAllProductsFromBackWithSearch() async {
    isLoading.value=true;
    var p = await getAllProducts(
        searchControllerInProductsPage.text,
        selectedCategoryIdInProductPage.value == '0'
            ? ''
            : selectedCategoryIdInProductPage.value,
        '',
        -1
    );
    if('$p'!='[]'){
      productsList.addAll(p);
    }
    isLoading.value=false;

    // productsList.addAll(p);
    // isProductsFetched.value = true;
    update();
  }


  nextPage(){
    currentPage.value++;
    getAllProductsFromBack();
  }
  previousPage(){
    if(currentPage.value>1){
      currentPage.value--;
      getAllProductsFromBack();
    }
  }

  discardInGeneral() {
    typeController.clear();
    taxationController.clear();
    // categoryController.clear();
    // resetPhotosWidgetsList();
    resetPhotosWidgetsMap();
    resetPhotosFilesList();
    resetImagesUrlsToRemoveList();
    setPhotosListWidth(0);
    dateController.clear();
    codeController.clear();
    mainDescriptionController.clear();
    shortDescriptionController.clear();
    secondLanguageController.clear();
    setSelectedSubrefsId(1);
    setIsCanBeSoldChecked(false);
    setIsCanBePurchasedChecked(false);
    setIsWarrantyChecked(false);
    setIsDiscontinuedChecked(false);
    setIsBlockedChecked(false);
    setSelectedItemTypesId('${itemTypesIds[0]}');
    setSelectedTaxationGroupsId('${taxationGroupsIds[0]}');
    setSelectedCategoryId('${categoriesIds[0]}');
    update();
  }

  discardProcurement() {
    unitCostController.text = '0';
    decimalCostController.text = '0';
    costCurrencyController.clear();
    setSelectedCurrencyId(currenciesIds[0]);
    update();
  }

  discardPricing() {
    unitPriceController.text = '0';
    decimalPriceController.text = '0';
    priceCurrencyController.clear();
    discLineLimitController.clear();
    setSelectedCurrencyId(currenciesIds[0]);
    update();
  }

  discardShipping() {
    unitsSuffix.clear();
    setsSuffix.clear();
    supersetSuffix.clear();
    paletteSuffix.clear();
    containerSuffix.clear();
    unitsQuantity.clear();
    supersetQuantity.clear();
    paletteQuantity.clear();
    containerQuantity.clear();
    decimalQuantityController.text = '0';
    // packageController.clear();
    // defaultTransactionPackageController.clear();
  }

  discardPos() {
    itemNameController.clear();
    isActiveInPosChecked = false;
    showProductCurrencyController.clear();
    setSelectedShownCurrencyId(currenciesIds[0]);
    update();
  }

  String unitsSuffixText = '';
  String setsSuffixText = '';
  String supersetsSuffixText = '';
  String paletteSuffixText = '';
  String containerSuffixText = '';

  setUnitsSuffixText(String val) {
    unitsSuffixText = val;
    update();
  }

  setSetsSuffixText(String val) {
    setsSuffixText = val;
    update();
  }

  setSupersetsSuffixText(String val) {
    supersetsSuffixText = val;
    update();
  }

  setPaletteSuffixText(String val) {
    paletteSuffixText = val;
    update();
  }

  setContainerSuffixText(String val) {
    containerSuffixText = val;
    update();
  }

  final HomeController homeController = Get.find();
  saveAndSendCreateProductOrder(context) async {
    showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => const AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            elevation: 0,
            content: LoadingDialog(),
          ),
    );
    var res = await storeProduct(
      selectedGroupsIds,
      selectedDefaultTransactionPackageId,
      int.parse(selectedShownCurrencyId),
      selectedCategoryId,
      isBlockedChecked ? 1 : 0,
      itemNameController.text,
      isActiveInPosChecked ? '1' : '0',
      1,
      int.parse(selectedItemTypesId),
      codeController.text,
      int.parse(selectedTaxationGroupsId),
      'barcode2w5',
      '43456e35',
      1,
      mainDescriptionController.text,
      shortDescriptionController.text,
      secondLanguageController.text,
      selectedSubrefsId,
      isCanBeSoldChecked ? 1 : 0,
      isCanBePurchasedChecked ? 1 : 0,
      isWarrantyChecked ? 1 : 0,
      dateController.text,
      unitCostController.text != '' ? double.parse(unitCostController.text) : 0,
      decimalCostController.text != ''
          ? int.parse(decimalCostController.text)
          : 0,
      int.parse(selectedCurrencyId),
      int.parse(selectedPriceCurrencyId),
      quantityController.text,
      // quantityController.text != ''
      //     ? int.parse(quantityController.text)
      //     : 0,
      unitPriceController.text != ''
          ? double.parse(unitPriceController.text)
          : 0,
      decimalPriceController.text != ''
          ? int.parse(decimalPriceController.text)
          : 0,
      discLineLimitController.text != ''
          ? double.parse(discLineLimitController.text)
          : 0,
      int.parse(selectedPackageId),
      unitsSuffix.text,
      unitsQuantity.text,
      setsSuffix.text,
      setsQuantity.text,
      supersetSuffix.text,
      supersetQuantity.text,
      paletteSuffix.text,
      paletteQuantity.text,
      containerSuffix.text,
      containerQuantity.text,
      decimalQuantityController.text != ''
          ? int.parse(decimalQuantityController.text)
          : 0,
      [1],
      isDiscontinuedChecked ? 1 : 0,
      altCodesList,
    );
    // if (res['success'] == true) {
    if (res['success'] == true) {
      if (photosFilesList.isNotEmpty) {
        var p = await addImagesToProduct(
          '${res['data']['id']}',
          photosFilesList,
        );
        Get.back();
        if (p['success'] == true) {
          Get.back();
          CommonWidgets.snackBar('Success', res['message']);
          productsList.value=[];
          currentPage.value=1;
          getAllProductsFromBack();
          if(isProductsPageIsLastPage){
          homeController.selectedTab.value = 'items';}else{Get.back();}
        } else {
          CommonWidgets.snackBar('error', p['message']);
        }
      } else {
        productsList.value=[];
        currentPage.value=1;
        getAllProductsFromBack();
        Get.back();
        Get.back();
        CommonWidgets.snackBar('Success', res['message']);
        if(isProductsPageIsLastPage){
        homeController.selectedTab.value = 'items';}else{Get.back();}
      }
    } else {
      CommonWidgets.snackBar('error', res['message']);
    }
    update();
  }

  String oldQuantity = '';

  removeFromImagesList(int key) {
    photosWidgetsMap.remove(key);
    photosListWidth = photosListWidth - 130;
    update();
  }

  int counterForImages = 1;
  incCounter() {
    counterForImages++;
  }

  getQuantities()async{
    var res=await getQuantitiesOfProduct(selectedProductId.toString());
    if(res['success']==true){
        transactionQuantitiesList[2]['quantities']='${res['data']['salesOrderQuantities']} Pcs';
        transactionQuantitiesList[5]['quantities']='${res['data']['salesOrderQuantities']} Pcs';
        transactionQuantitiesList[1]['quantities']='${res['data']['qtyOwned']} Pcs';
    }
  }

  setAllValuesForUpdate(Map product) {
    counterForImages = 1;
    isProductsInfoFetched = false;
    data = {};
    photosFilesList = [];
    for (int i = 0; i < product['images'].length; i++) {
      // photosWidgetsList
      //     .add(ReusablePhotoCardInUpdateProduct(url: product['images'][i],func: (){
      //   removeFromImagesList(i);
      // },));
      var index = counterForImages;
      photosWidgetsMap[index] = ReusablePhotoCardInUpdateProduct(
        url: product['images'][i],
        func: () async {
          removeFromImagesList(index);
          addImageToImagesUrlsToRemoveList(product['images'][i]);
        },
      );
      incCounter();
      // File imageFile = File.fromUri(Uri.parse(product['images'][i]));
      // Uint8List bytes = imageFile.readAsBytesSync();
      // photosFilesList.add(ByteData.view(bytes.buffer));
    }
    photosListWidth = double.parse('${product['images'].length * 130}');
    itemTypesNames = [];
    itemTypesIds = [];
    taxationGroupsNames = [];
    categoriesNames = [];
    taxationGroupsIds = [];
    categoriesIds = [];
    currenciesNames = [];
    currenciesIds = [];
    packagesNames = [];
    packagesIds = [];
    subrefsNames = [''];
    subrefsIds = [0];
    warehousesList = product['warehouses'] ?? [];
    selectedCategoryId = '${product['totalQuantities'] ?? ''}';
    transactionQuantitiesList[0]['quantities'] =
        '${product['totalQuantities'] ?? ''} ${product['packageUnitName'] ?? ''}';
    // transactionQuantitiesList[1]['quantities'] =
    //     '${product['totalQuantities'] ?? ''} ${product['packageUnitName'] ?? ''}';
    selectedCategoryId = '${product['category']['id'] ?? '1'}';
    isCanBeSoldChecked = '${product['canBeSold'] ?? '0'}' == '0' ? false : true;
    isCanBePurchasedChecked =
        '${product['canBePurchased'] ?? '0'}' == '0' ? false : true;
    isWarrantyChecked = '${product['warranty'] ?? '0'}' == '0' ? false : true;
    isDiscontinuedChecked = '${product['active'] ?? '1'}' == '1' ? false : true;
    isBlockedChecked = '${product['isBlocked'] ?? '0'}' == '0' ? false : true;
    itemNameController.text = product['item_name'] ?? '';
    isActiveInPosChecked =
        '${product['showOnPos'] ?? '0'}' == '0' ? false : true;
    codeController.text = product['mainCode'] ?? '';
    mainDescriptionController.text = product['mainDescription'] ?? '';
    shortDescriptionController.text = product['shortDescription'] ?? '';
    secondLanguageController.text = product['secondLanguageDescription'] ?? '';
    dateController.text = product['lastAllowedPurchaseDate'] ?? '';
    quantityController.text = '';
    oldQuantity = '${product['current_quantity'] ?? ''}';
    unitCostController.text = '${product['unitCost'] ?? ''}';
    decimalCostController.text = '${product['decimalCost'] ?? ''}';
    unitPriceController.text = '${product['unitPrice'] ?? ''}';
    decimalPriceController.text = '${product['decimalPrice'] ?? ''}';
    discLineLimitController.text = '${product['lineDiscountLimit'] ?? ''}';
    selectedTaxationGroupsId = '${product['taxationGroup']['id'] ?? '1'}';
    taxationController.text = '${product['taxationGroup']['code'] ?? '1'}';
    selectedItemTypesId = '${product['itemType']['id'] ?? ''}';
    selectedSubrefsId = int.parse(
      product['subref_id'] != null
          ? '${product['subref_id']['id'] ?? '1'}'
          : '1',
    );
    selectedCurrencyId = '${product['currency']['id'] ?? '1'}';
    costCurrencyController.text = '${product['currency']['name'] ?? 'USD'}';
    selectedPriceCurrencyId = '${product['priceCurrency']['id'] ?? '1'}';
    priceCurrencyController.text =
        '${product['priceCurrency']['name'] ?? 'USD'}';
    selectedShownCurrencyId = '${product['posCurrency']['id'] ?? '1'}';
    showProductCurrencyController.text =
        '${product['posCurrency']['name'] ?? 'USD'}';
    selectedPackageId = '${product['packageType'] ?? '1'}';
    packageController.text = '${product['packageName'] ?? ''}';
    unitsSuffix.text = product['packageUnitName'] ?? '';
    unitsQuantity.text = '${product['packageUnitQuantity'] ?? ''}';
    setsSuffix.text = product['packageSetName'] ?? '';
    setsQuantity.text = '${product['packageSetQuantity'] ?? ''}';
    supersetSuffix.text = product['packageSupersetName'] ?? '';
    supersetQuantity.text = '${product['packageSupersetQuantity'] ?? ''}';
    paletteSuffix.text = product['packagePaletteName'] ?? '';
    paletteQuantity.text = '${product['packagePaletteQuantity'] ?? ''}';
    containerSuffix.text = product['packageContainerName'] ?? '';
    containerQuantity.text = '${product['packageContainerQuantity'] ?? ''}';
    selectedDefaultTransactionPackageId =
        '${product['defaultTransactionPackageType'] ?? '1'}';
    decimalQuantityController.text = '${product['decimalQuantity'] ?? ''}';
    selectedCategoryId = '${product['category']['id'] ?? ''}';
    categoryController.text = '${product['category']['category_name'] ?? ''}';
    typeController.text = '${product['itemType']['name'] ?? ''}';
    itemGroups = product['itemGroups'] ?? [];
    // reformatGroupsForUpdate();
    // altCodesList.add(product['barcode']);
    // altCodesList.add(product['alternativeCodes']);
    // altCodesList.add(product['supplierCodes']);
    for (int i = 0; i < product['barcode'].length; i++) {
      Map p = {
        'print_on_invoice':
            '${product['barcode'][i]['print_code'] ?? '0'}' == '0'
                ? false
                : true,
        'creation_date': '${product['barcode'][i]['created_at']}'.substring(
          0,
          10,
        ),
        'type': 'barcode',
        'code': product['barcode'][i]['code'],
      };
      altCodesList.add(p);
    }
    for (int i = 0; i < product['alternativeCodes'].length; i++) {
      Map p = {
        'print_on_invoice':
            '${product['alternativeCodes'][i]['print_code'] ?? '0'}' == '0'
                ? false
                : true,
        'creation_date': '${product['alternativeCodes'][i]['created_at']}'
            .substring(0, 10),
        'type': 'alternative_code',
        'code': product['alternativeCodes'][i]['code'],
      };
      altCodesList.add(p);
    }
    for (int i = 0; i < product['supplierCodes'].length; i++) {
      Map p = {
        'print_on_invoice':
            '${product['supplierCodes'][i]['print_code'] ?? '0'}' == '0'
                ? false
                : true,
        'creation_date': '${product['supplierCodes'][i]['created_at']}'
            .substring(0, 10),
        'type': 'supplier_code',
        'code': product['supplierCodes'][i]['code'],
      };
      altCodesList.add(p);
    }
    // print('isDiscontinuedChecked');
    // print(product['lastAllowedPurchaseDate']);
    // print(product['active']);
    getQuantities();
    update();
  }

  String selectedProductId = '';
  String startDate = '';
  String startTime = '';
  setSelectedProductId(String newVal) {
    selectedProductId = newVal;
    update();
  }

  int selectedProductIndex = 0;
  setSelectedProductIndex(int newVal) {
    selectedProductIndex = newVal;
    update();
  }

  setStartDate(String newVal) {
    startDate = newVal;
    update();
  }

  setStartTime(String newVal) {
    startTime = newVal;
    update();
  }

  updateProductCont(context) async {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);
    showDialog<String>(
      context: context,
      builder:
          (BuildContext context) => const AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(9)),
            ),
            elevation: 0,
            content: LoadingDialog(),
          ),
    );
    var res = await updateProduct(
      selectedGroupsIds,
      selectedProductId,
      int.parse(selectedShownCurrencyId),
      isBlockedChecked ? 1 : 0,
      formattedDate,
      startDate.isEmpty && startTime.isEmpty
          ? '${DateFormat('yyyy-MM-dd').format(DateTime.now())} ${DateFormat.Hms().format(DateTime.now())}'
          : startDate.isEmpty && startTime.isNotEmpty
          ? '${DateFormat('yyyy-MM-dd').format(DateTime.now())} $startTime:00'
          : startDate.isNotEmpty && startTime.isEmpty
          ? '$startDate ${DateFormat.Hms().format(DateTime.now())}'
          : '$startDate $startTime:00',
      selectedCategoryId,
      itemNameController.text,
      isActiveInPosChecked ? '1' : '0',
      1,
      int.parse(selectedItemTypesId),
      codeController.text,
      int.parse(selectedTaxationGroupsId),
      'barcode2w5',
      '43456e35',
      1,
      mainDescriptionController.text,
      shortDescriptionController.text,
      secondLanguageController.text,
      selectedSubrefsId,
      isCanBeSoldChecked ? 1 : 0,
      isCanBePurchasedChecked ? 1 : 0,
      isWarrantyChecked ? 1 : 0,
      dateController.text,
      unitCostController.text != '' ? double.parse(unitCostController.text) : 0,
      decimalCostController.text != ''
          ? int.parse(decimalCostController.text)
          : 0,
      int.parse(selectedCurrencyId),
      int.parse(selectedPriceCurrencyId),
      quantityController.text,
      // quantityController.text != ''
      //     ? int.parse(quantityController.text)
      //     : 0,
      unitPriceController.text != ''
          ? double.parse(unitPriceController.text)
          : 0,
      decimalPriceController.text != ''
          ? int.parse(decimalPriceController.text)
          : 0,
      discLineLimitController.text != ''
          ? double.parse(discLineLimitController.text)
          : 0,
      int.parse(selectedPackageId),
      unitsSuffix.text,
      unitsQuantity.text,
      setsSuffix.text,
      setsQuantity.text,
      supersetSuffix.text,
      supersetQuantity.text,
      paletteSuffix.text,
      paletteQuantity.text,
      containerSuffix.text,
      containerQuantity.text,
      decimalQuantityController.text != ''
          ? int.parse(decimalQuantityController.text)
          : 0,
      [1],
      isDiscontinuedChecked ? 1 : 0,
      altCodesList,
    );

    if (res['success'] == true) {
      if(imagesUrlsToRemove.isNotEmpty){
        for(int i=0;i<imagesUrlsToRemove.length;i++) {
          var subString = imagesUrlsToRemove[i].substring(baseImage.length);
          var del = await deleteImage(selectedProductId, subString);
          if (del['success'] == true) {
            Get.back();
            // CommonWidgets.snackBar('Success', del['message']);
          } else {
            CommonWidgets.snackBar('error', del['message']);
          }
        }
      }
      if (photosFilesList.isNotEmpty) {
        var p = await addImagesToProduct(
          '${res['data']['id']}',
          photosFilesList,
        );
        Get.back();
        if (p['success'] == true) {
          Get.back();
          CommonWidgets.snackBar('Success', res['message']);
          productsList.value = [];
          currentPage.value=1;
          isLoading.value=false;
          hasMore=true;
          getAllProductsFromBack();
          homeController.selectedTab.value = 'items';
        } else {
          CommonWidgets.snackBar('error', p['message']);
        }
      } else
      {
        productsList.value = [];
        currentPage.value=1;
        isLoading.value=false;
        hasMore=true;
        getAllProductsFromBack();
        Get.back();
        Get.back();
        CommonWidgets.snackBar('Success', res['message']);
        homeController.selectedTab.value = 'items';
      }
    } else {
      CommonWidgets.snackBar('error', res['message']);
    }
    update();
  }

  validationFunction(context) {
    if (codeController.text.isEmpty) {
      CommonWidgets.snackBar('error', 'Code is required field');
    } else if (mainDescriptionController.text.isEmpty) {
      CommonWidgets.snackBar('error', 'Main Description is required field');
      // }
      // else if(unitCostController.text.isEmpty || double.parse(unitCostController.text)<=0){
      //   CommonWidgets.snackBar(
      //       'error','Unit Cost is required field');
    } else if (unitPriceController.text.isEmpty ||
        double.parse(unitPriceController.text) <= 0) {
      CommonWidgets.snackBar('error', 'Unit Price is required field');
    } else if (unitsSuffix.text.isEmpty) {
      CommonWidgets.snackBar('error', 'Unit Package Name is required field');
    } else if (int.parse(selectedPackageId) >= 2 && setsSuffix.text.isEmpty) {
      CommonWidgets.snackBar('error', 'Set Package Name is required field');
    } else if (int.parse(selectedPackageId) >= 2 && setsQuantity.text.isEmpty) {
      CommonWidgets.snackBar('error', 'Set Package Quantity is required field');
    } else if (int.parse(selectedPackageId) >= 2 &&
        double.parse(setsQuantity.text) <= 0) {
      CommonWidgets.snackBar('error', 'Set Package Quantity Should be > 0');
    } else if (int.parse(selectedPackageId) >= 3 &&
        supersetSuffix.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Superset Package Name is required field',
      );
    } else if (int.parse(selectedPackageId) >= 3 && setsQuantity.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Superset Package Quantity is required field',
      );
    } else if (int.parse(selectedPackageId) >= 3 &&
        double.parse(setsQuantity.text) <= 0) {
      CommonWidgets.snackBar('error', 'Set Package Quantity Should be > 0');
    } else if (int.parse(selectedPackageId) >= 4 &&
        supersetSuffix.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Superset Package Name is required field',
      );
    } else if (int.parse(selectedPackageId) >= 4 &&
        supersetQuantity.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Superset Package Quantity is required field',
      );
    } else if (int.parse(selectedPackageId) >= 4 &&
        double.parse(supersetQuantity.text) <= 0) {
      CommonWidgets.snackBar(
        'error',
        'Superset Package Quantity Should be > 0',
      );
    } else if (int.parse(selectedPackageId) >= 5 &&
        paletteSuffix.text.isEmpty) {
      CommonWidgets.snackBar('error', 'Palette Package Name is required field');
    } else if (int.parse(selectedPackageId) >= 5 &&
        paletteQuantity.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Palette Package Quantity is required field',
      );
    } else if (int.parse(selectedPackageId) >= 5 &&
        double.parse(paletteQuantity.text) <= 0) {
      CommonWidgets.snackBar('error', 'Palette Package Quantity Should be > 0');
    } else if (int.parse(selectedPackageId) >= 6 &&
        containerSuffix.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Container Package Name is required field',
      );
    } else if (int.parse(selectedPackageId) >= 6 &&
        containerQuantity.text.isEmpty) {
      CommonWidgets.snackBar(
        'error',
        'Container Package Quantity is required field',
      );
    } else if (int.parse(selectedPackageId) >= 6 &&
        double.parse(containerQuantity.text) <= 0) {
      CommonWidgets.snackBar(
        'error',
        'Container Package Quantity Should be > 0',
      );
    }
    // else if(itemNameController.text.isEmpty ) {
    //   CommonWidgets.snackBar(
    //       'error','Item Name Field Is Required');
    // }
    else if (itemNameController.text.length > 30) {
      CommonWidgets.snackBar(
        'error',
        'Item Name Length Should be < 30 character',
      );
    } else {
      isItUpdateProduct
          ? updateProductCont(context)
          : saveAndSendCreateProductOrder(context);
    }
  }
}
