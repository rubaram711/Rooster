import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Screens/Transfers/print_transfer.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/Transfers/transfer_in.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/transfer_controller.dart';
import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
import '../../Widgets/TransferWidgets/reusable_time_line_tile.dart';
import '../../Widgets/TransferWidgets/under_item_btn.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class TransferIn extends StatefulWidget {
  const TransferIn({super.key});

  @override
  State<TransferIn> createState() => _TransferInState();
}

class _TransferInState extends State<TransferIn> {
  // TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  int currentStep = 0;
  int selectedTabIndex = 0;
  List tabsList = [
    'order_lines',
    'other_information',
  ];
  String? selectedItem = '';

  double listViewLength = Sizes.deviceHeight * 0.09;
  double increment = Sizes.deviceHeight * 0.09;
  final TransferController transferController = Get.find();
  final HomeController homeController = Get.find();
  int progressVar = 0;
  Map data = {};
  bool isInfoFetched = false;
  List<String> warehousesNameList = [];

  String selectedSourceWarehouseIds = '';
  String selectedDestinationWarehouseIds = '';
  clearFieldsForCreateTransfer() async {
    setState(() {
      currentStep = 0;
      selectedTabIndex = 0;
      selectedItem = '';
      progressVar = 0;
      selectedSourceWarehouseIds = '';
      selectedDestinationWarehouseIds = '';
      data = {};
      warehousesNameList = [];
      isInfoFetched = true;
    });
  }

  @override
  void initState() {
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    clearFieldsForCreateTransfer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isInfoFetched
        ? GetBuilder<TransferController>(
          builder: (transferCont) {
            return Container(
                  padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02),
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PageTitle(text: 'transfer_in'.tr),
                  ],
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        UnderTitleBtn(
                          text: 'preview'.tr,
                          onTap: () {
                            // setState(() {
                            //   progressVar+=1;
                            // });
                            Navigator.push(context,
                                MaterialPageRoute(builder: (BuildContext context) {
                                  return   PrintTransferIn(
                                    transferNumber:  transferCont.selectedTransferIn['transferNumber']??'',
                                    receivedDate:transferCont.selectedTransferIn['receivingDate']!=null? dateController.text:'',
                                    creationDate: transferCont.selectedTransferIn['creationDate'].substring(0,11),
                                    ref: transferCont.selectedTransferIn['reference']??'',
                                    transferTo: transferCont.selectedTransferIn['destWarhouse']??'',
                                    receivedUser: transferCont.selectedTransferIn['receivingUser']??'',
                                    senderUser: transferCont.selectedTransferIn['sendingUser']??'',
                                    status: transferCont.selectedTransferIn['status']??'',
                                    transferFrom: transferCont.selectedTransferIn['sourceWarhouse']??'',
                                    rowsInListViewInTransfer: transferCont.rowsInListViewInTransferIn,
                                  );
                                }));
                          },
                        ),
                        UnderTitleBtn(
                          text: 'submit_and_preview'.tr,
                          onTap: () async{
                            // setState(() {
                            //    progressVar = 0;
                            // });
                            bool isThereItemsEmpty=false;
                            for (var map in transferCont.rowsInListViewInTransferIn) {
                              if ( double.parse('${map!["receivedQty"]}') == 0.0 ||  map!["receivedQty"] == '' ||  map!["receivedQty"]==null) {
                                setState(() {
                                  isThereItemsEmpty=true;
                                });
                                break;
                              }
                            }
                            if(isThereItemsEmpty){
                              CommonWidgets.snackBar(
                                  'error',
                                  'check all order lines and enter the required fields');
                            }else{
                              var res = await addTransferIn(
                                  '${transferController
                                      .selectedTransferIn['id']}',
                                  dateController.text,
                                  transferController
                                      .rowsInListViewInTransferIn);
                              if (res['success'] == true) {
                                CommonWidgets.snackBar(
                                    'Success', res['message']);
                                // transferController.getAllTransactionsFromBack();
                                transferCont.setIsSubmitAndPreviewClicked(true);
                                // ignore: use_build_context_synchronously
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (BuildContext context) {
                                      return   PrintTransferIn(
                                        transferNumber:  transferCont.selectedTransferIn['transferNumber']??'',
                                        receivedDate:transferCont.selectedTransferIn['receivingDate']!=null? dateController.text:'',
                                        creationDate: transferCont.selectedTransferIn['creationDate'].substring(0,11),
                                        ref: transferCont.selectedTransferIn['reference']??'',
                                        transferTo: transferCont.selectedTransferIn['destWarhouse']??'',
                                        receivedUser: transferCont.selectedTransferIn['receivingUser']??'',
                                        senderUser: transferCont.selectedTransferIn['sendingUser']??'',
                                        status: transferCont.selectedTransferIn['status']??'',
                                        transferFrom: transferCont.selectedTransferIn['sourceWarhouse']??'',
                                        rowsInListViewInTransfer: transferCont.rowsInListViewInTransferIn,
                                      );
                                    }));
                              } else {
                                CommonWidgets.snackBar(
                                    'error', res['message'] ??
                                    'error'.tr);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ReusableTimeLineTile(
                            id: 0,
                            progressVar: progressVar,
                            isFirst: true,
                            isLast: false,
                            isPast: true,
                            text: 'processing'.tr),
                        ReusableTimeLineTile(
                            id: 1,
                            progressVar: progressVar,
                            isFirst: false,
                            isLast: false,
                            isPast: false,
                            text: 'pending'.tr),
                        ReusableTimeLineTile(
                          id: 2,
                          progressVar: progressVar,
                          isFirst: false,
                          isLast: true,
                          isPast: false,
                          text: 'received'.tr,
                        ),
                      ],
                    )
                  ],
                ),
                gapH16,
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                      border: Border.all(color: Others.divider),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(9))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.35,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                isInfoFetched
                                    ? Text(
                                    transferCont.selectedTransferIn['transferNumber'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color:
                                        TypographyColor.titleTable))
                                    : const CircularProgressIndicator(),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.05,
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.18,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('ref'.tr),
                                      ReusableShowInfoCard(
                                        text: transferCont.selectedTransferIn['reference']??'',
                                        width: MediaQuery.of(context).size.width * 0.15,),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            gapH16,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('transfer_from'.tr),
                                ReusableShowInfoCard(
                                  text: transferCont.selectedTransferIn['sourceWarhouse']??'',
                                  width: MediaQuery.of(context).size.width * 0.25,)
                              ],
                            ),
                            gapH16,
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text('transfer_to'.tr),
                                ReusableShowInfoCard(
                                  text:  transferCont.selectedTransferIn['destWarhouse']??'',
                                  width: MediaQuery.of(context).size.width * 0.25,)
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.25,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('date'.tr),
                                  DialogDateTextField(
                                    textEditingController: dateController,
                                    text: '',
                                    textFieldWidth:
                                    MediaQuery.of(context).size.width *
                                        0.15,
                                    validationFunc: (val) {},
                                    onChangedFunc: (val) {
                                      // dateController.text=val;
                                    },
                                    onDateSelected: (value) {
                                      String rd=transferCont.selectedTransferIn['creationDate'].substring(0,10);
                                      DateTime dt1 = DateTime.parse("$rd 00:00:00");
                                      DateTime dt2 = DateTime.parse("$value 00:00:00");
                                      if(dt2.isBefore(dt1)){
                                        CommonWidgets.snackBar(
                                            'error',
                                            'Received date can\'t be before transfer date');
                                      }else{
                                        dateController.text = value;}
                                    },
                                  ),
                                ],
                              ),
                            ),
                            gapH100,
                            Text('${'total_qty'.tr}: ')
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                        spacing: 0.0,
                        direction: Axis.horizontal,
                        children: tabsList
                            .map((element) => _buildTabChipItem(
                            element,
                            tabsList.indexOf(element)))
                            .toList()),
                  ],
                ),
                // tabsContent[selectedTabIndex],
                selectedTabIndex == 0
                    ? Column(
                  children: [
                    Container(
                      padding:const EdgeInsets.symmetric(
                          // horizontal:
                          // MediaQuery.of(context).size.width *
                          //     0.01,
                          vertical: 15),
                      decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius: const BorderRadius.all(
                              Radius.circular(6))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TableTitle(
                            text: 'item'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.1,
                          ),
                          TableTitle(
                            text: 'description'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.2,
                          ),
                          TableTitle(
                            text: 'qty_transferred'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.07,
                          ),
                          TableTitle(
                            text: 'pack'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.03,
                          ),
                          TableTitle(
                            text: 'qty_received'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.07,
                          ),
                          TableTitle(
                            text: 'pack'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.03,
                          ),
                          TableTitle(
                            text: 'difference'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.07,
                          ),
                          TableTitle(
                            text: 'pack'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.03,
                          ),
                          TableTitle(
                            text: 'note'.tr,
                            width: MediaQuery.of(context).size.width *
                                0.1,
                          ),
                        ],
                      ),
                    ),
                    GetBuilder<TransferController>(builder: (cont) {
                      return Container(
                        // padding: EdgeInsets.symmetric(
                        //     horizontal:
                        //     MediaQuery.of(context).size.width *
                        //         0.01),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(6),
                              bottomRight: Radius.circular(6)),
                          color: Colors.white,
                        ),
                        child: Column(
                          // crossAxisAlignment:
                          // CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: Sizes.deviceHeight * 0.13*cont.rowsInListViewInTransferIn.length,
                              child: ListView.builder(
                                padding:  const EdgeInsets.symmetric(
                                    vertical: 10),
                                itemCount: cont.rowsInListViewInTransferIn
                                    .length, //products is data from back res
                                itemBuilder: (context, index) =>ReusableItemRowInTransferIn(
                                  transferredItemInfo: cont.rowsInListViewInTransferIn[index],
                                index: index,
                                )
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    gapH28,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ReusableButtonWithColor(
                          width: MediaQuery.of(context).size.width *
                              0.15,
                          height: 45,
                          onTapFunction: () async {
                            bool isThereItemsEmpty=false;
                            for (var map in transferCont.rowsInListViewInTransferIn) {
                              if ( double.parse('${map!["receivedQty"]}') == 0.0 ||  map!["receivedQty"] == '' ||  map!["receivedQty"]==null) {
                                setState(() {
                                  isThereItemsEmpty=true;
                                });
                                break;
                              }
                            }
                            if(isThereItemsEmpty){
                              CommonWidgets.snackBar(
                                  'error',
                                  'check all order lines and enter the required fields');
                            }else{
                              var res = await addTransferIn(
                                  '${transferController
                                  .selectedTransferIn['id']}',
                                  dateController.text,
                                  transferController
                                      .rowsInListViewInTransferIn);
                              if (res['success'] == true) {
                                CommonWidgets.snackBar(
                                    'Success', res['message']);
                                transferController.getAllTransactionsFromBack();
                                homeController.selectedTab.value =
                                'transfers';
                              } else {
                                CommonWidgets.snackBar(
                                    'error', res['message'] ??
                                    'error'.tr);
                              }
                            }
                          },
                          btnText: 'submit'.tr,
                        ),
                      ],
                    )
                  ],
                )
                    : const SizedBox(),
                gapH40,
              ],
            ),
                  ),
                );
          }
        )
        : const CircularProgressIndicator();
  }

  Widget _buildTabChipItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: ClipPath(
        clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9)))),
        child: Container(
          width:name.length*10,// MediaQuery.of(context).size.width * 0.09,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
              color: selectedTabIndex == index ? Primary.p20 : Colors.white,
              border: selectedTabIndex == index
                  ? Border(
                top: BorderSide(color: Primary.primary, width: 3),
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  // offset: Offset(0, 3),
                )
              ]),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Primary.primary),
            ),
          ),
        ),
      ),
    );
  }

}


class ReusableItemRowInTransferIn extends StatefulWidget {
  const ReusableItemRowInTransferIn({super.key, required this.transferredItemInfo, required this.index, this.isMobile=false});
  final Map transferredItemInfo;
  final int index;
  final bool isMobile;
  @override
  State<ReusableItemRowInTransferIn> createState() => _ReusableItemRowInTransferInState();
}

class _ReusableItemRowInTransferInState extends State<ReusableItemRowInTransferIn> {
  TextEditingController receivedQtyController=TextEditingController();
  String deference='';
  TextEditingController noteController=TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final TransferController transferController = Get.find();
  @override
  void initState() {
    transferController.isSubmitAndPreviewClicked=false;
    receivedQtyController.clear();
    deference='${widget.transferredItemInfo['transferredQty']??'0'}';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  GetBuilder<TransferController>(builder: (cont) {
        return Container(
          // width: MediaQuery.of(context).size.width * 0.63,
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Form(
            key: _formKey,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width:widget.isMobile?20:  MediaQuery.of(context).size.width * 0.02,
                  height: 20,
                  margin:
                  const EdgeInsets.symmetric(
                      vertical: 15),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                          'assets/images/newRow.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                ReusableShowInfoCard(text: widget.transferredItemInfo['itemCode']??'', width:widget.isMobile?150:  MediaQuery.of(context).size.width * 0.07),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(text: widget.transferredItemInfo['mainDescription']??'', width: widget.isMobile?200: MediaQuery.of(context).size.width * 0.2),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(text: '${widget.transferredItemInfo['transferredQty']??''}', width:widget.isMobile?150:  MediaQuery.of(context).size.width * 0.07),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(text: '${widget.transferredItemInfo['transferredQtyPackageName']??''}', width:widget.isMobile?80:  MediaQuery.of(context).size.width * 0.03),
                widget.isMobile?gapW4:SizedBox(),
                SizedBox(
                    width:widget.isMobile?150:  MediaQuery.of(context).size.width * 0.07,
                    child: ReusableNumberField(
                      textEditingController: receivedQtyController,
                      isPasswordField: false,
                      isCentered: true,
                      hint: '0',
                      onChangedFunc: (val) {
                        _formKey.currentState!.validate();
                        cont.setEnteredQtyInTransferIn(widget.index, val);
                        setState(() {
                          deference='${double.parse('${widget.transferredItemInfo['transferredQty']}') - double.parse(val??'0')}';
                        });
                        cont.setDifferenceInTransferIn(widget.index, deference);
                      },
                      validationFunc: (String? value) {
                        if( value!.isEmpty || double.parse(value)<=0 ){
                          return 'must be >0';
                        }
                        return null;
                      },
                    )),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(text: '${widget.transferredItemInfo['transferredQtyPackageName']??''}', width:widget.isMobile?80: MediaQuery.of(context).size.width * 0.03),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(text: deference, width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.07),
                widget.isMobile?gapW4:SizedBox(),
                ReusableShowInfoCard(text: '${widget.transferredItemInfo['transferredQtyPackageName']??''}', width:widget.isMobile?80: MediaQuery.of(context).size.width * 0.03),
                widget.isMobile?gapW4:SizedBox(),
                SizedBox(
                    width:widget.isMobile?150: MediaQuery.of(context).size.width * 0.1,
                    child: ReusableTextField(
                      onChangedFunc: (val){
                        cont.setNoteInTransferIn(widget.index, val);
                      },
                      validationFunc: (val){},
                      hint: '',
                      isPasswordField: false,
                      textEditingController:noteController
                  ),
                )
              ],
            ),
          ),
        );
      }
    );
  }
}






class TransferInForMobile extends StatefulWidget {
  const TransferInForMobile({super.key});

  @override
  State<TransferInForMobile> createState() => _TransferInForMobileState();
}

class _TransferInForMobileState extends State<TransferInForMobile> {
  // TextEditingController refController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  int currentStep = 0;
  int selectedTabIndex = 0;
  List tabsList = [
    'order_lines',
    'other_information',
  ];
  String? selectedItem = '';

  double listViewLength = Sizes.deviceHeight * 0.09;
  double increment = Sizes.deviceHeight * 0.09;
  final TransferController transferController = Get.find();
  final HomeController homeController = Get.find();
  int progressVar = 0;
  Map data = {};
  bool isInfoFetched = false;
  List<String> warehousesNameList = [];

  String selectedSourceWarehouseIds = '';
  String selectedDestinationWarehouseIds = '';
  clearFieldsForCreateTransfer() async {
    setState(() {
      currentStep = 0;
      selectedTabIndex = 0;
      selectedItem = '';
      progressVar = 0;
      selectedSourceWarehouseIds = '';
      selectedDestinationWarehouseIds = '';
      data = {};
      warehousesNameList = [];
      isInfoFetched = true;
    });
  }

  @override
  void initState() {
    dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    clearFieldsForCreateTransfer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isInfoFetched
        ? GetBuilder<TransferController>(
        builder: (transferCont) {
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.02),
            height: MediaQuery.of(context).size.height * 0.85,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PageTitle(text: 'transfer_in'.tr),
                    ],
                  ),
                  gapH16,
                  Row(
                    children: [
                      UnderTitleBtn(
                        text: 'preview'.tr,
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (BuildContext context) {
                                return   PrintTransferIn(
                                  transferNumber:  transferCont.selectedTransferIn['transferNumber']??'',
                                  receivedDate:transferCont.selectedTransferIn['receivingDate']!=null? dateController.text:'',
                                  creationDate: transferCont.selectedTransferIn['creationDate'].substring(0,11),
                                  ref: transferCont.selectedTransferIn['reference']??'',
                                  transferTo: transferCont.selectedTransferIn['destWarhouse']??'',
                                  receivedUser: transferCont.selectedTransferIn['receivingUser']??'',
                                  senderUser: transferCont.selectedTransferIn['sendingUser']??'',
                                  status: transferCont.selectedTransferIn['status']??'',
                                  transferFrom: transferCont.selectedTransferIn['sourceWarhouse']??'',
                                  rowsInListViewInTransfer: transferCont.rowsInListViewInTransferIn,
                                );
                              }));
                        },
                      ),
                      UnderTitleBtn(
                        text: 'submit_and_preview'.tr,
                        onTap: () async{
                          // setState(() {
                          //    progressVar = 0;
                          // });
                          bool isThereItemsEmpty=false;
                          for (var map in transferCont.rowsInListViewInTransferIn) {
                            if ( double.parse('${map!["receivedQty"]}') == 0.0 ||  map!["receivedQty"] == '' ||  map!["receivedQty"]==null) {
                              setState(() {
                                isThereItemsEmpty=true;
                              });
                              break;
                            }
                          }
                          if(isThereItemsEmpty){
                            CommonWidgets.snackBar(
                                'error',
                                'check all order lines and enter the required fields');
                          }else{
                            var res = await addTransferIn(
                                '${transferController
                                    .selectedTransferIn['id']}',
                                dateController.text,
                                transferController
                                    .rowsInListViewInTransferIn);
                            if (res['success'] == true) {
                              CommonWidgets.snackBar(
                                  'Success', res['message']);
                              // transferController.getAllTransactionsFromBack();
                              transferCont.setIsSubmitAndPreviewClicked(true);
                              // ignore: use_build_context_synchronously
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (BuildContext context) {
                                    return   PrintTransferIn(
                                      transferNumber:  transferCont.selectedTransferIn['transferNumber']??'',
                                      receivedDate:transferCont.selectedTransferIn['receivingDate']!=null? dateController.text:'',
                                      creationDate: transferCont.selectedTransferIn['creationDate'].substring(0,11),
                                      ref: transferCont.selectedTransferIn['reference']??'',
                                      transferTo: transferCont.selectedTransferIn['destWarhouse']??'',
                                      receivedUser: transferCont.selectedTransferIn['receivingUser']??'',
                                      senderUser: transferCont.selectedTransferIn['sendingUser']??'',
                                      status: transferCont.selectedTransferIn['status']??'',
                                      transferFrom: transferCont.selectedTransferIn['sourceWarhouse']??'',
                                      rowsInListViewInTransfer: transferCont.rowsInListViewInTransferIn,
                                    );
                                  }));
                            } else {
                              CommonWidgets.snackBar(
                                  'error', res['message'] ??
                                  'error'.tr);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  gapH16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ReusableTimeLineTile(
                          id: 0,
                          progressVar: progressVar,
                          isFirst: true,
                          isLast: false,
                          isPast: true,
                          isDesktop: false,
                          text: 'processing'.tr),
                      ReusableTimeLineTile(
                          id: 1,
                          progressVar: progressVar,
                          isFirst: false,
                          isLast: false,
                          isPast: false,
                          isDesktop: false,
                          text: 'pending'.tr),
                      ReusableTimeLineTile(
                        id: 2,
                        progressVar: progressVar,
                        isFirst: false,
                        isLast: true,
                        isPast: false,
                        isDesktop: false,
                        text: 'received'.tr,
                      ),
                    ],
                  ),
                  gapH16,
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    decoration: BoxDecoration(
                        border: Border.all(color: Others.divider),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(9))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            isInfoFetched
                                ? Text(
                                transferCont.selectedTransferIn['transferNumber'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color:
                                    TypographyColor.titleTable))
                                : const CircularProgressIndicator(),
                            SizedBox(
                              width: MediaQuery.of(context).size.width *
                                  0.1,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('ref'.tr),
                                  ReusableShowInfoCard(
                                    text: transferCont.selectedTransferIn['reference']??'',
                                    width: MediaQuery.of(context).size.width * 0.35,),
                                ],
                              ),
                            )
                          ],
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('date'.tr),
                            DialogDateTextField(
                              textEditingController: dateController,
                              text: '',
                              textFieldWidth:
                              MediaQuery.of(context).size.width *
                                  0.5,
                              validationFunc: (val) {},
                              onChangedFunc: (val) {
                                // dateController.text=val;
                              },
                              onDateSelected: (value) {
                                String rd=transferCont.selectedTransferIn['creationDate'].substring(0,10);
                                DateTime dt1 = DateTime.parse("$rd 00:00:00");
                                DateTime dt2 = DateTime.parse("$value 00:00:00");
                                if(dt2.isBefore(dt1)){
                                  CommonWidgets.snackBar(
                                      'error',
                                      'Received date can\'t be before transfer date');
                                }else{
                                  dateController.text = value;}
                              },
                            ),
                          ],
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('transfer_from'.tr),
                            ReusableShowInfoCard(
                              text: transferCont.selectedTransferIn['sourceWarhouse']??'',
                              width: MediaQuery.of(context).size.width * 0.5,)
                          ],
                        ),
                        gapH16,
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Text('transfer_to'.tr),
                            ReusableShowInfoCard(
                              text:  transferCont.selectedTransferIn['destWarhouse']??'',
                              width: MediaQuery.of(context).size.width * 0.5,)
                          ],
                        ),
                      ],
                    ),
                  ),
                  gapH16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Wrap(
                          spacing: 0.0,
                          direction: Axis.horizontal,
                          children: tabsList
                              .map((element) => _buildTabChipItem(
                              element,
                              tabsList.indexOf(element)))
                              .toList()),
                    ],
                  ),
                  // tabsContent[selectedTabIndex],
                  selectedTabIndex == 0
                      ? Column(
                    children: [
                      SingleChildScrollView(
                        child: Row(
                          children: [ Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding:
                                    const EdgeInsets.symmetric( vertical: 15),
                                    decoration: BoxDecoration(
                                        color: Primary.primary,
                                        borderRadius:
                                        const BorderRadius.all(Radius.circular(6))),
                                    child: Row(
                                      children: [
                                        TableTitle(
                                          text: 'item'.tr,
                                          width: 170,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'description'.tr,
                                          width: 200,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'qty_transferred'.tr,
                                          width:150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'pack'.tr,
                                          width: 80,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'qty_received'.tr,
                                          width: 150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'pack'.tr,
                                          width: 80,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'difference'.tr,
                                          width: 150,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'pack'.tr,
                                          width: 80,
                                        ),
                                        gapW4,
                                        TableTitle(
                                          text: 'note'.tr,
                                          width: 150,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      children: List.generate(
                                        transferCont.rowsInListViewInTransferIn
                                            .length,
                                            (index) =>ReusableItemRowInTransferIn(
                                              isMobile: true,
                                              transferredItemInfo: transferCont.rowsInListViewInTransferIn[index],
                                              index: index,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),],
                        ),
                      ),
                      gapH28,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ReusableButtonWithColor(
                            width: MediaQuery.of(context).size.width *
                                0.35,
                            height: 45,
                            onTapFunction: () async {
                              bool isThereItemsEmpty=false;
                              for (var map in transferCont.rowsInListViewInTransferIn) {
                                if ( double.parse('${map!["receivedQty"]}') == 0.0 ||  map!["receivedQty"] == '' ||  map!["receivedQty"]==null) {
                                  setState(() {
                                    isThereItemsEmpty=true;
                                  });
                                  break;
                                }
                              }
                              if(isThereItemsEmpty){
                                CommonWidgets.snackBar(
                                    'error',
                                    'check all order lines and enter the required fields');
                              }else{
                                var res = await addTransferIn(
                                    '${transferController
                                        .selectedTransferIn['id']}',
                                    dateController.text,
                                    transferController
                                        .rowsInListViewInTransferIn);
                                if (res['success'] == true) {
                                  CommonWidgets.snackBar(
                                      'Success', res['message']);
                                  transferController.getAllTransactionsFromBack();
                                  homeController.selectedTab.value =
                                  'transfers';
                                } else {
                                  CommonWidgets.snackBar(
                                      'error', res['message'] ??
                                      'error'.tr);
                                }
                              }
                            },
                            btnText: 'submit'.tr,
                          ),
                        ],
                      ),
                      gapH28,
                    ],
                  )
                      : const SizedBox(),
                  gapH40,
                ],
              ),
            ),
          );
        }
    )
        : const CircularProgressIndicator();
  }

  Widget _buildTabChipItem(String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: ClipPath(
        clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9)))),
        child: Container(
          width:name.length*10,// MediaQuery.of(context).size.width * 0.09,
          height: MediaQuery.of(context).size.height * 0.07,
          decoration: BoxDecoration(
              color: selectedTabIndex == index ? Primary.p20 : Colors.white,
              border: selectedTabIndex == index
                  ? Border(
                top: BorderSide(color: Primary.primary, width: 3),
              )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  // offset: Offset(0, 3),
                )
              ]),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Primary.primary),
            ),
          ),
        ),
      ),
    );
  }

}