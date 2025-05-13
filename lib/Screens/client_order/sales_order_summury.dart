import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Backend/Quotations/delete_quotation.dart';
import '../../Backend/Quotations/get_quotations.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';

class ClientOrderSummary extends StatefulWidget {
  const ClientOrderSummary({super.key});

  @override
  State<ClientOrderSummary> createState() => _ClientOrderState();
}

class _ClientOrderState extends State<ClientOrderSummary> {
  final TextEditingController filterController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  GlobalKey accMoreKey = GlobalKey();
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

  List clientOrdersList=[];
  bool isQuotationsFetched = false;
  getAllQuotationsFromBack()async{
    var p=await getAllQuotations();
    setState(() {
      clientOrdersList.addAll(p);
      isQuotationsFetched=true;
      listViewLength = clientOrdersList.length < 10
          ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
          : Sizes.deviceHeight * (0.09 * 10);
    });
  }
  @override
  void initState() {
    listViewLength = clientOrdersList.length < 10
        ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
        : Sizes.deviceHeight * (0.09 * 10);
    getAllQuotationsFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
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
                // PageTitle(text: 'quotations'.tr),
                Text("sales_orders".tr,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Primary.primary)),
                ReusableButtonWithColor(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: 45,
                  onTapFunction: () {
                    homeController.selectedTab.value = 'new_sales_order';
                  },
                  // btnText: 'create_new_quotation'.tr,
                  btnText: 'create_new_sales_order'.tr,
                ),
              ],
            ),
            gapH24,
            SizedBox(
              // width: MediaQuery.of(context).size.width * 0.59,
              child: ReusableSearchTextField(
                hint: '${"search".tr}...',
                textEditingController: searchController,
                onChangedFunc: () {},
                validationFunc: () {},
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const ReusableChip(
              // name: 'all_quotations'.tr,
              name: 'All Sales Orders',
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
                    children: [
                      tableTitleWithOrderArrow('number'.tr,
                          MediaQuery.of(context).size.width * 0.09, () {
                            setState(() {
                              isNumberOrderedUp=!isNumberOrderedUp;
                              isNumberOrderedUp
                                  ? clientOrdersList.sort((a, b) => a['clientOrderNumber'].compareTo(b['clientOrderNumber']))
                                  : clientOrdersList.sort((a, b) => b['clientOrderNumber'].compareTo(a['clientOrderNumber']));
                            });
                          }),
                      tableTitleWithOrderArrow('creation'.tr,
                          MediaQuery.of(context).size.width * 0.09, () {
                            setState(() {
                              isCreationOrderedUp=!isCreationOrderedUp;
                              isCreationOrderedUp?
                              clientOrdersList.sort((a, b) => a['createdAtDate'].compareTo(b['createdAtDate']))
                                  :clientOrdersList.sort((a, b) => b['createdAtDate'].compareTo(a['createdAtDate']));
                            });
                          }),
                      tableTitleWithOrderArrow('customer'.tr,
                          MediaQuery.of(context).size.width * 0.09, () {
                            setState(() {
                              isCustomerOrderedUp=!isCustomerOrderedUp;
                              isCustomerOrderedUp?
                              clientOrdersList.sort((a, b) => '${a['client']['name']}' .compareTo('${b['client']['name']}'))
                                  : clientOrdersList.sort((a, b) => '${b['client']['name']}'.compareTo('${a['client']['name']}' ));
                            });
                          }),
                      tableTitleWithOrderArrow('salesperson'.tr,
                          MediaQuery.of(context).size.width * 0.09, () {
                            setState(() {
                              isSalespersonOrderedUp=!isSalespersonOrderedUp;
                              isSalespersonOrderedUp?
                              clientOrdersList.sort((a, b) => a['salesperson'].compareTo(b['salesperson'])):
                              clientOrdersList.sort((a, b) => b['salesperson'].compareTo(a['salesperson']));
                            });
                          }),
                      TableTitle(
                        text: 'task'.tr,
                        width: MediaQuery.of(context).size.width * 0.085,
                      ),
                      TableTitle(
                        text: 'total'.tr,
                        width: MediaQuery.of(context).size.width * 0.085,
                      ),
                      TableTitle(
                        text: 'status'.tr,
                        width: MediaQuery.of(context).size.width * 0.085,
                      ),
                      TableTitle(
                        text: 'more_options'.tr,
                        width: MediaQuery.of(context).size.width * 0.13,
                      ),
                    ],
                  ),
                ),
                isQuotationsFetched
                    ?Container(
                  color: Colors.white,
                  height: listViewLength,
                  child: ListView.builder(
                    itemCount:clientOrdersList.length>9?selectedNumberOfRowsAsInt:clientOrdersList.length,
                    itemBuilder: (context, index) => Column(
                      children: [
                        Row(
                          children: [
                            QuotationAsRowInTable(
                              info: clientOrdersList[index],
                              index: index,
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    ),
                  ),
                ):const CircularProgressIndicator(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${'rows_per_page'.tr}:  ',
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54),
                    ),
                    Container(
                      width: 60,
                      height: 30,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black, width: 2)),
                      child: Center(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            borderRadius: BorderRadius.circular(0),
                            items: ['10', '20', '50', 'all'.tr]
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              );
                            }).toList(),
                            value: selectedNumberOfRows,
                            onChanged: (val) {
                              setState(() {
                                selectedNumberOfRows = val!;
                                if(val=='10'){
                                  listViewLength = clientOrdersList.length < 10
                                      ?Sizes.deviceHeight * (0.09 * clientOrdersList.length)
                                      : Sizes.deviceHeight * (0.09 * 10);
                                  selectedNumberOfRowsAsInt=clientOrdersList.length < 10? clientOrdersList.length:10;
                                }if(val=='20'){
                                  listViewLength = clientOrdersList.length < 20
                                      ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
                                      : Sizes.deviceHeight * (0.09 * 20);
                                  selectedNumberOfRowsAsInt=clientOrdersList.length < 20? clientOrdersList.length:20;
                                }if(val=='50'){
                                  listViewLength = clientOrdersList.length < 50
                                      ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
                                      : Sizes.deviceHeight * (0.09 * 50);
                                  selectedNumberOfRowsAsInt=clientOrdersList.length < 50? clientOrdersList.length:50;
                                }if(val=='all'.tr){
                                  listViewLength = Sizes.deviceHeight * (0.09 * clientOrdersList.length);
                                  selectedNumberOfRowsAsInt= clientOrdersList.length;
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    gapW16,
                    Text(selectedNumberOfRows=='all'.tr?'${'all'.tr} of ${clientOrdersList.length}':'$start-$selectedNumberOfRows of ${clientOrdersList.length}',
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54)),
                    gapW16,
                    InkWell(
                        onTap: () {
                          setState(() {
                            isArrowBackClicked = !isArrowBackClicked;
                            isArrowForwardClicked = false;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.skip_previous,
                              color: isArrowBackClicked
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                            Icon(
                              Icons.navigate_before,
                              color: isArrowBackClicked
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ],
                        )),
                    gapW10,
                    InkWell(
                        onTap: () {
                          setState(() {
                            isArrowForwardClicked = !isArrowForwardClicked;
                            isArrowBackClicked = false;
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.navigate_next,
                              color: isArrowForwardClicked
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                            Icon(
                              Icons.skip_next,
                              color: isArrowForwardClicked
                                  ? Colors.black87
                                  : Colors.grey,
                            ),
                          ],
                        )),
                    gapW40,
                  ],
                )
              ],
            ),
          ],
        ),
      ),
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

class ReusableChip extends StatelessWidget {
  const ReusableChip({super.key, required this.name, this.isDesktop=true});
  final String name;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: ClipPath(
        clipper: const ShapeBorderClipper(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9)))),
        child: Container(
          width:isDesktop? MediaQuery.of(context).size.width * 0.09: MediaQuery.of(context).size.width * 0.2,
          height: MediaQuery.of(context).size.height * 0.07,
          // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          decoration: BoxDecoration(
              color: Primary.p20,
              border: Border(
                top: BorderSide(color: Primary.primary, width: 3),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                  spreadRadius: 9,
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                )
              ]),
          child: Center(
            child: Text(
              name,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Primary.primary),
            ),
          ),
        ),
      ),
    );
  }
}

class QuotationAsRowInTable extends StatelessWidget {
  const QuotationAsRowInTable(
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
        children: [
          TableItem(
            text: '${info['clientOrderNumber'] ?? ''}',
            width:isDesktop? MediaQuery.of(context).size.width * 0.09 :150,
          ),
          TableItem(
            text: '${info['createdAtDate'] ?? ''}',
            width:isDesktop? MediaQuery.of(context).size.width * 0.09 :150,
          ),
          TableItem(
            text:info['client']==null?'': '${info['client']['name'] ?? ''}',
            width: isDesktop? MediaQuery.of(context).size.width * 0.09 :150,
          ),
          TableItem(
            text: '${info['salesperson'] ?? ''}',
            width: isDesktop? MediaQuery.of(context).size.width * 0.09 :150,
          ),
          TableItem(
            text: '${info['task'] ?? 'No Records'}',
            width:isDesktop? MediaQuery.of(context).size.width * 0.085 :150,
          ),
          TableItem(
            text: '${info['total'] ?? ''}',
            width: isDesktop? MediaQuery.of(context).size.width * 0.085 :150,
          ),
          SizedBox(
            width:isDesktop? MediaQuery.of(context).size.width * 0.085 :150,
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




class MobileClientOrderSummary extends StatefulWidget {
  const MobileClientOrderSummary({super.key});

  @override
  State<MobileClientOrderSummary> createState() => _MobileClientOrderSummaryState();
}

class _MobileClientOrderSummaryState extends State<MobileClientOrderSummary> {
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

  List clientOrdersList=[];
  bool isQuotationsFetched = false;
  getAllQuotationsFromBack()async{
    var p=await getAllQuotations();
    setState(() {
      clientOrdersList.addAll(p);
      isQuotationsFetched=true;
      listViewLength = clientOrdersList.length < 10
          ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
          : Sizes.deviceHeight * (0.09 * 10);
    });
  }
  @override
  void initState() {
    listViewLength = clientOrdersList.length < 10
        ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
        : Sizes.deviceHeight * (0.09 * 10);
    getAllQuotationsFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal:  MediaQuery.of(context).size.width * 0.02),
      height: MediaQuery.of(context).size.height * 0.8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PageTitle(text: 'quotations'.tr),
            Text("Sales Orders",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Primary.primary)),
            gapH10,
            ReusableButtonWithColor(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 45,
              onTapFunction: () {
                homeController.selectedTab.value = 'new_quotation';
              },
              // btnText: 'create_new_quotation'.tr,
              btnText: 'Create New Sales Order',
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
            const ReusableChip(
              // name: 'all_quotations'.tr,
              name: 'All Sales Orders',
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
                                            ? clientOrdersList.sort((a, b) => a['clientOrderNumber'].compareTo(b['clientOrderNumber']))
                                            : clientOrdersList.sort((a, b) => b['clientOrderNumber'].compareTo(a['clientOrderNumber']));
                                      });
                                    }),
                                tableTitleWithOrderArrow('creation'.tr,
                                    150, () {
                                      setState(() {
                                        isCreationOrderedUp=!isCreationOrderedUp;
                                        isCreationOrderedUp?
                                        clientOrdersList.sort((a, b) => a['createdAtDate'].compareTo(b['createdAtDate']))
                                            :clientOrdersList.sort((a, b) => b['createdAtDate'].compareTo(a['createdAtDate']));
                                      });
                                    }),
                                tableTitleWithOrderArrow('customer'.tr,
                                    150, () {
                                      setState(() {
                                        isCustomerOrderedUp=!isCustomerOrderedUp;
                                        isCustomerOrderedUp?
                                        clientOrdersList.sort((a, b) => '${a['client']['name']}' .compareTo('${b['client']['name']}'))
                                            : clientOrdersList.sort((a, b) => '${b['client']['name']}'.compareTo('${a['client']['name']}' ));
                                      });
                                    }),
                                tableTitleWithOrderArrow('salesperson'.tr,
                                    150, () {
                                      setState(() {
                                        isSalespersonOrderedUp=!isSalespersonOrderedUp;
                                        isSalespersonOrderedUp?
                                        clientOrdersList.sort((a, b) => a['salesperson'].compareTo(b['salesperson'])):
                                        clientOrdersList.sort((a, b) => b['salesperson'].compareTo(a['salesperson']));
                                      });
                                    }),
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
                          isQuotationsFetched
                              ?Container(
                            color: Colors.white,
                            child: Column(
                              children: List.generate(
                                clientOrdersList.length>9?selectedNumberOfRowsAsInt:clientOrdersList.length,
                                    (index) =>Column(
                                  children: [
                                    Row(
                                      children: [
                                        QuotationAsRowInTable(
                                          info: clientOrdersList[index],
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
                                                    var res= await deleteQuotation('${clientOrdersList[index]['id']}');
                                                    var p=json.decode(res.body);
                                                    if(res.statusCode==200){
                                                      CommonWidgets.snackBar('Success', p['message']);
                                                      setState(() {
                                                        selectedNumberOfRowsAsInt=selectedNumberOfRowsAsInt-1;
                                                        clientOrdersList.removeAt(index);
                                                        listViewLength=listViewLength-0.09;
                                                      });
                                                    }else{
                                                      CommonWidgets.snackBar('error',
                                                          p['message'] );
                                                    }
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${'rows_per_page'.tr}:  ',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black54),
                              ),
                              Container(
                                width: 60,
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.black, width: 2)),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      borderRadius: BorderRadius.circular(0),
                                      items: ['10', '20', '50', 'all'.tr]
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(
                                            value,
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                        );
                                      }).toList(),
                                      value: selectedNumberOfRows,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedNumberOfRows = val!;
                                          if(val=='10'){
                                            listViewLength = clientOrdersList.length < 10
                                                ?Sizes.deviceHeight * (0.09 * clientOrdersList.length)
                                                : Sizes.deviceHeight * (0.09 * 10);
                                            selectedNumberOfRowsAsInt=clientOrdersList.length < 10? clientOrdersList.length:10;
                                          }if(val=='20'){
                                            listViewLength = clientOrdersList.length < 20
                                                ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
                                                : Sizes.deviceHeight * (0.09 * 20);
                                            selectedNumberOfRowsAsInt=clientOrdersList.length < 20? clientOrdersList.length:20;
                                          }if(val=='50'){
                                            listViewLength = clientOrdersList.length < 50
                                                ? Sizes.deviceHeight * (0.09 * clientOrdersList.length)
                                                : Sizes.deviceHeight * (0.09 * 50);
                                            selectedNumberOfRowsAsInt=clientOrdersList.length < 50? clientOrdersList.length:50;
                                          }if(val=='all'.tr){
                                            listViewLength = Sizes.deviceHeight * (0.09 * clientOrdersList.length);
                                            selectedNumberOfRowsAsInt= clientOrdersList.length;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              gapW16,
                              Text(selectedNumberOfRows=='all'.tr?'${'all'.tr} of ${clientOrdersList.length}':'$start-$selectedNumberOfRows of ${clientOrdersList.length}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black54)),
                              gapW16,
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      isArrowBackClicked = !isArrowBackClicked;
                                      isArrowForwardClicked = false;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.skip_previous,
                                        color: isArrowBackClicked
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                      Icon(
                                        Icons.navigate_before,
                                        color: isArrowBackClicked
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ],
                                  )),
                              gapW10,
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      isArrowForwardClicked = !isArrowForwardClicked;
                                      isArrowBackClicked = false;
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.navigate_next,
                                        color: isArrowForwardClicked
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                      Icon(
                                        Icons.skip_next,
                                        color: isArrowForwardClicked
                                            ? Colors.black87
                                            : Colors.grey,
                                      ),
                                    ],
                                  )),
                              gapW40,
                            ],
                          )
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


