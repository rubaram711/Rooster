
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/transfer_controller.dart';
import 'package:rooster_app/Widgets/table_item.dart';
import '../../../Controllers/home_controller.dart';
import '../../../Widgets/page_title.dart';
import '../../../Widgets/reusable_btn.dart';
import '../../../Widgets/reusable_text_field.dart';
import '../../../Widgets/table_title.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../PurchaseInvoice/purchase_invoice_summary.dart';

class Replenishment extends StatefulWidget {
  const Replenishment({super.key});

  @override
  State<Replenishment> createState() => _ReplenishmentState();
}

class _ReplenishmentState extends State<Replenishment> {
  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt=10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  final TransferController transferController = Get.find();
  bool isNumberOrderedUp=true;
  bool isCreationOrderedUp=true;


  String searchValue = '';
  Timer? searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
        800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
            () => searchOnStoppedTyping = Timer(duration, () => search(value)));
  }

  search(value) async {
    setState(() {
      searchValue = value;
    });
    await transferController.getAllReplenishmentFromBack();
  }
  @override
  void initState() {
    listViewLength = Sizes.deviceHeight * (0.09 * transferController.transfersList.length);
    transferController.searchInReplenishmentsController.clear();
    transferController.getAllReplenishmentFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
        builder: (cont) {
          return Container(
            padding:  EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.width * 0.02),
            height: MediaQuery.of(context).size.height * 0.85,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(text: 'replenishment'.tr),
                      ReusableButtonWithColor(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 45,
                        onTapFunction: () {
                          homeController.selectedTab.value = 'replenish_transfer';
                        },
                        btnText: 'create_new_replenishment'.tr,
                      ),
                    ],
                  ),
                  gapH24,
                  SizedBox(
                    // width: MediaQuery.of(context).size.width * 0.59,
                    child: ReusableSearchTextField(
                      hint: '${"search".tr}...',
                      textEditingController: cont.searchInReplenishmentsController,
                      onChangedFunc: (val) {
                        _onChangeHandler(val);
                      },
                      validationFunc: (val) {},
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  ReusableChip(
                    name: 'all_transfers'.tr,
                  ),
                  Column(
                    children: [
                      Container(
                        padding:
                        const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            color: Primary.primary,
                            borderRadius:
                            const BorderRadius.all(Radius.circular(6))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            tableTitleWithOrderArrow('number'.tr,
                                MediaQuery.of(context).size.width * 0.1, () {
                                  setState(() {
                                    isNumberOrderedUp=!isNumberOrderedUp;
                                    isNumberOrderedUp
                                        ? cont.replenishmentList.sort((a, b) => a['transferNumber'].compareTo(b['transferNumber']))
                                        : cont.replenishmentList.sort((a, b) => b['transferNumber'].compareTo(a['transferNumber']));
                                  });
                                }),
                            tableTitleWithOrderArrow('creation_date'.tr,
                                MediaQuery.of(context).size.width * 0.1, () {
                                  setState(() {
                                    isCreationOrderedUp=!isCreationOrderedUp;
                                    isCreationOrderedUp?
                                    cont.replenishmentList.sort((a, b) => a['date'].compareTo(b['date']))
                                        :cont.replenishmentList.sort((a, b) => b['date'].compareTo(a['date']));
                                  });
                                }),
                            TableTitle(
                              text: 'dest_whse'.tr,
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),
                            TableTitle(
                              text: 'task'.tr,
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),
                            TableTitle(
                              text: 'status'.tr,
                              width: MediaQuery.of(context).size.width * 0.1,
                            ),
                            // TableTitle(
                            //   text: 'more'.tr,
                            //   width: MediaQuery.of(context).size.width * 0.03,
                            // ),
                          ],
                        ),
                      ),
                      cont.isReplenishmentFetched
                          ?Container(
                        color: Colors.white,
                        height:500,// listViewLength,
                        child: ListView.builder(
                          itemCount:cont.replenishmentList.length,// cont.replenishmentList.length>9?selectedNumberOfRowsAsInt: cont.replenishmentList.length,
                          itemBuilder: (context, index) => Column(
                            children: [
                              ReplenishmentAsRowInTable(
                                info:  cont.replenishmentList[index],
                                index: index,
                              ),
                              const Divider()
                            ],
                          ),
                        ),
                      ):const CircularProgressIndicator(),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Text(
                      //       '${'rows_per_page'.tr}:  ',
                      //       style: const TextStyle(
                      //           fontSize: 13, color: Colors.black54),
                      //     ),
                      //     Container(
                      //       width: 60,
                      //       height: 30,
                      //       decoration: BoxDecoration(
                      //           borderRadius: BorderRadius.circular(6),
                      //           border: Border.all(color: Colors.black, width: 2)),
                      //       child: Center(
                      //         child: DropdownButtonHideUnderline(
                      //           child: DropdownButton<String>(
                      //             borderRadius: BorderRadius.circular(0),
                      //             items: ['10', '20', '50', 'all'.tr]
                      //                 .map((String value) {
                      //               return DropdownMenuItem<String>(
                      //                 value: value,
                      //                 child: Text(
                      //                   value,
                      //                   style: const TextStyle(
                      //                       fontSize: 12, color: Colors.grey),
                      //                 ),
                      //               );
                      //             }).toList(),
                      //             value: selectedNumberOfRows,
                      //             onChanged: (val) {
                      //               setState(() {
                      //                 selectedNumberOfRows = val!;
                      //                 if(val=='10'){
                      //                   listViewLength =  cont.replenishmentList.length < 10
                      //                       ?Sizes.deviceHeight * (0.09 *  cont.replenishmentList.length)
                      //                       : Sizes.deviceHeight * (0.09 * 10);
                      //                   selectedNumberOfRowsAsInt= cont.replenishmentList.length < 10?  cont.replenishmentList.length:10;
                      //                 }if(val=='20'){
                      //                   listViewLength =  cont.replenishmentList.length < 20
                      //                       ? Sizes.deviceHeight * (0.09 *  cont.replenishmentList.length)
                      //                       : Sizes.deviceHeight * (0.09 * 20);
                      //                   selectedNumberOfRowsAsInt= cont.replenishmentList.length < 20?  cont.replenishmentList.length:20;
                      //                 }if(val=='50'){
                      //                   listViewLength =  cont.replenishmentList.length < 50
                      //                       ? Sizes.deviceHeight * (0.09 *  cont.replenishmentList.length)
                      //                       : Sizes.deviceHeight * (0.09 * 50);
                      //                   selectedNumberOfRowsAsInt= cont.replenishmentList.length < 50?  cont.replenishmentList.length:50;
                      //                 }if(val=='all'.tr){
                      //                   listViewLength = Sizes.deviceHeight * (0.09 *  cont.replenishmentList.length);
                      //                   selectedNumberOfRowsAsInt=  cont.replenishmentList.length;
                      //                 }
                      //               });
                      //             },
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     gapW16,
                      //     Text(selectedNumberOfRows=='all'.tr?'${'all'.tr} of ${ cont.replenishmentList.length}':'$start-$selectedNumberOfRows of ${ cont.replenishmentList.length}',
                      //         style: const TextStyle(
                      //             fontSize: 13, color: Colors.black54)),
                      //     gapW16,
                      //     InkWell(
                      //         onTap: () {
                      //           setState(() {
                      //             isArrowBackClicked = !isArrowBackClicked;
                      //             isArrowForwardClicked = false;
                      //           });
                      //         },
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.skip_previous,
                      //               color: isArrowBackClicked
                      //                   ? Colors.black87
                      //                   : Colors.grey,
                      //             ),
                      //             Icon(
                      //               Icons.navigate_before,
                      //               color: isArrowBackClicked
                      //                   ? Colors.black87
                      //                   : Colors.grey,
                      //             ),
                      //           ],
                      //         )),
                      //     gapW10,
                      //     InkWell(
                      //         onTap: () {
                      //           setState(() {
                      //             isArrowForwardClicked = !isArrowForwardClicked;
                      //             isArrowBackClicked = false;
                      //           });
                      //         },
                      //         child: Row(
                      //           children: [
                      //             Icon(
                      //               Icons.navigate_next,
                      //               color: isArrowForwardClicked
                      //                   ? Colors.black87
                      //                   : Colors.grey,
                      //             ),
                      //             Icon(
                      //               Icons.skip_next,
                      //               color: isArrowForwardClicked
                      //                   ? Colors.black87
                      //                   : Colors.grey,
                      //             ),
                      //           ],
                      //         )),
                      //     gapW40,
                      //   ],
                      // )
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  String hoverTitle = '';
  String clickedTitle = '';
  bool isClicked = false;
  tableTitleWithOrderArrow(String text, double width, Function onClickedFunc) {
    return SizedBox(
      width: width,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              clickedTitle = text;
              hoverTitle = '';
              isClicked = !isClicked;
              onClickedFunc();
            });
          },
          onHover: (val) {
            if (val) {
              setState(() {
                hoverTitle = text;
              });
            } else {
              setState(() {
                hoverTitle = '';
              });
            }
          },
          child: clickedTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text.length>8?'${text.substring(0,8)}...':text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              isClicked
                  ? const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              )
                  : const Icon(
                Icons.arrow_drop_up,
                color: Colors.white,
              )
            ],
          )
              : hoverTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${text.length>7?text.substring(0,6):text}...',
                  style: TextStyle(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withAlpha((0.5 * 255).toInt()),
              )
            ],
          )
              : Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}



class ReplenishmentAsRowInTable extends StatelessWidget {
  const ReplenishmentAsRowInTable(
      {super.key, required this.info, required this.index,  this.isDesktop=true});
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric( vertical: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TableItem(
            text: '${info['replenishmentNumber'] ?? ''}',
            width:isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          TableItem(
            text: '${info['date'] ?? ''}'.substring(0,11),
            width:isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          TableItem(
            text: '${info['destWarehouse'] ?? ''}',
            width: isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          TableItem(
            text: '${info['task'] ?? 'No Records'}',
            width:isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
          ),
          SizedBox(
            width:isDesktop? MediaQuery.of(context).size.width * 0.1 :150,
            child: Center(
              child: Container(
                width: '${info['status']}'.length * 10.0,
                padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
                decoration: BoxDecoration(
                    color: info['status'] == "pending"
                        ? Others.orangeStatusColor
                        : info['status'] == 'cancelled'
                        ? Others.redStatusColor
                        : Others.greenStatusColor,
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                    child: Text(
                      '${info['status'] ?? ''}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReusableMore extends StatelessWidget {
  const ReusableMore({super.key, required this.itemsList});
  final List<PopupMenuEntry> itemsList;
  @override
  Widget build(BuildContext context) {
    GlobalKey accMoreKey = GlobalKey();
    return InkWell(
      key: accMoreKey,
      onTap: () {
        {
          // if (val == true) {
          final RenderBox renderBox =
          accMoreKey.currentContext?.findRenderObject() as RenderBox;
          final Size size = renderBox.size;
          final Offset offset = renderBox.localToGlobal(Offset.zero);
          showMenu(
              context: context,
              color: Colors.white, //TypographyColor.menuBg,
              surfaceTintColor: Colors.white,
              position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + size.height + 15,
                  offset.dx + size.width,
                  offset.dy + size.height),
              items: itemsList
          );
        }
      },
      child: Icon(
        Icons.more_horiz,
        color: TypographyColor.titleTable,
      ),
    );
  }
}


class MobileReplenishmentSummary extends StatefulWidget {
  const MobileReplenishmentSummary({super.key});

  @override
  State<MobileReplenishmentSummary> createState() => _MobileReplenishmentSummaryState();
}

class _MobileReplenishmentSummaryState extends State<MobileReplenishmentSummary> {
  final TextEditingController filterController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt=10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  bool isNumberOrderedUp=true;
  bool isCreationOrderedUp=true;
  bool isCustomerOrderedUp=true;
  bool isSalespersonOrderedUp=true;
  final TransferController transferController = Get.find();

  @override
  void initState() {
    listViewLength = Sizes.deviceHeight * (0.09 * transferController.replenishmentList.length);
    transferController.getAllTransactionsFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
        builder: (cont) {
          return Container(
            padding:  EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.width * 0.02),
            height: MediaQuery.of(context).size.height * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(text: 'replenishment'.tr),
                  gapH10,
                  ReusableButtonWithColor(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 45,
                    onTapFunction: () {
                      homeController.selectedTab.value = 'replenish_transfer';
                    },
                    btnText: 'create_new_replenishment'.tr,
                  ),
                  gapH10,
                  SizedBox(
                    // width: MediaQuery.of(context).size.width * 0.59,
                    child: ReusableSearchTextField(
                      hint: '${"search".tr}...',
                      textEditingController: searchController,
                      onChangedFunc: () {},
                      validationFunc: () {},
                    ),
                  ),
                  gapH24,
                  ReusableChip(
                    name: 'all_Transfers'.tr,
                    isDesktop: false,
                  ),
                  SizedBox(
                    height: listViewLength+150,
                    child: SingleChildScrollView(
                      child: Row(
                        children: [ Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
                                  decoration: BoxDecoration(
                                      color: Primary.primary,
                                      borderRadius:
                                      const BorderRadius.all(Radius.circular(6))),
                                  child: Row(
                                    children: [
                                      tableTitleWithOrderArrow('number'.tr,
                                          150, () {
                                            setState(() {
                                              isNumberOrderedUp=!isNumberOrderedUp;
                                              isNumberOrderedUp
                                                  ? cont.replenishmentList.sort((a, b) => a['transferNumber'].compareTo(b['transferNumber']))
                                                  : cont.replenishmentList.sort((a, b) => b['transferNumber'].compareTo(a['transferNumber']));
                                            });
                                          }),
                                      tableTitleWithOrderArrow('creation'.tr,
                                          150, () {
                                            setState(() {
                                              isCreationOrderedUp=!isCreationOrderedUp;
                                              isCreationOrderedUp?
                                              cont.replenishmentList.sort((a, b) => a['createdAtDate'].compareTo(b['createdAtDate']))
                                                  :cont.replenishmentList.sort((a, b) => b['createdAtDate'].compareTo(a['createdAtDate']));
                                            });
                                          }),
                                      //todo
                                      TableTitle(
                                        text: 'task'.tr,
                                        width: 150,
                                      ),
                                      TableTitle(
                                        text: 'total'.tr,
                                        width:150,
                                      ),
                                      TableTitle(
                                        text: 'status'.tr,
                                        width:150,
                                      ),
                                      TableTitle(
                                          text: 'more_options'.tr,
                                          width:100
                                      ),
                                    ],
                                  ),
                                ),
                                cont.isTransactionsFetched
                                    ?Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: List.generate(
                                      cont.replenishmentList.length>9?selectedNumberOfRowsAsInt:cont.replenishmentList.length,
                                          (index) =>Column(
                                        children: [
                                          Row(
                                            children: [
                                              ReplenishmentAsRowInTable(
                                                info: cont.replenishmentList[index],
                                                index: index,
                                                isDesktop: false,
                                              ),
                                              SizedBox(
                                                width: 100,
                                                child: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width *
                                                          0.03,
                                                      child:  const ReusableMore(
                                                        itemsList: [],),
                                                    ),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width *
                                                          0.03,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          // var res= await deleteTransfer('${transfersList[index]['id']}');
                                                          // if(res.statusCode==200){
                                                          //   CommonWidgets.snackBar('Success', res['message']);
                                                          //   setState(() {
                                                          //     selectedNumberOfRowsAsInt=selectedNumberOfRowsAsInt-1;
                                                          //     transfersList.removeAt(index);
                                                          //     listViewLength=listViewLength-0.09;
                                                          //   });
                                                          // }else{
                                                          //   CommonWidgets.snackBar('error',
                                                          //       res['message']);
                                                          // }
                                                        },
                                                        child: Icon(
                                                          Icons.delete_outline,
                                                          color: Primary.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider()
                                        ],
                                      ),
                                    ),
                                  ),
                                ):const CircularProgressIndicator(),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   children: [
                                //     Text(
                                //       '${'rows_per_page'.tr}:  ',
                                //       style: const TextStyle(
                                //           fontSize: 13, color: Colors.black54),
                                //     ),
                                //     Container(
                                //       width: 60,
                                //       height: 30,
                                //       decoration: BoxDecoration(
                                //           borderRadius: BorderRadius.circular(6),
                                //           border: Border.all(color: Colors.black, width: 2)),
                                //       child: Center(
                                //         child: DropdownButtonHideUnderline(
                                //           child: DropdownButton<String>(
                                //             borderRadius: BorderRadius.circular(0),
                                //             items: ['10', '20', '50', 'all'.tr]
                                //                 .map((String value) {
                                //               return DropdownMenuItem<String>(
                                //                 value: value,
                                //                 child: Text(
                                //                   value,
                                //                   style: const TextStyle(
                                //                       fontSize: 12, color: Colors.grey),
                                //                 ),
                                //               );
                                //             }).toList(),
                                //             value: selectedNumberOfRows,
                                //             onChanged: (val) {
                                //               setState(() {
                                //                 selectedNumberOfRows = val!;
                                //                 if(val=='10'){
                                //                   listViewLength = cont.replenishmentList.length < 10
                                //                       ?Sizes.deviceHeight * (0.09 * cont.replenishmentList.length)
                                //                       : Sizes.deviceHeight * (0.09 * 10);
                                //                   selectedNumberOfRowsAsInt=cont.replenishmentList.length < 10? cont.replenishmentList.length:10;
                                //                 }if(val=='20'){
                                //                   listViewLength = cont.replenishmentList.length < 20
                                //                       ? Sizes.deviceHeight * (0.09 * cont.replenishmentList.length)
                                //                       : Sizes.deviceHeight * (0.09 * 20);
                                //                   selectedNumberOfRowsAsInt=cont.replenishmentList.length < 20? cont.replenishmentList.length:20;
                                //                 }if(val=='50'){
                                //                   listViewLength = cont.replenishmentList.length < 50
                                //                       ? Sizes.deviceHeight * (0.09 * cont.replenishmentList.length)
                                //                       : Sizes.deviceHeight * (0.09 * 50);
                                //                   selectedNumberOfRowsAsInt=cont.replenishmentList.length < 50? cont.replenishmentList.length:50;
                                //                 }if(val=='all'.tr){
                                //                   listViewLength = Sizes.deviceHeight * (0.09 * cont.replenishmentList.length);
                                //                   selectedNumberOfRowsAsInt= cont.replenishmentList.length;
                                //                 }
                                //               });
                                //             },
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //     gapW16,
                                //     Text(selectedNumberOfRows=='all'.tr?'${'all'.tr} of ${cont.replenishmentList.length}':'$start-$selectedNumberOfRows of ${cont.replenishmentList.length}',
                                //         style: const TextStyle(
                                //             fontSize: 13, color: Colors.black54)),
                                //     gapW16,
                                //     InkWell(
                                //         onTap: () {
                                //           setState(() {
                                //             isArrowBackClicked = !isArrowBackClicked;
                                //             isArrowForwardClicked = false;
                                //           });
                                //         },
                                //         child: Row(
                                //           children: [
                                //             Icon(
                                //               Icons.skip_previous,
                                //               color: isArrowBackClicked
                                //                   ? Colors.black87
                                //                   : Colors.grey,
                                //             ),
                                //             Icon(
                                //               Icons.navigate_before,
                                //               color: isArrowBackClicked
                                //                   ? Colors.black87
                                //                   : Colors.grey,
                                //             ),
                                //           ],
                                //         )),
                                //     gapW10,
                                //     InkWell(
                                //         onTap: () {
                                //           setState(() {
                                //             isArrowForwardClicked = !isArrowForwardClicked;
                                //             isArrowBackClicked = false;
                                //           });
                                //         },
                                //         child: Row(
                                //           children: [
                                //             Icon(
                                //               Icons.navigate_next,
                                //               color: isArrowForwardClicked
                                //                   ? Colors.black87
                                //                   : Colors.grey,
                                //             ),
                                //             Icon(
                                //               Icons.skip_next,
                                //               color: isArrowForwardClicked
                                //                   ? Colors.black87
                                //                   : Colors.grey,
                                //             ),
                                //           ],
                                //         )),
                                //     gapW40,
                                //   ],
                                // )
                              ],
                            ),
                          ),
                        ),],
                      ),
                    ),)
                ],
              ),
            ),
          );
        }
    );
  }

  String hoverTitle = '';
  String clickedTitle = '';
  bool isClicked = false;
  tableTitleWithOrderArrow(String text, double width, Function onClickedFunc) {
    return SizedBox(
      width: width,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              clickedTitle = text;
              hoverTitle = '';
              isClicked = !isClicked;
              onClickedFunc();
            });
          },
          onHover: (val) {
            if (val) {
              setState(() {
                hoverTitle = text;
              });
            } else {
              setState(() {
                hoverTitle = '';
              });
            }
          },
          child: clickedTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              isClicked
                  ? const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              )
                  : const Icon(
                Icons.arrow_drop_up,
                color: Colors.white,
              )
            ],
          )
              : hoverTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$text...',
                  style: TextStyle(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withAlpha((0.5 * 255).toInt()),
              )
            ],
          )
              : Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}



class MobileReplenishment extends StatefulWidget {
  const MobileReplenishment({super.key});

  @override
  State<MobileReplenishment> createState() => _MobileReplenishmentState();
}

class _MobileReplenishmentState extends State<MobileReplenishment> {
  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt=10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  final TransferController transferController = Get.find();
  bool isNumberOrderedUp=true;
  bool isCreationOrderedUp=true;


  String searchValue = '';
  Timer? searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(
        milliseconds:
        800); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
            () => searchOnStoppedTyping = Timer(duration, () => search(value)));
  }

  search(value) async {
    setState(() {
      searchValue = value;
    });
    await transferController.getAllReplenishmentFromBack();
  }
  @override
  void initState() {
    listViewLength = Sizes.deviceHeight * (0.09 * transferController.transfersList.length);
    transferController.searchInReplenishmentsController.clear();
    transferController.getAllReplenishmentFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransferController>(
        builder: (cont) {
          return Container(
            padding:  EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.width * 0.02),
            // height: MediaQuery.of(context).size.height * 0.85,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(text: 'replenishment'.tr),
                      ReusableButtonWithColor(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 45,
                        onTapFunction: () {
                          homeController.selectedTab.value = 'replenish_transfer';
                        },
                        btnText: 'create_new_replenishment'.tr,
                      ),
                    ],
                  ),
                  gapH24,
                  SizedBox(
                    child: ReusableSearchTextField(
                      hint: '${"search".tr}...',
                      textEditingController: cont.searchInReplenishmentsController,
                      onChangedFunc: (val) {
                        _onChangeHandler(val);
                      },
                      validationFunc: (val) {},
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  ReusableChip(
                    name: 'all_transfers'.tr,
                    isDesktop: false,
                  ),
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
                                  children:[
                                    tableTitleWithOrderArrow('number'.tr,
                                        150, () {
                                          setState(() {
                                            isNumberOrderedUp=!isNumberOrderedUp;
                                            isNumberOrderedUp
                                                ? cont.replenishmentList.sort((a, b) => a['transferNumber'].compareTo(b['transferNumber']))
                                                : cont.replenishmentList.sort((a, b) => b['transferNumber'].compareTo(a['transferNumber']));
                                          });
                                        }),
                                    tableTitleWithOrderArrow('creation_date'.tr,
                                        150, () {
                                          setState(() {
                                            isCreationOrderedUp=!isCreationOrderedUp;
                                            isCreationOrderedUp?
                                            cont.replenishmentList.sort((a, b) => a['date'].compareTo(b['date']))
                                                :cont.replenishmentList.sort((a, b) => b['date'].compareTo(a['date']));
                                          });
                                        }),
                                    TableTitle(
                                      text: 'dest_whse'.tr,
                                      width:150
                                    ),
                                    TableTitle(
                                      text: 'task'.tr,
                                      width:150
                                    ),
                                    TableTitle(
                                      text: 'status'.tr,
                                      width: 150
                                    ),
                                    // TableTitle(
                                    //   text: 'more'.tr,
                                    //   width: MediaQuery.of(context).size.width * 0.03,
                                    // ),
                                  ],
                                ),
                              ),
                              cont.isReplenishmentFetched
                                  ?Container(
                                color: Colors.white,
                                child: Column(
                                  children: List.generate(
                                    cont.replenishmentList.length,
                                        (index) =>Column(
                                      children: [
                                        ReplenishmentAsRowInTable(
                                          info:  cont.replenishmentList[index],
                                          index: index,
                                          isDesktop: false,
                                        ),
                                        const Divider()
                                      ],
                                    ),
                                  ),
                                ),
                              ):const CircularProgressIndicator(),

                            ],
                          ),
                        ),
                      ),],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }

  String hoverTitle = '';
  String clickedTitle = '';
  bool isClicked = false;
  tableTitleWithOrderArrow(String text, double width, Function onClickedFunc) {
    return SizedBox(
      width: width,
      child: Center(
        child: InkWell(
          onTap: () {
            setState(() {
              clickedTitle = text;
              hoverTitle = '';
              isClicked = !isClicked;
              onClickedFunc();
            });
          },
          onHover: (val) {
            if (val) {
              setState(() {
                hoverTitle = text;
              });
            } else {
              setState(() {
                hoverTitle = '';
              });
            }
          },
          child: clickedTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text.length>8?'${text.substring(0,8)}...':text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              isClicked
                  ? const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              )
                  : const Icon(
                Icons.arrow_drop_up,
                color: Colors.white,
              )
            ],
          )
              : hoverTitle == text
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${text.length>7?text.substring(0,6):text}...',
                  style: TextStyle(
                      color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      fontWeight: FontWeight.bold)),
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white.withAlpha((0.5 * 255).toInt()),
              )
            ],
          )
              : Text(text,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}