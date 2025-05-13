
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/Transfers/Replenish/get_replenishments.dart';

import '../Backend/ProductsBackend/get_products.dart';
import '../Backend/Transfers/get_transfers.dart';


class TransferController extends GetxController{
  int focusIndex=0;
  final focus = FocusNode();
  setFocusIndex(){
    focusIndex+=1;
    update();
  }

  bool isSubmitAndPreviewClicked=false;
  setIsSubmitAndPreviewClicked(bool val){
    isSubmitAndPreviewClicked=val;
    update();
  }

  int selectedTabIndex=0;
  setSelectedTabIndex(int index){
    selectedTabIndex=index;
    update();
  }
  List productsList = [];
  List<String> productsNames = [];
  List<String> productsCodes = [];
  List productsIds = [];
  bool isProductsFetched = false;
  getAllProductsFromBack(String warehouseId,String search,String cat) async {
    productsList= [];
    productsNames = [];
    productsCodes = [];
    productsIds = [];
    itemsListInReplenish = {};
    isProductsFetched = false;
    var p = await getAllProducts(search,cat,warehouseId,-1);
    for (var item in p) {
      productsNames.add('${item['item_name']}');
      productsCodes.add('${item['mainCode']}');
      productsIds.add(item['id']);
      update();
    }
    productsList.addAll(p);
    isProductsFetched= true;
    update();
  }

  // List<Widget> orderLinesList = [];
  double imageSpaceHeight = 90;

  // addToOrderLinesList(Widget p){
  //   orderLinesList.add(p);
  //   update();
  // }
  // removeFromOrderLinesList(int index){
  //   orderLinesList.removeAt(index);
  //   update();
  // }

  increaseImageSpace(double val){
    imageSpaceHeight=imageSpaceHeight+val;
    update();
  }

//replinsh section
  TextEditingController transferToInReplenishController = TextEditingController();
  String transferToIdInReplenish='';
  // List<Widget> orderLinesInReplenishList = [];
  bool imageAvailableInReplenish=false;
  String selectedCategoryId='';
  setSelectedCategoryId(String val){
    selectedCategoryId=val;
    update();
  }
  setTransferToIdInReplenish(String value){
    transferToIdInReplenish=value;
    update();
  }

  changeBoolVar(bool val){
    imageAvailableInReplenish=val;
    update();
  }
  // addToOrderLinesInReplenishList(Widget p){
  //   orderLinesInReplenishList.add(p);
  //   update();
  // }
  // removeFromOrderLinesInReplenishList(int index){
  //   orderLinesInReplenishList.removeAt(index);
  //   update();
  // }

  resetReplenish(){
    // orderLinesInReplenishList = [];
    itemsListInReplenish={};
    productsList= [];
    productsNames = [];
    productsCodes = [];
    productsIds = [];
    isProductsFetched = false;
    update();
    }



  Map itemsListInReplenish={
    // 1:{
    //   'itemId':1,
    //   'replenishedQty':'ll',
    //    'cost':'20',
    //   'replenishedQtyPackageName':1,//
    //   'note':22,
    // }
  };

  clearReplenishOrderLines(){
    itemsListInReplenish={};
    // orderLinesInReplenishList = [];
    update();
  }
  addToItemsListInReplenish(String index,Map orderItem){
    itemsListInReplenish[index]=orderItem;
    update();
  }
  removeFromItemsListInReplenish(String index){
    itemsListInReplenish.remove(index);
    update();
  }

  setItemIdInReplenish(String index,String val){
    itemsListInReplenish[index]['itemId']=val;
    update();
  }
  setItemNameInReplenish(String index,String val){
    itemsListInReplenish[index]['itemCode']=val;
    update();
  }
  setMainDescriptionInReplenish(String index,String val){
    itemsListInReplenish[index]['mainDescription']=val;
    update();
  }
  setReplenishedQtyInReplenish(String index,String val){
    itemsListInReplenish[index]['replenishedQty']=val;
    update();
  }
  setReplenishedQtyPackageIdInReplenish(String index,String val){
    itemsListInReplenish[index]['replenishedQtyPackage']=val;
    update();
  }
  setCostItemInReplenish(String index,String val){
    itemsListInReplenish[index]['cost']=val;
    update();
  }
  setNoteInReplenish(String index,String val){
    itemsListInReplenish[index]['note']=val;
    update();
  } 
  setQtyOnHandInSourceInReplenish(String index,String val){
    itemsListInReplenish[index]['qtyOnHandPackagesInSource']=val;
    update();
  }
  setProductsPackagesInReplenish(String index,List<String> val){
    itemsListInReplenish[index]['productsPackages']=val;
    update();
  }


  List replenishmentList=[];
  bool isReplenishmentFetched = false;
  TextEditingController searchInReplenishmentsController = TextEditingController();
  getAllReplenishmentFromBack() async{
    replenishmentList=[];
    isReplenishmentFetched = false;
    var p=await getAllReplenishments(searchInReplenishmentsController.text);
    replenishmentList=p;
    isReplenishmentFetched=true;
    update();
  }


//transfers section
  TextEditingController searchInTransfersController = TextEditingController();
  List transfersList=[];
  bool isTransactionsFetched = false;
  getAllTransactionsFromBack() async{
    transfersList=[];
    isTransactionsFetched = false;
    update();
    var p=await getAllTransfers(searchInTransfersController.text);
    if(p['success']==true){
      transfersList=p['data'];
      transfersList=transfersList.reversed.toList();
      isTransactionsFetched=true;
    }
    update();
  }



  //transfer out document
  Map<String,Widget> orderLinesInTransferOutList = {};
  bool imageAvailableInTransferOut=false;
  double imageSpaceHeightInTransferOut = 90;
  TextEditingController transferFromControllerInTransferOut = TextEditingController();
  TextEditingController transferToControllerInTransferOut = TextEditingController();
  String transferToIdInTransferOut='';
  String transferFromIdInTransferOut='';
  double listViewLengthInTransferOut =  50;
  double increment = 50;

  List rowsInListViewInTransferOut=[];
  clearList(){
    rowsInListViewInTransferOut=[];
    update();
  }
  addToRowsInListViewInTransferOut(Map p){
    rowsInListViewInTransferOut.add(p);
    update();
  }
  removeFromRowsInListViewInTransferOut(int index){
    rowsInListViewInTransferOut.removeAt(index);
    update();
  }

  setListViewLengthInTransferOut(double val){
    listViewLengthInTransferOut=val;
    update();
  }
  setIncrement(double val){
    listViewLengthInTransferOut=val;
    update();
  }
  incrementListViewLengthInTransferOut(double val){
    listViewLengthInTransferOut=listViewLengthInTransferOut+val;
    update();
  }
  decrementListViewLengthInTransferOut(double val){
    listViewLengthInTransferOut=listViewLengthInTransferOut-val;
    update();
  }
  setTransferToIdInTransferOut(String value){
    transferToIdInTransferOut=value;
    update();
  }
  setTransferFromIdInTransferOut(String value){
    transferFromIdInTransferOut=value;
    update();
  }
  resetTransferOut(){
    orderLinesInTransferOutList = {};
    productsList= [];
    productsNames = [];
    productsCodes = [];
    productsIds = [];
    isProductsFetched = false;
    update();
  }
  addToOrderLinesInTransferOutList(String index,Widget p){
    orderLinesInTransferOutList[index]=p;
    update();
  }
  removeFromOrderLinesInTransferOutList(String index){
    orderLinesInTransferOutList.remove(index);
    update();
  }

  // Map itemsListInTransferOut={
  //   // 1:{
  //   //   'itemId':1,
  //   //   'replenishedQty':'ll',
  //   //   'replenishedQtyPackageId':1,//todo change
  //   //   'note':22,
  //   // }
  // };
  // addToItemsListInTransferOut(String index,Map orderItem){
  //   itemsListInTransferOut[index]=orderItem;
  //   update();
  // }
  // removeFromItemsListInTransferOut(String index){
  //   itemsListInTransferOut.remove(index);
  //   update();
  // }

  setItemIdInTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['itemId']=val;
    update();
  }
  setItemNameInTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['itemCode']=val;
    update();
  }
  setItemDescriptionInTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['mainDescription']=val;
    update();
  }
  setEnteredQtyInTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['transferredQty']=val;
    update();
  }
  setProductsPackagesInTransferOut(int index,List<String> val){
    rowsInListViewInTransferOut[index]['productsPackages']=val;
    update();
  }
  setQtyOnHandPackagesTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['qtyOnHandPackages']=val;
    update();
  }
  setPackageNameInTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['transferredQtyPackageName']=val;
    update();
  }
  setQtyOnHandPackagesInSourceInTransferOut(int index,String val){
    rowsInListViewInTransferOut[index]['qtyOnHandPackagesInSource']=val;
    update();
  }

  increaseImageSpaceInTransferOut(double val){
    imageSpaceHeightInTransferOut=imageSpaceHeightInTransferOut+val;
    update();
  }
  changeBoolVarInTransferOut(bool val){
    imageAvailableInTransferOut=val;
    update();
  }




  //transfer in document
  Map selectedTransferIn={};
  List rowsInListViewInTransferIn=[];


  setSelectedTransferIn(Map map){
    selectedTransferIn=map;
    update();
  }
  resetTransferIn(){
    rowsInListViewInTransferIn = [];
    selectedTransferIn={};
    update();
  }
  clearRowsInListViewInTransferIn(){
    rowsInListViewInTransferIn=[];
    update();
  }
  addToRowsInListViewInTransferIn(List p){
    rowsInListViewInTransferIn=p;
    update();
  }

  setEnteredQtyInTransferIn(int index,String val){
    rowsInListViewInTransferIn[index]['receivedQty']=val;
    update();
  }
  setNoteInTransferIn(int index,String val){
    rowsInListViewInTransferIn[index]['note']=val;
    update();
  }
  setDifferenceInTransferIn(int index,String val){
    rowsInListViewInTransferIn[index]['qtyDifference']=val;
    update();
  }


}