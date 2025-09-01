import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ProductsBackend/get_an_item.dart';
import 'package:rooster_app/Locale_Memory/save_user_info_locally.dart';
import '../../Backend/ClientsBackend/delete_client.dart';
import '../../Backend/ClientsBackend/get_client_create_info.dart';
import '../../Backend/ClientsBackend/update_client.dart';
import '../../Backend/get_cities_of_a_specified_country.dart';
import '../../Backend/get_countries.dart';
import '../../Controllers/client_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/TransferWidgets/reusable_show_info_card.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_more.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';
import '../Products/products_page.dart';
import '../PurchaseInvoice/purchase_invoice_summary.dart';
import 'add_new_client.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final TextEditingController filterController = TextEditingController();
  FilterItems? selectedFilterItem;
  // GlobalKey filterKey = GlobalKey();
  bool isGridClicked = false;

  final HomeController homeController = Get.find();
  List tabsList = ['general', 'transactions'];
  int selectedTabIndex = 0;
  double generalListViewLength = 100;
  double transactionListViewLength = 100;
  String selectedNumberOfRowsInGeneralTab = '10';
  int selectedNumberOfRowsInGeneralTabAsInt = 10;
  String selectedNumberOfRowsInTransactionsTab = '10';
  int selectedNumberOfRowsInTransactionsTabAsInt = 10;
  int startInGeneral = 1;
  bool isArrowBackClickedInGeneral = false;
  bool isArrowForwardClickedInGeneral = false;
  int startInTransactions = 1;
  bool isArrowBackClickedInTransactions = false;
  bool isArrowForwardClickedInTransactions = false;

  // TextEditingController searchController = TextEditingController();
  // GlobalKey accMoreKey = GlobalKey();

  ClientController clientController = Get.find();

  String searchValue = '';
  Timer? searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
      () => searchOnStoppedTyping = Timer(duration, () => search(value)),
    );
  }

  search(value) async {
    if (selectedTabIndex == 0) {
      setState(() {
        searchValue = value;
        clientController.setIsClientsFetched(false);
        clientController.setAccounts([]);
      });
      await clientController.getAllClientsFromBack();
    } else {
      setState(() {
        searchValue = value;
        clientController.setIsTransactionsFetched(false);
        clientController.setTransactionsOrders([]);
        clientController.setTransactionsQuotations([]);
      });
      await clientController.getTransactionsFromBack();
    }
  }

  String primaryCurr = '';
  getCurrency() async {
    var curr = await getCompanyPrimaryCurrencyFromPref();
    primaryCurr = curr;
  }

  @override
  void initState() {
    clientController.getAllUsersSalesPersonFromBack();
    clientController.selectedSalesPerson = '';
    clientController.selectedSalesPersonId = 0;
    clientController.salesPersonController.text = '';
    getCurrency();
    // generalListViewLength = accounts.length < 10
    //     ? Sizes.deviceHeight * (0.09 * accounts.length)
    //     : Sizes.deviceHeight * (0.09 * 10);
    // selectedNumberOfRowsInGeneralTabAsInt =
    //     accounts.length < 10 ? accounts.length : 10;

    // transactionListViewLength = transactions.length < 10
    //     ? Sizes.deviceHeight * (0.09 * transactions.length)
    //     : Sizes.deviceHeight * (0.09 * 10);
    // selectedNumberOfRowsInTransactionsTabAsInt =
    //     transactions.length < 10 ? transactions.length : 10;
    // clientController.getAllOrdersFromBack();
    clientController.getAllClientsFromBack();
    selectedNumberOfRowsInGeneralTabAsInt =
        clientController.accounts.length < 10
            ? clientController.accounts.length
            : 10;
    generalListViewLength =
        clientController.accounts.length < 10
            ? Sizes.deviceHeight * (0.09 * clientController.accounts.length)
            : Sizes.deviceHeight * (0.09 * 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        child: GetBuilder<ClientController>(
          builder: (clientCont) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(text: 'list_of_clients'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        homeController.selectedTab.value = 'add_new_client';
                      },
                      btnText: 'create_new_client'.tr,
                    ),
                  ],
                ),
                gapH24,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ReusableSearchTextField(
                        hint: '${"search".tr}...',
                        textEditingController: clientCont.searchController,
                        onChangedFunc: (val) {
                          _onChangeHandler(val);
                        },
                        validationFunc: (val) {},
                      ),
                    ),

                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       isGridClicked = !isGridClicked;
                    //     });
                    //   },
                    //   child: Icon(
                    //     Icons.grid_view_outlined,
                    //     color: isGridClicked
                    //         ? Primary.primary
                    //         : TypographyColor.textTable,
                    //   ),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       isGridClicked = !isGridClicked;
                    //     });
                    //   },
                    //   child: Icon(
                    //     Icons.format_list_bulleted,
                    //     color: isGridClicked
                    //         ? TypographyColor.textTable
                    //         : Primary.primary,
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 0.0,
                      direction: Axis.horizontal,
                      children:
                          tabsList
                              .map(
                                (element) => _buildTabChipItem(
                                  element,
                                  // element['id'],
                                  // element['name'],
                                  tabsList.indexOf(element),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                selectedTabIndex == 0
                    ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Primary.primary,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                          child: GetBuilder<HomeController>(
                            builder: (homeCont) {
                              double bigWidth =
                                  homeCont.isMenuOpened
                                      ? MediaQuery.of(context).size.width * 0.25
                                      : MediaQuery.of(context).size.width *
                                          0.28;
                              double smallWidth =
                                  homeCont.isMenuOpened
                                      ? MediaQuery.of(context).size.width * 0.09
                                      : MediaQuery.of(context).size.width *
                                          0.12;
                              return Row(
                                children: [
                                  TableTitle(
                                    text: 'code'.tr,
                                    isCentered: false,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'name'.tr,
                                    isCentered: false,
                                    width: bigWidth,
                                  ),
                                  TableTitle(
                                    text: 'mobile_number'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'balance_usd'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: '${'balance'.tr} $primaryCurr',
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'more_options'.tr,
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.13,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        clientCont.isClientsFetched
                            ? Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: ListView.builder(
                                itemCount:
                                    clientCont
                                        .accounts
                                        .length, // selectedNumberOfRowsInGeneralTabAsInt,
                                itemBuilder:
                                    (context, index) => Column(
                                      children: [
                                        Container(
                                          color:
                                              clientCont.selectedClientId ==
                                                      '${clientCont.accounts[index]['id']}'
                                                  ? Primary.primary.withAlpha(
                                                    (0.5 * 255).toInt(),
                                                  )
                                                  : clientCont
                                                          .hoveredClientId ==
                                                      '${clientCont.accounts[index]['id']}'
                                                  ? Primary.primary.withAlpha(
                                                    (0.2 * 255).toInt(),
                                                  )
                                                  : Colors.white,
                                          child: Row(
                                            children: [
                                              ClientAsRowInTable(
                                                info:
                                                    clientCont.accounts[index],
                                                index: index,
                                              ),
                                              SizedBox(
                                                width:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.13,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.03,
                                                      child: ReusableMore(
                                                        itemsList: [
                                                          PopupMenuItem<String>(
                                                            value: '1',
                                                            onTap: () async {
                                                              var res =
                                                                  await deleteClient(
                                                                    '${clientCont.accounts[index]['id']}',
                                                                  );
                                                              var p = json
                                                                  .decode(
                                                                    res.body,
                                                                  );
                                                              if (res.statusCode ==
                                                                  200) {
                                                                CommonWidgets.snackBar(
                                                                  'Success',
                                                                  p['message'],
                                                                );
                                                                setState(() {
                                                                  selectedNumberOfRowsInGeneralTabAsInt =
                                                                      selectedNumberOfRowsInGeneralTabAsInt -
                                                                      1;
                                                                  clientCont
                                                                      .removeFromAccounts(
                                                                        index,
                                                                      );
                                                                  generalListViewLength =
                                                                      generalListViewLength -
                                                                      0.09;
                                                                });
                                                              } else {
                                                                CommonWidgets.snackBar(
                                                                  'error',
                                                                  p['message'],
                                                                );
                                                              }
                                                            },
                                                            child: Text(
                                                              'delete'.tr,
                                                            ),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            value: '2',
                                                            onTap: () async {
                                                              showDialog<
                                                                String
                                                              >(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (
                                                                      BuildContext
                                                                      context,
                                                                    ) => AlertDialog(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      shape: const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.all(
                                                                          Radius.circular(
                                                                            9,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      elevation:
                                                                          0,
                                                                      content: UpdateClientDialog(
                                                                        index:
                                                                            index,
                                                                        info:
                                                                            clientCont.accounts[index],
                                                                      ),
                                                                    ),
                                                              );
                                                            },
                                                            child: Text(
                                                              'update'.tr,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                              ),
                            )
                            : const CircularProgressIndicator(),
                      ],
                    )
                    : Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Primary.primary,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                          child: GetBuilder<HomeController>(
                            builder: (homeCont) {
                              double bigWidth =
                                  homeCont.isMenuOpened
                                      ? MediaQuery.of(context).size.width * 0.12
                                      : MediaQuery.of(context).size.width *
                                          0.16;
                              double smallWidth =
                                  homeCont.isMenuOpened
                                      ? MediaQuery.of(context).size.width * 0.09
                                      : MediaQuery.of(context).size.width *
                                          0.11;
                              return Row(
                                children: [
                                  TableTitle(
                                    text: 'date'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'serial'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'manual_ref'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'doctype'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: 'transaction_label'.tr,
                                    width: smallWidth,
                                  ),
                                  TableTitle(
                                    text: '${'value'.tr} (USD)',
                                    width: bigWidth,
                                  ),
                                  // TableTitle(
                                  //   text: 'Debit'.tr,
                                  //   width: MediaQuery.of(context).size.width * 0.09,
                                  // ),
                                  // TableTitle(
                                  //   text: 'Credit'.tr,
                                  //   width: MediaQuery.of(context).size.width * 0.09,
                                  // ),
                                  TableTitle(
                                    text: '${'value'.tr} (other currency)',
                                    width: bigWidth,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        clientCont.isTransactionsFetched
                            ? Container(
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.4,
                              child: ListView.builder(
                                itemCount:
                                    clientCont.transactionsOrders.length +
                                    clientCont.transactionsQuotations.length,
                                itemBuilder:
                                    (context, index) => Column(
                                      children: [
                                        index <
                                                clientCont
                                                    .transactionsOrders
                                                    .length
                                            ? TransactionOrderAsRowInTable(
                                              info:
                                                  clientCont
                                                      .transactionsOrders[index],
                                              index: index,
                                            )
                                            : TransactionQuotationsAsRowInTable(
                                              info:
                                                  clientCont
                                                      .transactionsQuotations[index -
                                                      clientCont
                                                          .transactionsOrders
                                                          .length],
                                              index:
                                                  index -
                                                  clientCont
                                                      .transactionsOrders
                                                      .length,
                                            ),
                                        const Divider(),
                                      ],
                                    ),
                              ),
                            )
                            : loading(),
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
                        //           border:
                        //               Border.all(color: Colors.black, width: 2)),
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
                        //             value: selectedNumberOfRowsInTransactionsTab,
                        //             onChanged: (val) {
                        //               setState(() {
                        //                 selectedNumberOfRowsInTransactionsTab =
                        //                     val!;
                        //                 if (val == '10') {
                        //                   transactionListViewLength =
                        //                       transactions.length < 10
                        //                           ? Sizes.deviceHeight *
                        //                               (0.09 * transactions.length)
                        //                           : Sizes.deviceHeight *
                        //                               (0.09 * 10);
                        //                   selectedNumberOfRowsInTransactionsTabAsInt =
                        //                       transactions.length < 10
                        //                           ? transactions.length
                        //                           : 10;
                        //                 }
                        //                 if (val == '20') {
                        //                   transactionListViewLength =
                        //                       transactions.length < 20
                        //                           ? Sizes.deviceHeight *
                        //                               (0.09 * transactions.length)
                        //                           : Sizes.deviceHeight *
                        //                               (0.09 * 20);
                        //                   selectedNumberOfRowsInTransactionsTabAsInt =
                        //                       transactions.length < 20
                        //                           ? transactions.length
                        //                           : 20;
                        //                 }
                        //                 if (val == '50') {
                        //                   transactionListViewLength =
                        //                       transactions.length < 50
                        //                           ? Sizes.deviceHeight *
                        //                               (0.09 * transactions.length)
                        //                           : Sizes.deviceHeight *
                        //                               (0.09 * 50);
                        //                   selectedNumberOfRowsInTransactionsTabAsInt =
                        //                       transactions.length < 50
                        //                           ? transactions.length
                        //                           : 50;
                        //                 }
                        //                 if (val == 'all'.tr) {
                        //                   transactionListViewLength =
                        //                       Sizes.deviceHeight *
                        //                           (0.09 * transactions.length);
                        //                   selectedNumberOfRowsInTransactionsTabAsInt =
                        //                       transactions.length;
                        //                 }
                        //               });
                        //             },
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //     gapW16,
                        //     Text(
                        //         selectedNumberOfRowsInGeneralTab == 'all'.tr
                        //             ? '${'all'.tr} of ${clientCont.accounts.length}'
                        //             : '$startInTransactions-$selectedNumberOfRowsInTransactionsTab of ${transactions.length}',
                        //         style: const TextStyle(
                        //             fontSize: 13, color: Colors.black54)),
                        //     gapW16,
                        //     InkWell(
                        //         onTap: () {
                        //           setState(() {
                        //             isArrowBackClickedInTransactions =
                        //                 !isArrowBackClickedInTransactions;
                        //             isArrowForwardClickedInTransactions = false;
                        //           });
                        //         },
                        //         child: Row(
                        //           children: [
                        //             Icon(
                        //               Icons.skip_previous,
                        //               color: isArrowBackClickedInTransactions
                        //                   ? Colors.black87
                        //                   : Colors.grey,
                        //             ),
                        //             Icon(
                        //               Icons.navigate_before,
                        //               color: isArrowBackClickedInTransactions
                        //                   ? Colors.black87
                        //                   : Colors.grey,
                        //             ),
                        //           ],
                        //         )),
                        //     gapW10,
                        //     InkWell(
                        //         onTap: () {
                        //           setState(() {
                        //             isArrowForwardClickedInTransactions =
                        //                 !isArrowForwardClickedInTransactions;
                        //             isArrowBackClickedInTransactions = false;
                        //           });
                        //         },
                        //         child: Row(
                        //           children: [
                        //             Icon(
                        //               Icons.navigate_next,
                        //               color: isArrowForwardClickedInTransactions
                        //                   ? Colors.black87
                        //                   : Colors.grey,
                        //             ),
                        //             Icon(
                        //               Icons.skip_next,
                        //               color: isArrowForwardClickedInTransactions
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return InkWell(
          onTap:
              cont.selectedClientId == '' && index == 1
                  ? null
                  : () {
                    setState(() {
                      clientController.searchController.clear();
                      clientController.getAllClientsFromBack();
                      // clientController.getAllOrdersFromBack();
                      selectedTabIndex = index;
                    });
                    if (index == 1) {
                      cont.getTransactionsFromBack();
                    }
                  },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
            ),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.09,
              // height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              decoration: BoxDecoration(
                color: selectedTabIndex == index ? Primary.p20 : Colors.white,
                border:
                    selectedTabIndex == index
                        ? Border(
                          top: BorderSide(color: Primary.primary, width: 3),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                    spreadRadius: 9,
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Primary.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ClientAsRowInTable extends StatelessWidget {
  const ClientAsRowInTable({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (clientCont) {
        return InkWell(
          onTap: () {
            clientCont.setSelectedClientId(
              '${clientCont.accounts[index]['id']}',
            );
            clientCont.setSelectedClient(clientCont.accounts[index]);
          },
          onHover: (value) {
            if (value) {
              clientCont.setHoveredClientId(
                '${clientCont.accounts[index]['id']}',
              );
            } else {
              clientCont.setHoveredClientId('');
            }
          },
          onDoubleTap:
              info['name'] == 'cash customer'
                  ? null
                  : () {
                    showDialog<String>(
                      context: context,
                      builder:
                          (BuildContext context) => AlertDialog(
                            backgroundColor: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(9),
                              ),
                            ),
                            elevation: 0,
                            content: UpdateClientDialog(
                              index: index,
                              info: info,
                            ),
                          ),
                    );
                  },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 5 : 0,
              vertical: 10,
            ),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
            child: GetBuilder<HomeController>(
              builder: (homeCont) {
                double bigWidth =
                    homeCont.isMenuOpened
                        ? MediaQuery.of(context).size.width * 0.25
                        : MediaQuery.of(context).size.width * 0.28;
                double smallWidth =
                    homeCont.isMenuOpened
                        ? MediaQuery.of(context).size.width * 0.09
                        : MediaQuery.of(context).size.width * 0.12;
                return Row(
                  children: [
                    TableItem(
                      isCentered: false,
                      text: '${info['clientNumber'] ?? ''}',
                      width: isDesktop ? smallWidth : 140,
                    ),
                    TableItem(
                      isCentered: false,
                      text: '${info['name'] ?? ''}',
                      width: isDesktop ? bigWidth : 140,
                    ),
                    TableItem(
                      text:
                          info['mobileNumber'] != null
                              ? '(${info['mobileCode']})-${info['mobileNumber']}'
                              : '',
                      width: isDesktop ? smallWidth : 140,
                    ),
                    TableItem(
                      text: '${info['balance_usd'] ?? ''}',
                      width: isDesktop ? smallWidth : 140,
                    ),
                    TableItem(
                      text: '${info['balance_lbp'] ?? ''}',
                      width: isDesktop ? smallWidth : 140,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class TransactionOrderAsRowInTable extends StatelessWidget {
  const TransactionOrderAsRowInTable({
    super.key,
    required this.info,
    required this.index,
  });
  final Map info;
  final int index;
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return InkWell(
      onTap: () {
        showDialog<String>(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                elevation: 0,
                content: UpdateTransactionOrderDialog(index: index),
              ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: GetBuilder<HomeController>(
          builder: (homeCont) {
            double bigWidth =
                homeCont.isMenuOpened
                    ? MediaQuery.of(context).size.width * 0.12
                    : MediaQuery.of(context).size.width * 0.16;
            double smallWidth =
                homeCont.isMenuOpened
                    ? MediaQuery.of(context).size.width * 0.09
                    : MediaQuery.of(context).size.width * 0.11;
            return Row(
              children: [
                TableItem(
                  text: '${info['date'] ?? ''}',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: '${info['orderNumber'] ?? ''}',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: '',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: 'order',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: '', // '${info['transaction_label'] ?? ''}',
                  width: homeController.isMobile.value ? 250 : smallWidth,
                ),
                TableItem(
                  text: numberWithComma(
                    '${info['primaryCurrencyTotal'] ?? ''}',
                  ),
                  width: homeController.isMobile.value ? 150 : bigWidth,
                ),
                TableItem(
                  text:
                      '${info['posCurrencyTotal'] != null ? numberWithComma('${info['posCurrencyTotal']}') : ''} '
                      '${info['posCurrency'] != null ? info['posCurrency']['name'] : ''}',
                  width: homeController.isMobile.value ? 200 : bigWidth,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TransactionQuotationsAsRowInTable extends StatelessWidget {
  const TransactionQuotationsAsRowInTable({
    super.key,
    required this.info,
    required this.index,
  });
  final Map info;
  final int index;
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return InkWell(
      onTap: () {
        showDialog<String>(
          context: context,
          builder:
              (BuildContext context) => AlertDialog(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                ),
                elevation: 0,
                content:
                    homeController.isMobile.value
                        ? MobileUpdateTransactionQuotationDialog(
                          quotationIndex: index,
                        )
                        : UpdateTransactionQuotationDialog(
                          quotationIndex: index,
                        ),
              ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: GetBuilder<HomeController>(
          builder: (homeCont) {
            double bigWidth =
                homeCont.isMenuOpened
                    ? MediaQuery.of(context).size.width * 0.12
                    : MediaQuery.of(context).size.width * 0.16;
            double smallWidth =
                homeCont.isMenuOpened
                    ? MediaQuery.of(context).size.width * 0.09
                    : MediaQuery.of(context).size.width * 0.11;
            return Row(
              children: [
                TableItem(
                  text: '${info['createdAtDate'] ?? ''}',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: '${info['quotationNumber'] ?? ''}',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: '${info['reference'] ?? ''}',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: 'quotation',
                  width: homeController.isMobile.value ? 140 : smallWidth,
                ),
                TableItem(
                  text: '', // '${info['transaction_label'] ?? ''}',
                  width: homeController.isMobile.value ? 250 : smallWidth,
                ),
                TableItem(
                  text:
                      info['currency']['name'] == 'USD'
                          ? '${info['total'] ?? ''}'
                          : '',
                  width: homeController.isMobile.value ? 150 : bigWidth,
                ),
                TableItem(
                  text:
                      info['currency']['name'] == 'USD'
                          ? ''
                          : '${info['total'] ?? ''} ${info['currency']['name'] ?? ''}',
                  width: homeController.isMobile.value ? 200 : bigWidth,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MobileAccountsPage extends StatefulWidget {
  const MobileAccountsPage({super.key});

  @override
  State<MobileAccountsPage> createState() => _MobileAccountsPageState();
}

class _MobileAccountsPageState extends State<MobileAccountsPage> {
  final TextEditingController filterController = TextEditingController();
  FilterItems? selectedFilterItem;
  // GlobalKey filterKey = GlobalKey();
  bool isGridClicked = false;

  final HomeController homeController = Get.find();
  List tabsList = ['general', 'transactions'];
  int selectedTabIndex = 0;
  double generalListViewLength = 100;
  double transactionListViewLength = 100;
  String selectedNumberOfRowsInGeneralTab = '10';
  int selectedNumberOfRowsInGeneralTabAsInt = 10;
  String selectedNumberOfRowsInTransactionsTab = '10';
  int selectedNumberOfRowsInTransactionsTabAsInt = 10;
  int startInGeneral = 1;
  bool isArrowBackClickedInGeneral = false;
  bool isArrowForwardClickedInGeneral = false;
  int startInTransactions = 1;
  bool isArrowBackClickedInTransactions = false;
  bool isArrowForwardClickedInTransactions = false;

  ClientController clientController = Get.find();

  String searchValue = '';
  Timer? searchOnStoppedTyping;
  _onChangeHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      setState(() => searchOnStoppedTyping!.cancel()); // clear timer
    }
    setState(
      () => searchOnStoppedTyping = Timer(duration, () => search(value)),
    );
  }

  search(value) async {
    if (selectedTabIndex == 0) {
      setState(() {
        searchValue = value;
        clientController.setIsClientsFetched(false);
        clientController.setAccounts([]);
      });
      await clientController.getAllClientsFromBack();
    } else {
      setState(() {
        searchValue = value;
        clientController.setIsTransactionsFetched(false);
        clientController.setTransactionsOrders([]);
        clientController.setTransactionsQuotations([]);
      });
      await clientController.getTransactionsFromBack();
    }
  }

  String primaryCurr = '';
  getCurrency() async {
    var curr = await getCompanyPrimaryCurrencyFromPref();
    primaryCurr = curr;
  }

  // TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    getCurrency();
    clientController.getAllClientsFromBack();
    selectedNumberOfRowsInGeneralTabAsInt =
        clientController.accounts.length < 10
            ? clientController.accounts.length
            : 10;
    generalListViewLength =
        clientController.accounts.length < 10
            ? Sizes.deviceHeight * (0.09 * clientController.accounts.length)
            : Sizes.deviceHeight * (0.09 * 10);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (clientCont) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03,
          ),
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PageTitle(text: 'list_of_clients'.tr),
                gapH10,
                ReusableButtonWithColor(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: 45,
                  onTapFunction: () {
                    homeController.selectedTab.value = 'add_new_client';
                  },
                  btnText: 'create_new_client'.tr,
                ),
                gapH10,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: ReusableSearchTextField(
                        hint: '${"search".tr}...',
                        textEditingController: clientCont.searchController,
                        onChangedFunc: (val) {
                          _onChangeHandler(val);
                        },
                        validationFunc: () {},
                      ),
                    ),
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       isGridClicked = !isGridClicked;
                    //     });
                    //   },
                    //   child: Icon(
                    //     Icons.grid_view_outlined,
                    //     color:
                    //         isGridClicked
                    //             ? Primary.primary
                    //             : TypographyColor.textTable,
                    //   ),
                    // ),
                    // InkWell(
                    //   onTap: () {
                    //     setState(() {
                    //       isGridClicked = !isGridClicked;
                    //     });
                    //   },
                    //   child: Icon(
                    //     Icons.format_list_bulleted,
                    //     color:
                    //         isGridClicked
                    //             ? TypographyColor.textTable
                    //             : Primary.primary,
                    //   ),
                    // ),
                  ],
                ),
                gapH32,
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 0.0,
                      direction: Axis.horizontal,
                      children:
                          tabsList
                              .map(
                                (element) => _buildTabChipItem(
                                  element,
                                  // element['id'],
                                  // element['name'],
                                  tabsList.indexOf(element),
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                selectedTabIndex == 0
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: SingleChildScrollView(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Primary.primary,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          TableTitle(
                                            text: 'code'.tr,
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'name'.tr,
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'mobile_number'.tr,
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'balance_usd'.tr,
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text:
                                                '${'balance'.tr} $primaryCurr',
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'more_options'.tr,
                                            width:
                                                200, // MediaQuery.of(context).size.width * 0.13,
                                          ),
                                        ],
                                      ),
                                    ),
                                    clientCont.isClientsFetched
                                        ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                            clientCont.accounts.length,
                                            (index) => Container(
                                              color: Colors.white,
                                              child: Column(
                                                children: [
                                                  Container(
                                                    color:
                                                        clientCont.selectedClientId ==
                                                                '${clientCont.accounts[index]['id']}'
                                                            ? Primary.primary
                                                                .withAlpha(
                                                                  (0.5 * 255)
                                                                      .toInt(),
                                                                )
                                                            : clientCont
                                                                    .hoveredClientId ==
                                                                '${clientCont.accounts[index]['id']}'
                                                            ? Primary.primary
                                                                .withAlpha(
                                                                  (0.2 * 255)
                                                                      .toInt(),
                                                                )
                                                            : Colors.white,
                                                    child: Row(
                                                      children: [
                                                        ClientAsRowInTable(
                                                          info:
                                                              clientCont
                                                                  .accounts[index],
                                                          index: index,
                                                          isDesktop: false,
                                                        ),
                                                        SizedBox(
                                                          width: 200,
                                                          child: ReusableMore(
                                                            itemsList: [
                                                              PopupMenuItem<
                                                                String
                                                              >(
                                                                value: '1',
                                                                onTap: () async {
                                                                  var res =
                                                                      await deleteClient(
                                                                        '${clientCont.accounts[index]['id']}',
                                                                      );
                                                                  var p = json
                                                                      .decode(
                                                                        res.body,
                                                                      );
                                                                  if (res.statusCode ==
                                                                      200) {
                                                                    CommonWidgets.snackBar(
                                                                      '',
                                                                      p['message'],
                                                                    );
                                                                    setState(() {
                                                                      selectedNumberOfRowsInGeneralTabAsInt =
                                                                          selectedNumberOfRowsInGeneralTabAsInt -
                                                                          1;
                                                                      clientCont
                                                                          .accounts
                                                                          .removeAt(
                                                                            index,
                                                                          );
                                                                      generalListViewLength =
                                                                          generalListViewLength -
                                                                          0.09;
                                                                    });
                                                                  } else {
                                                                    CommonWidgets.snackBar(
                                                                      'error',
                                                                      p['message'],
                                                                    );
                                                                  }
                                                                },
                                                                child: Text(
                                                                  'delete'.tr,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Divider(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                        : const CircularProgressIndicator(),
                                    // gapH4,
                                    // clientCont.accounts.isNotEmpty
                                    //     ? Row(
                                    //       mainAxisAlignment:
                                    //           MainAxisAlignment.start,
                                    //       children: [
                                    //         Text(
                                    //           '${'rows_per_page'.tr}:  ',
                                    //           style: const TextStyle(
                                    //             fontSize: 13,
                                    //             color: Colors.black54,
                                    //           ),
                                    //         ),
                                    //         Container(
                                    //           width: 60,
                                    //           height: 30,
                                    //           decoration: BoxDecoration(
                                    //             borderRadius:
                                    //                 BorderRadius.circular(6),
                                    //             border: Border.all(
                                    //               color: Colors.black,
                                    //               width: 2,
                                    //             ),
                                    //           ),
                                    //           child: Center(
                                    //             child: DropdownButtonHideUnderline(
                                    //               child: DropdownButton<String>(
                                    //                 borderRadius:
                                    //                     BorderRadius.circular(
                                    //                       0,
                                    //                     ),
                                    //                 items:
                                    //                     [
                                    //                       '10',
                                    //                       '20',
                                    //                       '50',
                                    //                       'all'.tr,
                                    //                     ].map((String value) {
                                    //                       return DropdownMenuItem<
                                    //                         String
                                    //                       >(
                                    //                         value: value,
                                    //                         child: Text(
                                    //                           value,
                                    //                           style:
                                    //                               const TextStyle(
                                    //                                 fontSize:
                                    //                                     12,
                                    //                                 color:
                                    //                                     Colors
                                    //                                         .grey,
                                    //                               ),
                                    //                         ),
                                    //                       );
                                    //                     }).toList(),
                                    //                 value:
                                    //                     selectedNumberOfRowsInGeneralTab,
                                    //                 onChanged: (val) {
                                    //                   setState(() {
                                    //                     selectedNumberOfRowsInGeneralTab =
                                    //                         val!;
                                    //                     if (val == '10') {
                                    //                       generalListViewLength =
                                    //                           clientCont
                                    //                                       .accounts
                                    //                                       .length <
                                    //                                   10
                                    //                               ? Sizes.deviceHeight *
                                    //                                   (0.09 *
                                    //                                       clientCont
                                    //                                           .accounts
                                    //                                           .length)
                                    //                               : Sizes.deviceHeight *
                                    //                                   (0.09 *
                                    //                                       10);
                                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                                    //                           clientCont
                                    //                                       .accounts
                                    //                                       .length <
                                    //                                   10
                                    //                               ? clientCont
                                    //                                   .accounts
                                    //                                   .length
                                    //                               : 10;
                                    //                     }
                                    //                     if (val == '20') {
                                    //                       generalListViewLength =
                                    //                           clientCont
                                    //                                       .accounts
                                    //                                       .length <
                                    //                                   20
                                    //                               ? Sizes.deviceHeight *
                                    //                                   (0.09 *
                                    //                                       clientCont
                                    //                                           .accounts
                                    //                                           .length)
                                    //                               : Sizes.deviceHeight *
                                    //                                   (0.09 *
                                    //                                       20);
                                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                                    //                           clientCont
                                    //                                       .accounts
                                    //                                       .length <
                                    //                                   20
                                    //                               ? clientCont
                                    //                                   .accounts
                                    //                                   .length
                                    //                               : 20;
                                    //                     }
                                    //                     if (val == '50') {
                                    //                       generalListViewLength =
                                    //                           clientCont
                                    //                                       .accounts
                                    //                                       .length <
                                    //                                   50
                                    //                               ? Sizes.deviceHeight *
                                    //                                   (0.09 *
                                    //                                       clientCont
                                    //                                           .accounts
                                    //                                           .length)
                                    //                               : Sizes.deviceHeight *
                                    //                                   (0.09 *
                                    //                                       50);
                                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                                    //                           clientCont
                                    //                                       .accounts
                                    //                                       .length <
                                    //                                   50
                                    //                               ? clientCont
                                    //                                   .accounts
                                    //                                   .length
                                    //                               : 50;
                                    //                     }
                                    //                     if (val == 'all'.tr) {
                                    //                       generalListViewLength =
                                    //                           Sizes
                                    //                               .deviceHeight *
                                    //                           (0.09 *
                                    //                               clientCont
                                    //                                   .accounts
                                    //                                   .length);
                                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                                    //                           clientCont
                                    //                               .accounts
                                    //                               .length;
                                    //                     }
                                    //                   });
                                    //                 },
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //         gapW16,
                                    //         Text(
                                    //           selectedNumberOfRowsInGeneralTab ==
                                    //                   'all'.tr
                                    //               ? '${'all'.tr} of ${clientCont.accounts.length}'
                                    //               : '$startInGeneral-$selectedNumberOfRowsInGeneralTab of ${clientCont.accounts.length}',
                                    //           style: const TextStyle(
                                    //             fontSize: 13,
                                    //             color: Colors.black54,
                                    //           ),
                                    //         ),
                                    //         gapW16,
                                    //         InkWell(
                                    //           onTap: () {
                                    //             setState(() {
                                    //               isArrowBackClickedInGeneral =
                                    //                   !isArrowBackClickedInGeneral;
                                    //               isArrowForwardClickedInGeneral =
                                    //                   false;
                                    //             });
                                    //           },
                                    //           child: Row(
                                    //             children: [
                                    //               Icon(
                                    //                 Icons.skip_previous,
                                    //                 color:
                                    //                     isArrowBackClickedInGeneral
                                    //                         ? Colors.black87
                                    //                         : Colors.grey,
                                    //               ),
                                    //               Icon(
                                    //                 Icons.navigate_before,
                                    //                 color:
                                    //                     isArrowBackClickedInGeneral
                                    //                         ? Colors.black87
                                    //                         : Colors.grey,
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //         gapW10,
                                    //         InkWell(
                                    //           onTap: () {
                                    //             setState(() {
                                    //               isArrowForwardClickedInGeneral =
                                    //                   !isArrowForwardClickedInGeneral;
                                    //               isArrowBackClickedInGeneral =
                                    //                   false;
                                    //             });
                                    //           },
                                    //           child: Row(
                                    //             children: [
                                    //               Icon(
                                    //                 Icons.navigate_next,
                                    //                 color:
                                    //                     isArrowForwardClickedInGeneral
                                    //                         ? Colors.black87
                                    //                         : Colors.grey,
                                    //               ),
                                    //               Icon(
                                    //                 Icons.skip_next,
                                    //                 color:
                                    //                     isArrowForwardClickedInGeneral
                                    //                         ? Colors.black87
                                    //                         : Colors.grey,
                                    //               ),
                                    //             ],
                                    //           ),
                                    //         ),
                                    //         gapW40,
                                    //       ],
                                    //     )
                                    //     : const SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    // Column(
                    //   children: [
                    //     Container(
                    //       padding: const EdgeInsets.symmetric(
                    //           horizontal: 5, vertical: 15),
                    //       decoration: BoxDecoration(
                    //           color: Primary.primary,
                    //           borderRadius:
                    //           const BorderRadius.all(Radius.circular(6))),
                    //       child: Row(
                    //         children: [
                    //           TableTitle(
                    //             text: 'code'.tr,
                    //             width: MediaQuery.of(context).size.width * 0.09,
                    //           ),
                    //           TableTitle(
                    //             text: 'name'.tr,
                    //             width: MediaQuery.of(context).size.width * 0.09,
                    //           ),
                    //           TableTitle(
                    //             text: '',
                    //             width: MediaQuery.of(context).size.width * 0.15,
                    //           ),
                    //           TableTitle(
                    //             text: 'phone_number'.tr,
                    //             width: MediaQuery.of(context).size.width * 0.09,
                    //           ),
                    //           TableTitle(
                    //             text: 'balance_usd'.tr,
                    //             width: MediaQuery.of(context).size.width * 0.09,
                    //           ),
                    //           TableTitle(
                    //             text: 'balance_lbp'.tr,
                    //             width: MediaQuery.of(context).size.width * 0.09,
                    //           ),
                    //           TableTitle(
                    //             text: 'more_options'.tr,
                    //             width: MediaQuery.of(context).size.width * 0.13,
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //     isClientsFetched
                    //         ? Container(
                    //       color: Colors.white,
                    //       height: generalListViewLength,
                    //       child: ListView.builder(
                    //         itemCount:
                    //         selectedNumberOfRowsInGeneralTabAsInt,
                    //         itemBuilder: (context, index) => Column(
                    //           children: [
                    //             Row(
                    //               children: [
                    //                 ClientAsRowInTable(
                    //                   info: accounts[index],
                    //                   index: index,
                    //                 ),
                    //                 SizedBox(
                    //                   width: MediaQuery.of(context)
                    //                       .size
                    //                       .width *
                    //                       0.13,
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                     MainAxisAlignment.spaceEvenly,
                    //                     children: [
                    //                       SizedBox(
                    //                         width: MediaQuery.of(context)
                    //                             .size
                    //                             .width *
                    //                             0.03,
                    //                         child: const ReusableMore(itemsList: [],),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //             const Divider()
                    //           ],
                    //         ),
                    //       ),
                    //     )
                    //         : const CircularProgressIndicator(),
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.end,
                    //       children: [
                    //         Text(
                    //           '${'rows_per_page'.tr}:  ',
                    //           style: const TextStyle(
                    //               fontSize: 13, color: Colors.black54),
                    //         ),
                    //         Container(
                    //           width: 60,
                    //           height: 30,
                    //           decoration: BoxDecoration(
                    //               borderRadius: BorderRadius.circular(6),
                    //               border:
                    //               Border.all(color: Colors.black, width: 2)),
                    //           child: Center(
                    //             child: DropdownButtonHideUnderline(
                    //               child: DropdownButton<String>(
                    //                 borderRadius: BorderRadius.circular(0),
                    //                 items: ['10', '20', '50', 'all'.tr]
                    //                     .map((String value) {
                    //                   return DropdownMenuItem<String>(
                    //                     value: value,
                    //                     child: Text(
                    //                       value,
                    //                       style: const TextStyle(
                    //                           fontSize: 12, color: Colors.grey),
                    //                     ),
                    //                   );
                    //                 }).toList(),
                    //                 value: selectedNumberOfRowsInGeneralTab,
                    //                 onChanged: (val) {
                    //                   setState(() {
                    //                     selectedNumberOfRowsInGeneralTab = val!;
                    //                     if (val == '10') {
                    //                       generalListViewLength =
                    //                       accounts.length < 10
                    //                           ? Sizes.deviceHeight *
                    //                           (0.09 * accounts.length)
                    //                           : Sizes.deviceHeight *
                    //                           (0.09 * 10);
                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                    //                       accounts.length < 10
                    //                           ? accounts.length
                    //                           : 10;
                    //                     }
                    //                     if (val == '20') {
                    //                       generalListViewLength =
                    //                       accounts.length < 20
                    //                           ? Sizes.deviceHeight *
                    //                           (0.09 * accounts.length)
                    //                           : Sizes.deviceHeight *
                    //                           (0.09 * 20);
                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                    //                       accounts.length < 20
                    //                           ? accounts.length
                    //                           : 20;
                    //                     }
                    //                     if (val == '50') {
                    //                       generalListViewLength =
                    //                       accounts.length < 50
                    //                           ? Sizes.deviceHeight *
                    //                           (0.09 * accounts.length)
                    //                           : Sizes.deviceHeight *
                    //                           (0.09 * 50);
                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                    //                       accounts.length < 50
                    //                           ? accounts.length
                    //                           : 50;
                    //                     }
                    //                     if (val == 'all'.tr) {
                    //                       generalListViewLength =
                    //                           Sizes.deviceHeight *
                    //                               (0.09 * accounts.length);
                    //                       selectedNumberOfRowsInGeneralTabAsInt =
                    //                           accounts.length;
                    //                     }
                    //                   });
                    //                 },
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         gapW16,
                    //         Text(
                    //             '$startInGeneral-$selectedNumberOfRowsInGeneralTab of ${accounts.length}',
                    //             style: const TextStyle(
                    //                 fontSize: 13, color: Colors.black54)),
                    //         gapW16,
                    //         InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 isArrowBackClickedInGeneral =
                    //                 !isArrowBackClickedInGeneral;
                    //                 isArrowForwardClickedInGeneral = false;
                    //               });
                    //             },
                    //             child: Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.skip_previous,
                    //                   color: isArrowBackClickedInGeneral
                    //                       ? Colors.black87
                    //                       : Colors.grey,
                    //                 ),
                    //                 Icon(
                    //                   Icons.navigate_before,
                    //                   color: isArrowBackClickedInGeneral
                    //                       ? Colors.black87
                    //                       : Colors.grey,
                    //                 ),
                    //               ],
                    //             )),
                    //         gapW10,
                    //         InkWell(
                    //             onTap: () {
                    //               setState(() {
                    //                 isArrowForwardClickedInGeneral =
                    //                 !isArrowForwardClickedInGeneral;
                    //                 isArrowBackClickedInGeneral = false;
                    //               });
                    //             },
                    //             child: Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.navigate_next,
                    //                   color: isArrowForwardClickedInGeneral
                    //                       ? Colors.black87
                    //                       : Colors.grey,
                    //                 ),
                    //                 Icon(
                    //                   Icons.skip_next,
                    //                   color: isArrowForwardClickedInGeneral
                    //                       ? Colors.black87
                    //                       : Colors.grey,
                    //                 ),
                    //               ],
                    //             )),
                    //         gapW40,
                    //       ],
                    //     )
                    //   ],
                    // )
                    : SizedBox(
                      // height: 200,
                      child: SingleChildScrollView(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Primary.primary,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          TableTitle(
                                            text: 'date'.tr,
                                            width:
                                                140, //MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'serial'.tr,
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'manual_ref'.tr,
                                            width:
                                                140, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'doctype'.tr,
                                            width:
                                                140, //MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text: 'transaction_label'.tr,
                                            width:
                                                250, //MediaQuery.of(context).size.width * 0.09,
                                          ),

                                          TableTitle(
                                            text: '${'value'.tr} (USD)',
                                            width:
                                                150, //MediaQuery.of(context).size.width * 0.09,
                                          ),
                                          TableTitle(
                                            text:
                                                '${'value'.tr} (other currency)',
                                            width:
                                                200, // MediaQuery.of(context).size.width * 0.09,
                                          ),
                                        ],
                                      ),
                                    ),
                                    clientCont.isTransactionsFetched
                                        ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: List.generate(
                                            clientCont
                                                    .transactionsOrders
                                                    .length +
                                                clientCont
                                                    .transactionsQuotations
                                                    .length,
                                            (index) =>
                                                index <
                                                        clientCont
                                                            .transactionsOrders
                                                            .length
                                                    ? TransactionOrderAsRowInTable(
                                                      info:
                                                          clientCont
                                                              .transactionsOrders[index],
                                                      index: index,
                                                    )
                                                    : TransactionQuotationsAsRowInTable(
                                                      info:
                                                          clientCont
                                                              .transactionsQuotations[index -
                                                              clientCont
                                                                  .transactionsOrders
                                                                  .length],
                                                      index:
                                                          index -
                                                          clientCont
                                                              .transactionsOrders
                                                              .length,
                                                    ),

                                            //     Container(
                                            //   padding:
                                            //       const EdgeInsets.symmetric(
                                            //         horizontal: 5,
                                            //         vertical: 10,
                                            //       ),
                                            //   decoration: const BoxDecoration(
                                            //     color: Colors.white,
                                            //     borderRadius: BorderRadius.all(
                                            //       Radius.circular(0),
                                            //     ),
                                            //   ),
                                            //   child: Row(
                                            //     children: [
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['date'] ?? ''}',
                                            //         width:
                                            //             140, //MediaQuery.of(context).size.width * 0.2,
                                            //       ),
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['serial'] ?? ''}',
                                            //         width:
                                            //             140, // MediaQuery.of(context).size.width * 0.2,
                                            //       ),
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['manual_ref'] ?? ''}',
                                            //         width:
                                            //             140, // MediaQuery.of(context).size.width * 0.2,
                                            //       ),
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['doctype'] ?? ''}',
                                            //         width:
                                            //             140, // MediaQuery.of(context).size.width * 0.2,
                                            //       ),
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['transaction_label'] ?? ''}',
                                            //         width:
                                            //             250, // MediaQuery.of(context).size.width * 0.5,
                                            //       ),
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['currency'] ?? ''}',
                                            //         width:
                                            //             150, // MediaQuery.of(context).size.width * 0.2,
                                            //       ),
                                            //       TableItem(
                                            //         text:
                                            //             '${clientCont.transactionsOrders[index]['value'] ?? ''}',
                                            //         width:
                                            //             200, // MediaQuery.of(context).size.width * 0.2,
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                          ),
                                        )
                                        : loading(),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                // Column(
                //   children: [
                //     Container(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: 5, vertical: 15),
                //       decoration: BoxDecoration(
                //           color: Primary.primary,
                //           borderRadius:
                //           const BorderRadius.all(Radius.circular(6))),
                //       child: Row(
                //         children: [
                //           TableTitle(
                //             text: 'date'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //           TableTitle(
                //             text: 'serial'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //           TableTitle(
                //             text: 'manual_ref'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //           TableTitle(
                //             text: 'doctype'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //           TableTitle(
                //             text: 'transaction_label'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //           TableTitle(
                //             text: '',
                //             width: MediaQuery.of(context).size.width * 0.1,
                //           ),
                //           TableTitle(
                //             text: 'currency'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //           // TableTitle(
                //           //   text: 'Debit'.tr,
                //           //   width: MediaQuery.of(context).size.width * 0.09,
                //           // ),
                //           // TableTitle(
                //           //   text: 'Credit'.tr,
                //           //   width: MediaQuery.of(context).size.width * 0.09,
                //           // ),
                //           TableTitle(
                //             text: 'value'.tr,
                //             width: MediaQuery.of(context).size.width * 0.09,
                //           ),
                //         ],
                //       ),
                //     ),
                //     Container(
                //       color: Colors.white,
                //       height: transactionListViewLength,
                //       child: ListView.builder(
                //         itemCount: selectedNumberOfRowsInTransactionsTabAsInt,
                //         itemBuilder: (context, index) => Column(
                //           children: [
                //             TransactionAsRowInTable(
                //               info: transactions[index],
                //               index: index,
                //             ),
                //             const Divider()
                //           ],
                //         ),
                //       ),
                //     ),
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.end,
                //       children: [
                //         Text(
                //           '${'rows_per_page'.tr}:  ',
                //           style: const TextStyle(
                //               fontSize: 13, color: Colors.black54),
                //         ),
                //         Container(
                //           width: 60,
                //           height: 30,
                //           decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(6),
                //               border:
                //               Border.all(color: Colors.black, width: 2)),
                //           child: Center(
                //             child: DropdownButtonHideUnderline(
                //               child: DropdownButton<String>(
                //                 borderRadius: BorderRadius.circular(0),
                //                 items: ['10', '20', '50', 'all'.tr]
                //                     .map((String value) {
                //                   return DropdownMenuItem<String>(
                //                     value: value,
                //                     child: Text(
                //                       value,
                //                       style: const TextStyle(
                //                           fontSize: 12, color: Colors.grey),
                //                     ),
                //                   );
                //                 }).toList(),
                //                 value: selectedNumberOfRowsInTransactionsTab,
                //                 onChanged: (val) {
                //                   setState(() {
                //                     selectedNumberOfRowsInTransactionsTab =
                //                     val!;
                //                     if (val == '10') {
                //                       transactionListViewLength =
                //                       transactions.length < 10
                //                           ? Sizes.deviceHeight *
                //                           (0.09 * transactions.length)
                //                           : Sizes.deviceHeight *
                //                           (0.09 * 10);
                //                       selectedNumberOfRowsInTransactionsTabAsInt =
                //                       transactions.length < 10
                //                           ? transactions.length
                //                           : 10;
                //                     }
                //                     if (val == '20') {
                //                       transactionListViewLength =
                //                       transactions.length < 20
                //                           ? Sizes.deviceHeight *
                //                           (0.09 * transactions.length)
                //                           : Sizes.deviceHeight *
                //                           (0.09 * 20);
                //                       selectedNumberOfRowsInTransactionsTabAsInt =
                //                       transactions.length < 20
                //                           ? transactions.length
                //                           : 20;
                //                     }
                //                     if (val == '50') {
                //                       transactionListViewLength =
                //                       transactions.length < 50
                //                           ? Sizes.deviceHeight *
                //                           (0.09 * transactions.length)
                //                           : Sizes.deviceHeight *
                //                           (0.09 * 50);
                //                       selectedNumberOfRowsInTransactionsTabAsInt =
                //                       transactions.length < 50
                //                           ? transactions.length
                //                           : 50;
                //                     }
                //                     if (val == 'all'.tr) {
                //                       transactionListViewLength =
                //                           Sizes.deviceHeight *
                //                               (0.09 * transactions.length);
                //                       selectedNumberOfRowsInTransactionsTabAsInt =
                //                           transactions.length;
                //                     }
                //                   });
                //                 },
                //               ),
                //             ),
                //           ),
                //         ),
                //         gapW16,
                //         Text(
                //             '$startInTransactions-$selectedNumberOfRowsInTransactionsTab of ${transactions.length}',
                //             style: const TextStyle(
                //                 fontSize: 13, color: Colors.black54)),
                //         gapW16,
                //         InkWell(
                //             onTap: () {
                //               setState(() {
                //                 isArrowBackClickedInTransactions =
                //                 !isArrowBackClickedInTransactions;
                //                 isArrowForwardClickedInTransactions = false;
                //               });
                //             },
                //             child: Row(
                //               children: [
                //                 Icon(
                //                   Icons.skip_previous,
                //                   color: isArrowBackClickedInTransactions
                //                       ? Colors.black87
                //                       : Colors.grey,
                //                 ),
                //                 Icon(
                //                   Icons.navigate_before,
                //                   color: isArrowBackClickedInTransactions
                //                       ? Colors.black87
                //                       : Colors.grey,
                //                 ),
                //               ],
                //             )),
                //         gapW10,
                //         InkWell(
                //             onTap: () {
                //               setState(() {
                //                 isArrowForwardClickedInTransactions =
                //                 !isArrowForwardClickedInTransactions;
                //                 isArrowBackClickedInTransactions = false;
                //               });
                //             },
                //             child: Row(
                //               children: [
                //                 Icon(
                //                   Icons.navigate_next,
                //                   color: isArrowForwardClickedInTransactions
                //                       ? Colors.black87
                //                       : Colors.grey,
                //                 ),
                //                 Icon(
                //                   Icons.skip_next,
                //                   color: isArrowForwardClickedInTransactions
                //                       ? Colors.black87
                //                       : Colors.grey,
                //                 ),
                //               ],
                //             )),
                //         gapW40,
                //       ],
                //     )
                //   ],
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return GestureDetector(
          onTap:
              cont.selectedClientId == '' && index == 1
                  ? null
                  : () {
                    setState(() {
                      clientController.searchController.clear();
                      clientController.getAllClientsFromBack();
                      // clientController.getAllOrdersFromBack();
                      selectedTabIndex = index;
                    });
                    if (index == 1) {
                      cont.getTransactionsFromBack();
                    }
                  },
          child: ClipPath(
            clipper: const ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(9),
                  topRight: Radius.circular(9),
                ),
              ),
            ),
            child: Container(
              // width: MediaQuery.of(context).size.width * 0.25,
              // height: MediaQuery.of(context).size.height * 0.07,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              decoration: BoxDecoration(
                color: selectedTabIndex == index ? Primary.p20 : Colors.white,
                border:
                    selectedTabIndex == index
                        ? Border(
                          top: BorderSide(color: Primary.primary, width: 3),
                        )
                        : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                    spreadRadius: 9,
                    blurRadius: 9,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  name.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Primary.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UpdateClientDialog extends StatefulWidget {
  const UpdateClientDialog({
    super.key,
    required this.index,
    required this.info,
  });
  final int index;
  final Map info;

  @override
  State<UpdateClientDialog> createState() => _UpdateClientDialogState();
}

class _UpdateClientDialogState extends State<UpdateClientDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();
  TextEditingController priceListController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController referenceController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController floorBldgController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController jobPositionController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController internalNoteController = TextEditingController();
  TextEditingController grantedDiscountController = TextEditingController();
  final HomeController homeController = Get.find();

  String paymentTerm = '',
      selectedPriceListId = '',
      selectedCountry = '',
      selectedCity = '';
  String selectedPhoneCode = '', selectedMobileCode = '';
  int selectedClientType = 1;
  int selectedTabIndex = 0;
  // List tabsList = [
  //   // 'contacts_addresses',
  //   // 'sales',
  //   // 'internal_note',
  //   'settings',
  // ];

  ClientController clientController = Get.find();

  List<String> titles = ['Doctor', 'Miss', 'Mister', 'Maitre', 'Professor'];
  String selectedTitle = '';
  bool isActiveInPosChecked = false;
  bool isBlockedChecked = false;
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  // String address = "";

  List<String> countriesNamesList = [];
  bool isCountriesFetched = false;
  List<String> citiesNamesList = [];
  bool isCitiesFetched = true;
  getCountriesFromBack() async {
    var p = await getCountries();
    setState(() {
      for (var c in p) {
        countriesNamesList.add('${c['country']}');
      }
      isCountriesFetched = true;
    });
  }

  getCitiesFromBack(String country) async {
    setState(() {
      isCitiesFetched = false;
      citiesNamesList = [];
    });
    var p = await getCitiesOfASpecifiedCountry(country);
    setState(() {
      for (var c in p) {
        citiesNamesList.add(c);
      }
      isCitiesFetched = true;
    });
  }

  List<String> pricesListsNames = [];
  List<String> pricesListsCodes = [];
  List<String> pricesListsIds = [];
  getFieldsForCreateClientsFromBack() async {
    var p = await getFieldsForCreateClient();
    if ('$p' != '[]') {
      for (var priceList in p['pricelists']) {
        setState(() {
          pricesListsNames.add(priceList['title']);
          pricesListsIds.add('${priceList['id']}');
          pricesListsCodes.add('${priceList['code']}');
        });
      }
    }
  }

  setContacts() {
    clientController.contactsList = [];
    for (var con in widget.info['deliveryAddresses']) {
      Map contact = {
        'type': con['type'] ?? '1',
        'name': con['name'] ?? '',
        'title': con['title'] ?? '',
        'jobPosition': con['job_position'] ?? '',
        'deliveryAddress': con['delivery_address'] ?? '',
        'phoneCode': con['phone_code'] ?? '+961',
        'phoneNumber': con['phone_number'] ?? '',
        'extension': con['extension'] ?? '',
        'mobileCode': con['mobile_code'] ?? '+961',
        'mobileNumber': con['mobile_number'] ?? '',
        'email': con['email'] ?? '',
        'note': con['note'] ?? '',
        'internalNote': con['internal_note'] ?? '',
      };
      clientController.contactsList.add(contact);
    }
  }
  setCars() {
    clientController.carsList = [];
    // for (var con in widget.info['cars']) {
    //   Map car = {
    //     'odometer': con['odometer'] ?? '',
    //     'registration': con['registration'] ?? '',
    //     'year': con['year'] ?? '',
    //     'color': con['color'] ?? '',
    //     'model': con['model'] ?? '',
    //     'brand': con['brand'] ?? '',
    //     'chassis_no': con['chassis_no'] ?? '',
    //     'rating': con['rating'] ?? '',
    //     'comment': con['comment'] ?? '',
    //     'car_fax': con['car_fax'] ?? '',
    //   };
    //   clientController.carsList.add(contact);
    // }
  }

  List tabsList = [
    'settings',
    'contacts_and_addresses',
    'sales',
    'accounting',
    // 'cars',
  ];
  setTabsList()async{
    var isItGarage= await getIsItGarageFromPref();
    if(isItGarage=='1'){
      tabsList.add('cars');
    }
  }
  @override
  void initState() {
    setTabsList();
    getFieldsForCreateClientsFromBack();
    getCountriesFromBack();
    setContacts();
    setCars();
    if (widget.info['country'] != null) {
      getCitiesOfASpecifiedCountry(widget.info['country']);
    }
    if (widget.info['pricelist'] != null) {
      selectedPriceListId = '${widget.info['pricelist']['id']}';
      priceListController.text = widget.info['pricelist']['code'];
    }
    if (widget.info['salesperson'] != null) {
      clientController.selectedSalesPersonId = widget.info['salesperson']['id'];
      clientController.salesPersonController.text =
          widget.info['salesperson']['name'];
    }
    selectedClientType = widget.info['type'] == 'company' ? 2 : 1;
    clientNameController.text = widget.info['name'] ?? '';
    internalNoteController.text = widget.info['internalNote'] ?? '';
    grantedDiscountController.text = '${widget.info['grantedDiscount'] ?? ''}';
    countryController.text = widget.info['country'] ?? '';
    selectedCountry = widget.info['country'] ?? '';
    countryValue = widget.info['country'] ?? '';
    cityController.text = widget.info['city'] ?? '';
    selectedCity = widget.info['city'] ?? '';
    cityValue = widget.info['city'] ?? '';
    floorBldgController.text = widget.info['floorBldg'] ?? '';
    streetController.text = widget.info['street'] ?? '';
    jobPositionController.text = widget.info['jobPosition'] ?? '';
    emailController.text = widget.info['email'] ?? '';
    titleController.text = widget.info['title'] ?? '';
    selectedTitle = widget.info['title'] ?? '';
    stateValue = widget.info['state'] ?? '';
    websiteController.text = widget.info['website'] ?? '';
    isActiveInPosChecked =
        '${widget.info['showOnPos'] ?? ''}' == '1' ? true : false;
    isBlockedChecked =
        '${widget.info['isBlocked'] ?? ''}' == '1' ? true : false;
    titleController.text = widget.info['title'] ?? '';
    referenceController.text = widget.info['reference'] ?? '';
    phoneController.text = widget.info['phoneNumber'] ?? '';
    selectedPhoneCode = widget.info['phoneCode'] ?? '';
    mobileController.text = widget.info['mobileNumber'] ?? '';
    selectedMobileCode = widget.info['mobileCode'] ?? '';
    taxNumberController.text = widget.info['taxId'] ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.78,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PageTitle(text: 'update_client'.tr),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: CircleAvatar(
                            backgroundColor: Primary.primary,
                            radius: 15,
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // gapH32,
                    // const AddPhotoCircle(),
                    gapH32,
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: ListTile(
                            title: Text(
                              'individual'.tr,
                              style: const TextStyle(fontSize: 12),
                            ),
                            leading: Radio(
                              value: 1,
                              groupValue: selectedClientType,
                              onChanged: (value) {
                                setState(() {
                                  selectedClientType = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: ListTile(
                            title: Text(
                              'company'.tr,
                              style: const TextStyle(fontSize: 12),
                            ),
                            leading: Radio(
                              value: 2,
                              groupValue: selectedClientType,
                              onChanged: (value) {
                                setState(() {
                                  selectedClientType = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    gapH10,
                    Text(
                      '${widget.info['clientNumber'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    gapH10,
                    DialogTextField(
                      textEditingController: clientNameController,
                      text: '${'client_name'.tr}*',
                      rowWidth: MediaQuery.of(context).size.width * 0.5,
                      textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                      validationFunc: (val) {
                        if (val.isEmpty) {
                          return 'required_field'.tr;
                        }
                        return null;
                      },
                    ),
                    gapH10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DialogTextField(
                          textEditingController: referenceController,
                          text: 'reference'.tr,
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                          validationFunc: (val) {},
                        ),
                        PhoneTextField(
                          textEditingController: phoneController,
                          text: 'phone'.tr,
                          initialValue: selectedPhoneCode,
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.2,
                          validationFunc: (String val) {
                            if (val.isNotEmpty && val.length < 7) {
                              return '7_digits'.tr;
                            }
                            return null;
                          },
                          onCodeSelected: (value) {
                            setState(() {
                              selectedPhoneCode = value;
                            });
                          },
                          onChangedFunc: (value) {
                            setState(() {
                              // mainDescriptionController.text=value;
                            });
                          },
                        ),
                        DialogTextField(
                          textEditingController: floorBldgController,
                          text: 'floor_bldg'.tr,
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                          validationFunc: (val) {},
                        ),
                      ],
                    ),
                    gapH10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('title'.tr),
                              DropdownMenu<String>(
                                width: MediaQuery.of(context).size.width * 0.15,
                                // requestFocusOnTap: false,
                                enableSearch: true,
                                controller: titleController,
                                hintText: 'Doctor, Miss, Mister',
                                inputDecorationTheme: InputDecorationTheme(
                                  // filled: true,
                                  hintStyle: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    20,
                                    0,
                                    25,
                                    5,
                                  ),
                                  // outlineBorder: BorderSide(color: Colors.black,),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Primary.primary.withAlpha(
                                        (0.2 * 255).toInt(),
                                      ),
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(9),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Primary.primary.withAlpha(
                                        (0.4 * 255).toInt(),
                                      ),
                                      width: 2,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(9),
                                    ),
                                  ),
                                ),
                                // menuStyle: ,
                                menuHeight: 250,
                                dropdownMenuEntries:
                                    titles.map<DropdownMenuEntry<String>>((
                                      String option,
                                    ) {
                                      return DropdownMenuEntry<String>(
                                        value: option,
                                        label: option,
                                      );
                                    }).toList(),
                                enableFilter: true,
                                onSelected: (String? val) {
                                  setState(() {
                                    selectedTitle = val!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        PhoneTextField(
                          textEditingController: mobileController,
                          text: 'mobile'.tr,
                          initialValue: selectedMobileCode,
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.2,
                          validationFunc: (val) {
                            if (val.isNotEmpty && val.length < 7) {
                              return '7_digits'.tr;
                            }
                            return null;
                          },
                          onCodeSelected: (value) {
                            setState(() {
                              selectedMobileCode = value;
                            });
                          },
                          onChangedFunc: (value) {
                            setState(() {
                              // mainDescriptionController.text=value;
                            });
                          },
                        ),
                        DialogTextField(
                          textEditingController: streetController,
                          text: 'street'.tr,
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                          validationFunc: (val) {},
                          // onChangedFunc: (value){
                          //   setState(() {
                          //     // mainDescriptionController.text=value;
                          //   });
                          // },
                        ),
                      ],
                    ),
                    gapH10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DialogTextField(
                          textEditingController: jobPositionController,
                          text: 'job_position'.tr,
                          hint: 'Sales Director,Sales...',
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                          validationFunc: (val) {},
                        ),
                        DialogTextField(
                          textEditingController: emailController,
                          text: 'email'.tr,
                          hint: 'example@gmail.com',
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.2,
                          validationFunc: (String value) {
                            if (value.isNotEmpty &&
                                !RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                ).hasMatch(value)) {
                              return 'check_format'.tr;
                            }
                          },
                        ),
                        isCountriesFetched
                            ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('country'.tr),
                                  DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller: countryController,
                                    hintText: '',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      // outlineBorder: BorderSide(color: Colors.black,),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                        countriesNamesList
                                            .map<DropdownMenuEntry<String>>((
                                              String option,
                                            ) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            })
                                            .toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedCountry = val!;
                                        getCitiesFromBack(val);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                            : SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: loading(),
                            ),
                      ],
                    ),
                    gapH10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DialogTextField(
                          textEditingController: taxNumberController,
                          text: 'tax_number'.tr,
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.15,
                          validationFunc: (val) {
                            if (selectedClientType == 2 && val.isEmpty) {
                              return 'required_field'.tr;
                            }
                            return null;
                          },
                        ),
                        DialogTextField(
                          textEditingController: websiteController,
                          text: 'website'.tr,
                          hint: 'www.example.com',
                          rowWidth: MediaQuery.of(context).size.width * 0.25,
                          textFieldWidth:
                              MediaQuery.of(context).size.width * 0.2,
                          validationFunc: (String value) {
                            // if(value.isNotEmpty && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            //     .hasMatch(value)) {
                            //   return 'check_format'.tr ;
                            // }return null;
                          },
                        ),
                        isCitiesFetched
                            ? SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('city'.tr),
                                  DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    // requestFocusOnTap: false,
                                    enableSearch: true,
                                    controller: cityController,
                                    hintText: '',
                                    inputDecorationTheme: InputDecorationTheme(
                                      // filled: true,
                                      hintStyle: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                      ),
                                      contentPadding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        25,
                                        5,
                                      ),
                                      // outlineBorder: BorderSide(color: Colors.black,),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.2 * 255).toInt(),
                                          ),
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Primary.primary.withAlpha(
                                            (0.4 * 255).toInt(),
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                    ),
                                    // menuStyle: ,
                                    menuHeight: 250,
                                    dropdownMenuEntries:
                                        citiesNamesList
                                            .map<DropdownMenuEntry<String>>((
                                              String option,
                                            ) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            })
                                            .toList(),
                                    enableFilter: true,
                                    onSelected: (String? val) {
                                      setState(() {
                                        selectedCity = val!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            )
                            : SizedBox(
                              width: MediaQuery.of(context).size.width * 0.25,
                              child: loading(),
                            ),
                      ],
                    ),
                    gapH10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 0.0,
                          direction: Axis.horizontal,
                          children:
                              tabsList
                                  .map(
                                    (element) => _buildTabChipItem(
                                      element,
                                      // element['id'],
                                      // element['name'],
                                      tabsList.indexOf(element),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.01,
                        vertical: 25,
                      ),
                      height: 560,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          // selectedTabIndex == 0
                          //     ? Column(
                          //         mainAxisAlignment: MainAxisAlignment.start,
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           ReusableAddCard(
                          //             text: 'add_contact'.tr,
                          //             onTap: () {},
                          //           ),
                          //         ],
                          //       )
                          //     : selectedTabIndex == 1
                          //         ? Row(
                          //             mainAxisAlignment:
                          //                 MainAxisAlignment.spaceBetween,
                          //             crossAxisAlignment:
                          //                 CrossAxisAlignment.start,
                          //             children: [
                          //               SizedBox(
                          //                   width: MediaQuery.of(context)
                          //                           .size
                          //                           .width *
                          //                       0.3,
                          //                   child: Column(
                          //                     children: [
                          //                       DialogDropMenu(
                          //                         optionsList: const [''],
                          //                         text: '${'sales_person'.tr}*',
                          //                         hint: '',
                          //                         rowWidth: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             0.3,
                          //                         textFieldWidth:
                          //                             MediaQuery.of(context)
                          //                                     .size
                          //                                     .width *
                          //                                 0.17,
                          //                         onSelected: () {},
                          //                       ),
                          //                       gapH16,
                          //                       DialogDropMenu(
                          //                         optionsList: [
                          //                           'cash'.tr,
                          //                           'on_account'.tr
                          //                         ],
                          //                         text: '${'payment_terms'.tr}*',
                          //                         hint: '',
                          //                         rowWidth: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             0.3,
                          //                         textFieldWidth:
                          //                             MediaQuery.of(context)
                          //                                     .size
                          //                                     .width *
                          //                                 0.17,
                          //                         onSelected: (val) {
                          //                           setState(() {
                          //                             paymentTerm = val;
                          //                           });
                          //                         },
                          //                       ),
                          //                       gapH16,
                          //                       DialogDropMenu(
                          //                         optionsList: ['standard'.tr],
                          //                         text: 'pricelist'.tr,
                          //                         hint: '',
                          //                         rowWidth: MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             0.3,
                          //                         textFieldWidth:
                          //                             MediaQuery.of(context)
                          //                                     .size
                          //                                     .width *
                          //                                 0.17,
                          //                         onSelected: (val) {
                          //                           setState(() {
                          //                             priceListSelected = val;
                          //                           });
                          //                         },
                          //                       ),
                          //                     ],
                          //                   )),
                          //             ],
                          //           )
                          //         : selectedTabIndex == 2
                          //             ? Column(
                          //                 mainAxisAlignment:
                          //                     MainAxisAlignment.start,
                          //                 crossAxisAlignment:
                          //                     CrossAxisAlignment.start,
                          //                 children: [
                          //                   DialogTextField(
                          //                     textEditingController:
                          //                         internalNoteController,
                          //                     text: '${'internal_note'.tr}*',
                          //                     rowWidth: MediaQuery.of(context)
                          //                             .size
                          //                             .width *
                          //                         0.7,
                          //                     textFieldWidth:
                          //                         MediaQuery.of(context)
                          //                                 .size
                          //                                 .width *
                          //                             0.6,
                          //                     validationFunc: (val) {},
                          //                   ),
                          //                 ],
                          //               )
                          //             :
                          selectedTabIndex == 0
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ReusableInputNumberField(
                                    controller: grantedDiscountController,
                                    textFieldWidth:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    rowWidth:
                                        MediaQuery.of(context).size.width *
                                        0.25,
                                    onChangedFunc: (val) {},
                                    validationFunc: (value) {},
                                    text: 'granted_discount'.tr,
                                  ),
                                  gapH20,
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.25,
                                    child: ListTile(
                                      title: Text(
                                        '    ${'show_in_POS'.tr}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Checkbox(
                                        // checkColor: Colors.white,
                                        // fillColor: MaterialStateProperty.resolveWith(getColor),
                                        value: isActiveInPosChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isActiveInPosChecked = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  gapH20,
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.25,
                                    child: ListTile(
                                      title: Text(
                                        '    ${'blocked'.tr}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      leading: Checkbox(
                                        // checkColor: Colors.white,
                                        // fillColor: MaterialStateProperty.resolveWith(getColor),
                                        value: isBlockedChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isBlockedChecked = value!;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : selectedTabIndex == 1
                              ? ContactsAndAddressesSection()
                              : selectedTabIndex == 2
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    child: Column(
                                      children: [
                                        GetBuilder<ClientController>(
                                          builder: (cont) {
                                            return DialogDropMenu(
                                              controller:
                                                  cont.salesPersonController,
                                              optionsList:
                                                  clientController
                                                      .salesPersonListNames,
                                              text: 'sales_person'.tr,
                                              hint: 'search'.tr,
                                              rowWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.3,
                                              textFieldWidth:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.17,
                                              onSelected: (String? val) {
                                                setState(() {
                                                  var index = clientController
                                                      .salesPersonListNames
                                                      .indexOf(val!);
                                                  clientController
                                                      .setSelectedSalesPerson(
                                                        val,
                                                        clientController
                                                            .salesPersonListId[index],
                                                      );
                                                });
                                              },
                                            );
                                          },
                                        ),
                                        gapH16,
                                        DialogDropMenu(
                                          optionsList: [''],
                                          text: '${'payment_terms'.tr}*',
                                          hint: '',
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.17,
                                          onSelected: (val) {
                                            setState(() {
                                              paymentTerm = val;
                                            });
                                          },
                                        ),
                                        gapH16,
                                        DialogDropMenu(
                                          controller: priceListController,
                                          optionsList: pricesListsCodes,
                                          text: 'pricelist'.tr,
                                          hint: '',
                                          rowWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.3,
                                          textFieldWidth:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.17,
                                          onSelected: (val) {
                                            var index = pricesListsCodes
                                                .indexOf(val);
                                            setState(() {
                                              selectedPriceListId =
                                                  pricesListsIds[index];
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                              : selectedTabIndex == 3
                              ? SizedBox()
                              : CarsSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            // height: MediaQuery.of(context).size.height * 0.1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (widget.info['country'] != null) {
                        getCitiesOfASpecifiedCountry(widget.info['country']);
                      }
                      if (widget.info['pricelist'] != null) {
                        selectedPriceListId =
                            '${widget.info['pricelist']['id']}';
                        priceListController.text =
                            widget.info['pricelist']['code'];
                      }
                      selectedClientType =
                          widget.info['type'] == 'company' ? 2 : 1;
                      clientNameController.text = widget.info['name'] ?? '';
                      internalNoteController.text =
                          widget.info['internalNote'] ?? '';
                      grantedDiscountController.text =
                          '${widget.info['grantedDiscount'] ?? ''}';
                      countryController.text = widget.info['country'] ?? '';
                      selectedCountry = widget.info['country'] ?? '';
                      countryValue = widget.info['country'] ?? '';
                      cityController.text = widget.info['city'] ?? '';
                      selectedCity = widget.info['city'] ?? '';
                      cityValue = widget.info['city'] ?? '';
                      floorBldgController.text = widget.info['floorBldg'] ?? '';
                      streetController.text = widget.info['street'] ?? '';
                      jobPositionController.text =
                          widget.info['jobPosition'] ?? '';
                      emailController.text = widget.info['email'] ?? '';
                      titleController.text = widget.info['title'] ?? '';
                      selectedTitle = widget.info['title'] ?? '';
                      stateValue = widget.info['state'] ?? '';
                      websiteController.text = widget.info['website'] ?? '';
                      isActiveInPosChecked =
                          '${widget.info['showOnPos'] ?? ''}' == '1'
                              ? true
                              : false;
                      isBlockedChecked =
                          '${widget.info['isBlocked'] ?? ''}' == '1'
                              ? true
                              : false;
                      titleController.text = widget.info['title'] ?? '';
                      referenceController.text = widget.info['reference'] ?? '';
                      phoneController.text = widget.info['phoneNumber'] ?? '';
                      selectedPhoneCode = widget.info['phoneCode'] ?? '';
                      mobileController.text = widget.info['mobileNumber'] ?? '';
                      selectedMobileCode = widget.info['mobileCode'] ?? '';
                      taxNumberController.text = widget.info['taxId'] ?? '';
                    });
                  },
                  child: Text(
                    'discard'.tr,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Primary.primary,
                    ),
                  ),
                ),
                gapW24,
                ReusableButtonWithColor(
                  btnText: 'save'.tr,
                  onTapFunction: () async {
                    if (_formKey.currentState!.validate()) {
                      var res = await updateClient(
                        '${widget.info['id']}',
                        referenceController.text,
                        isActiveInPosChecked ? '1' : '0',
                        grantedDiscountController.text,
                        isBlockedChecked ? '1' : '0',
                        selectedClientType == 1 ? 'individual' : 'company',
                        clientNameController.text,
                        widget.info['clientNumber'] ?? '',
                        selectedCountry,
                        selectedCity,
                        '',
                        '',
                        streetController.text,
                        floorBldgController.text,
                        jobPositionController.text,
                        selectedPhoneCode.isEmpty ? '+961' : selectedPhoneCode,
                        phoneController.text,
                        selectedMobileCode.isEmpty
                            ? '+961'
                            : selectedMobileCode,
                        mobileController.text,
                        emailController.text,
                        titleController.text,
                        '',
                        taxNumberController.text,
                        websiteController.text,
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        '',
                        clientController.selectedSalesPersonId == 0
                            ? ''
                            : clientController.selectedSalesPersonId.toString(),
                        paymentTerm,
                        selectedPriceListId,
                        internalNoteController.text,
                        '',
                        clientController.contactsList,
                      );
                      if (res['success'] == true) {
                        Get.back();
                        clientController.getAllClientsFromBack();
                        homeController.selectedTab.value = 'clients';
                        CommonWidgets.snackBar('Success', res['message']);
                      } else {
                        CommonWidgets.snackBar('error', res['message']);
                      }
                    }
                  },
                  width: 100,
                  height: 35,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              topRight: Radius.circular(9),
            ),
          ),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.12,
          height: MediaQuery.of(context).size.height * 0.07,
          // padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          decoration: BoxDecoration(
            color: selectedTabIndex == index ? Primary.p20 : Colors.white,
            border:
                selectedTabIndex == index
                    ? Border(top: BorderSide(color: Primary.primary, width: 3))
                    : null,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.5 * 255).toInt()),
                spreadRadius: 9,
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.tr,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Primary.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UpdateTransactionOrderDialog extends StatelessWidget {
  const UpdateTransactionOrderDialog({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return GetBuilder<ClientController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: EdgeInsets.symmetric(
            horizontal: homeController.isMobile.value ? 0 : 50,
            vertical: 30,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(
                      text: cont.transactionsOrders[index]['orderNumber'],
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: CircleAvatar(
                        backgroundColor: Primary.primary,
                        radius: 15,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH40,
                ReusableInfoText(
                  keyText: 'Status',
                  value: cont.transactionsOrders[index]['status'],
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'Note',
                  value: cont.transactionsOrders[index]['note'] ?? '',
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'Opened At',
                  value: cont.transactionsOrders[index]['date'],
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'Closed At',
                  value: cont.transactionsOrders[index]['closedAt'] ?? '',
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'Total',
                  value:
                      '${cont.transactionsOrders[index]['usdTotal'] ?? '0'} (USD)       '
                      '${cont.transactionsOrders[index]['otherCurrencyTotal'] ?? '0'} (LBP)',
                  // value: cont.transactionsOrders[index]['usdTotal'].toString(),
                ),
                gapH10,
                // ReusableInfoText(
                //   keyText: 'Total (LBP)',
                //   value: cont.transactionsOrders[index]['otherCurrencyTotal']
                //       .toString(),
                // ),
                ReusableInfoText(
                  keyText: 'Discount',
                  value:
                      '${cont.transactionsOrders[index]['usdDiscountValue'] ?? '0'} (USD)       '
                      '${cont.transactionsOrders[index]['otherCurrencyDiscountValue'] ?? '0'} (LBP)',
                  // value: cont.transactionsOrders[index]['usdDiscountValue']
                  //     .toString(),
                ),
                gapH10,
                // ReusableInfoText(
                //   keyText: 'Discount (LBP)',
                //   value: cont.transactionsOrders[index]
                //           ['otherCurrencyDiscountValue']
                //       .toString(),
                // ),
                ReusableInfoText(
                  keyText: 'Tax',
                  value:
                      '${cont.transactionsOrders[index]['usdTaxValue'] ?? '0'} (USD)       '
                      '${cont.transactionsOrders[index]['otherCurrencyTaxValue'] ?? '0'} (LBP)',
                ),
                gapH10,
                // ReusableInfoText(
                //   keyText: 'Tax (LBP)',
                //   value: cont.transactionsOrders[index]['otherCurrencyTaxValue']
                //       .toString(),
                // ),
                ReusableInfoText(
                  keyText: 'Cashier',
                  value: cont.transactionsOrders[index]['cashier'],
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'Finished By',
                  value: cont.transactionsOrders[index]['finishedBy'],
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'DOC Number',
                  value: cont.transactionsOrders[index]['docNumber'],
                ),
                gapH10,
                ReusableInfoText(
                  keyText: 'Discount Type',
                  value: cont.transactionsOrders[index]['discountType'] ?? '',
                ),
                gapH10,
                const Text(
                  'Items: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                homeController.isMobile.value
                    ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: SingleChildScrollView(
                        child: Row(
                          children: [
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        // horizontal: 10,
                                        vertical: 15,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Primary.primary,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(6),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          TableTitle(
                                            text: 'item_name'.tr,
                                            width: 140,
                                          ),
                                          TableTitle(
                                            text: 'quantity'.tr,
                                            width: 140,
                                          ),
                                          TableTitle(
                                            text: '${'price'.tr} (after tax)',
                                            width: 140,
                                          ),
                                          TableTitle(
                                            text: '${'discount'.tr}%',
                                            width: 140,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      color: Colors.white,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: List.generate(
                                          cont
                                              .transactionsOrders[index]['orderItems']
                                              .length,
                                          (ind) => ReusableItemRow(
                                            index: ind,
                                            product:
                                                cont.transactionsOrders[index]['orderItems'][ind],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Container(
                      width: 4 * MediaQuery.of(context).size.width * 0.1,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Primary.primary,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TableTitle(
                            text: 'item_name'.tr,
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          TableTitle(
                            text: 'quantity'.tr,
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          TableTitle(
                            text: '${'price'.tr} (after tax)',
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                          TableTitle(
                            text: '${'discount'.tr}%',
                            width: MediaQuery.of(context).size.width * 0.1,
                          ),
                        ],
                      ),
                    ),
                Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: 4 * MediaQuery.of(context).size.width * 0.1,
                  child: ListView.builder(
                    itemCount:
                        cont
                            .transactionsOrders[index]['orderItems']
                            .length, //products is data from back res
                    itemBuilder:
                        (context, ind) => ReusableItemRow(
                          index: ind,
                          product:
                              cont.transactionsOrders[index]['orderItems'][ind],
                        ),
                  ),
                ),
                // SizedBox(
                //   height: 500,
                //     width: 500,
                //     child: ListView.builder(
                //   itemCount: cont.transactionsOrders[index]['orderItems'].length,
                //   itemBuilder: (context, index) => ReusableItemRow(
                //     product: cont.transactionsOrders[index]['orderItems'][index],
                //   ),
                // ))
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReusableItemRow extends StatelessWidget {
  const ReusableItemRow({
    super.key,
    required this.product,
    required this.index,
  });
  final Map product;
  final int index;
  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: (index % 2 == 0) ? Primary.p10 : Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: '${product['item_name'] ?? ''}',
            width:
                homeController.isMobile.value
                    ? 140
                    : MediaQuery.of(context).size.width * 0.1,
          ),
          TableItem(
            text: '${product['quantity'] ?? ''}',
            width:
                homeController.isMobile.value
                    ? 140
                    : MediaQuery.of(context).size.width * 0.1,
          ),
          TableItem(
            text:
                '${product['price_after_tax'] ?? ''} (${product['price_currency']['name']})',
            width:
                homeController.isMobile.value
                    ? 140
                    : MediaQuery.of(context).size.width * 0.1,
          ),
          TableItem(
            text: '${product['item_discount'] ?? '0'}',
            width:
                homeController.isMobile.value
                    ? 140
                    : MediaQuery.of(context).size.width * 0.1,
          ),
        ],
      ),
    );

    //   Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Row(
    //       children: [
    //         Text(
    //           '${product['item_name'] ?? ''} ',
    //           style: const TextStyle(
    //             fontSize: 15,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ],
    //     ),
    //     //Text(
    //     //                 widget.product['posCurrency'] != null
    //     //                     ? ' ${
    //     //                     widget.product['posCurrency']['symbol']=='\$'?usdPrice:otherCurrencyPrice
    //     //                     // numberWithComma('${widget.product['unitPrice']?? ''}' )
    //     //                      }'
    //     //                     '${ ' ${widget.product['posCurrency']['symbol'] ?? ''}' }': '',
    //     //               ),
    //     Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Row(
    //           children: [
    //             SizedBox(
    //               width: Sizes.deviceWidth * 0.15,
    //               child: Text(
    //                 '${product['quantity']} ${'units'.tr} '
    //                 'x ${product['price_after_tax']} '
    //                 '${product['price_currency']['name']}/${'units'.tr}',
    //                 style: const TextStyle(
    //                   fontSize: 12,
    //                 ),
    //               ),
    //             ),
    //             // controller.discountValuesMap.containsKey(product['id'])
    //             product['item_discount'] != null
    //                 ? Text(
    //                     '     W/ ${product['item_discount']}%',
    //                     // 'W/ ${controller.discountValuesMap[product['id']]}${'discount'.tr}',
    //                     style: const TextStyle(
    //                         fontSize: 12, fontWeight: FontWeight.bold),
    //                   )
    //                 : const SizedBox()
    //           ],
    //         ),
    //         SizedBox(
    //           width: Sizes.deviceWidth * 0.07,
    //           child: Text(
    //             '${double.parse(product['price_after_tax'])*double.parse(product['quantity'])}',
    //             // '${(product['unitPrice']+tax) * controller.orderItemsQuantities[product['id']]} ${product['priceCurrency']['symbol']}',
    //             textAlign: TextAlign.end,
    //             style: const TextStyle(
    //                 fontSize: 12,
    //                 fontWeight: FontWeight.bold,
    //                 color: Colors.black),
    //           ),
    //         ),
    //       ],
    //     )
    //   ],
    // );
  }
}

class ReusableInfoText extends StatelessWidget {
  const ReusableInfoText({
    super.key,
    required this.keyText,
    required this.value,
  });
  final String keyText;
  final String value;
  @override
  Widget build(BuildContext context) {
    return value == ''
        ? const SizedBox()
        : Row(
          children: [
            Text(
              '$keyText: ',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        );
  }
}

class UpdateTransactionQuotationDialog extends StatelessWidget {
  const UpdateTransactionQuotationDialog({
    super.key,
    required this.quotationIndex,
  });
  final int quotationIndex;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(
                      text:
                          'quotation'
                              .tr, //cont.transactionsQuotations[quotationIndex]['quotationNumber']
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: CircleAvatar(
                        backgroundColor: Primary.primary,
                        radius: 15,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH40,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Others.divider),
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // isInfoFetched
                          //     ?
                          Text(
                            cont.transactionsQuotations[quotationIndex]['quotationNumber'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: TypographyColor.titleTable,
                            ),
                          ),
                          // : const CircularProgressIndicator(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.18,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('ref'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['reference'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('currency'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['currency']['name'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('validity'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['validity'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      gapH16,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.18,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('code'.tr),
                                ReusableShowInfoCard(
                                  text: cont.selectedClient['clientNumber'],
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.516,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('name'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['client']['name'] ??
                                      '',
                                  width:
                                      MediaQuery.of(context).size.width * 0.48,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      gapH16,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('address'.tr),
                                    Text(
                                      ': ${cont.selectedClient['country'] ?? ''}${cont.selectedClient['city'] == null ? '' : '-'} ${cont.selectedClient['city'] ?? ''}',
                                    ),
                                  ],
                                ),
                              ),
                              gapH6,
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('email'.tr),
                                    Text(
                                      ': ${cont.selectedClient['email'] ?? ''}',
                                    ),
                                  ],
                                ),
                              ),
                              gapH6,
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('phone'.tr),
                                    Text(
                                      cont.selectedClient['phoneNumber'] == null
                                          ? ':'
                                          : ': ${cont.selectedClient['phoneCode'] ?? ''} ${cont.selectedClient['phoneNumber'] ?? ''}',
                                    ),
                                  ],
                                ),
                              ),

                              // SizedBox(
                              //   width: MediaQuery.of(context).size.width * 0.15,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //     children: [
                              //       Text('vat'.tr),
                              //       ReusableShowInfoCard(
                              //         text:  '${cont.selectedClient['country']??''}',
                              //         width: MediaQuery.of(context).size.width * 0.1,),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Vat exempt'.tr),
                                ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['vatExempt']
                                          .toString(),
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // gapH40,
                // ReusableInfoText(
                //   keyText: 'status'.tr,
                //   value: cont.transactionsQuotations[quotationIndex]['status'],
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'reference'.tr,
                //   value: cont.transactionsQuotations[quotationIndex]['reference'],
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'validity'.tr,
                //   value: cont.transactionsQuotations[quotationIndex]['validity'] ?? '',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Created At',
                //   value: cont.transactionsQuotations[quotationIndex]['createdAtDate'],
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Special Discount',
                //   value: '${cont.transactionsQuotations[quotationIndex]['specialDiscount']??'0'}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Special Discount Amount',
                //   value: '${cont.transactionsQuotations[quotationIndex]['specialDiscountAmount']??'0'}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Global Discount',
                //   value: '${cont.transactionsQuotations[quotationIndex]['globalDiscount']??'0'}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Global Discount Amount',
                //   value: '${cont.transactionsQuotations[quotationIndex]['globalDiscountAmount']??'0'}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'vat',
                //   value: '${cont.transactionsQuotations[quotationIndex]['vat']??'0'}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'totalBeforeVat',
                //   value: '${cont.transactionsQuotations[quotationIndex]['totalBeforeVat']??'0'} ${cont.transactionsQuotations[quotationIndex]['currency']['name']}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Total',
                //   value: '${cont.transactionsQuotations[quotationIndex]['total']??'0'} ${cont.transactionsQuotations[quotationIndex]['currency']['name']}',
                // ),
                // gapH10,
                // ReusableInfoText(
                //   keyText: 'Tax',
                //   value: '${cont.transactionsQuotations[quotationIndex]['usdTaxValue']??'0'} (USD)       '
                //       '${cont.transactionsQuotations[quotationIndex]['otherCurrencyTaxValue']??'0'} (LBP)',
                // ),
                gapH20,
                ReusableChip(name: 'order_lines'.tr, isDesktop: true),
                // (name: 'order_lines'.tr, index: 0, function: (){}, isClicked: true),
                Container(
                  // width: 4* MediaQuery.of(context).size.width * 0.1,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Primary.primary,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TableTitle(
                        text: 'item_code'.tr,
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      TableTitle(
                        text: 'description'.tr,
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                      TableTitle(
                        text: 'quantity'.tr,
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      TableTitle(
                        text: 'unit_price'.tr,
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      TableTitle(
                        text: '${'discount'.tr}%',
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                      TableTitle(
                        text: 'total'.tr,
                        width: MediaQuery.of(context).size.width * 0.1,
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  height:
                      cont
                          .transactionsQuotations[quotationIndex]['orderLines']
                          .length *
                      75,
                  // width: 4* MediaQuery.of(context).size.width * 0.1,
                  child: ListView.builder(
                    itemCount:
                        cont
                            .transactionsQuotations[quotationIndex]['orderLines']
                            .length, //products is data from back res
                    itemBuilder:
                        (context, index) => ReusableRowInOrderLinesTable(
                          index: index,
                          info:
                              cont.transactionsQuotations[quotationIndex]['orderLines'][index],
                        ),
                  ),
                ),
                gapH24,
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'terms_conditions'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: TypographyColor.titleTable,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gapH16,
                      ReusableShowInfoCard(
                        text:
                            cont.transactionsQuotations[quotationIndex]['termsAndConditions'] ??
                            '',
                        // .toString(),
                        width: MediaQuery.of(context).size.width,
                      ),
                      gapH16,
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 40,
                  ),
                  decoration: BoxDecoration(
                    color: Primary.p20,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('total_before_vat'.tr),
                                // ReusableShowInfoCard(text: '${quotationController.totalQuotation}', width: MediaQuery.of(context).size.width * 0.1),
                                ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['totalBeforeVat']
                                          .toString()
                                          .toString(),
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                ),
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('global_disc'.tr),
                                Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                      child: ReusableShowInfoCard(
                                        text:
                                            cont.transactionsQuotations[quotationIndex]['globalDiscount']
                                                .toString()
                                                .toString(),
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.1,
                                      ),
                                    ),
                                    gapW10,
                                    ReusableShowInfoCard(
                                      text:
                                          cont.transactionsQuotations[quotationIndex]['globalDiscountAmount']
                                              .toString(),
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('special_disc'.tr),
                                Row(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                      child: ReusableShowInfoCard(
                                        text:
                                            cont.transactionsQuotations[quotationIndex]['specialDiscount']
                                                .toString()
                                                .toString(),
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.1,
                                      ),
                                    ),
                                    gapW10,
                                    ReusableShowInfoCard(
                                      text:
                                          cont.transactionsQuotations[quotationIndex]['specialDiscountAmount']
                                              .toString(),
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            gapH6,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('vat_11'.tr),
                                Row(
                                  children: [
                                    ReusableShowInfoCard(
                                      text:
                                          cont.transactionsQuotations[quotationIndex]['vat']
                                              .toString(),
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                    gapW10,
                                    ReusableShowInfoCard(
                                      text:
                                          cont.transactionsQuotations[quotationIndex]['vatLebanese']
                                              .toString(),
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            gapH10,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'total_amount'.tr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Primary.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  // '${'usd'.tr} 0.00',
                                  '${'usd'.tr} ${cont.transactionsQuotations[quotationIndex]['total'].toString()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Primary.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MobileUpdateTransactionQuotationDialog extends StatelessWidget {
  const MobileUpdateTransactionQuotationDialog({
    super.key,
    required this.quotationIndex,
  });
  final int quotationIndex;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.9,
          margin: const EdgeInsets.symmetric(vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(
                      text:
                          'quotation'
                              .tr, //cont.transactionsQuotations[quotationIndex]['quotationNumber']
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: CircleAvatar(
                        backgroundColor: Primary.primary,
                        radius: 15,
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                gapH40,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Others.divider),
                    borderRadius: const BorderRadius.all(Radius.circular(9)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        cont.transactionsQuotations[quotationIndex]['quotationNumber'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: TypographyColor.titleTable,
                        ),
                      ),
                      gapH6,

                      // : const CircularProgressIndicator(),
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('ref'.tr),
                            ReusableShowInfoCard(
                              text:
                                  cont.transactionsQuotations[quotationIndex]['reference'] ??
                                  '',
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                      ),
                      gapH6,

                      SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.15,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('currency'.tr),
                            ReusableShowInfoCard(
                              text:
                                  cont.transactionsQuotations[quotationIndex]['currency']['name'] ??
                                  '',
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                      ),
                      gapH6,

                      SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.25,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('validity'.tr),
                            ReusableShowInfoCard(
                              text:
                                  cont.transactionsQuotations[quotationIndex]['validity'] ??
                                  '',
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                      ),
                      gapH6,

                      gapH6,
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.18,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('code'.tr),
                            ReusableShowInfoCard(
                              text: cont.selectedClient['clientNumber'],
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                      ),
                      gapH6,

                      SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.516,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('name'.tr),
                            ReusableShowInfoCard(
                              text:
                                  cont.transactionsQuotations[quotationIndex]['client']['name'] ??
                                  '',
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                      ),
                      gapH6,
                      Column(
                        children: [
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('address'.tr),
                                Text(
                                  ': ${cont.selectedClient['country'] ?? ''}${cont.selectedClient['city'] == null ? '' : '-'} ${cont.selectedClient['city'] ?? ''}',
                                ),
                              ],
                            ),
                          ),
                          gapH6,
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('email'.tr),
                                Text(': ${cont.selectedClient['email'] ?? ''}'),
                              ],
                            ),
                          ),
                          gapH6,
                          SizedBox(
                            // width: MediaQuery.of(context).size.width * 0.15,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text('phone'.tr),
                                Text(
                                  cont.selectedClient['phoneNumber'] == null
                                      ? ':'
                                      : ': ${cont.selectedClient['phoneCode'] ?? ''} ${cont.selectedClient['phoneNumber'] ?? ''}',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      gapH6,
                      SizedBox(
                        // width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Vat exempt'.tr),
                            ReusableShowInfoCard(
                              text:
                                  cont.transactionsQuotations[quotationIndex]['vatExempt']
                                      .toString(),
                              width: MediaQuery.of(context).size.width * 0.4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                gapH20,
                ReusableChip(name: 'order_lines'.tr, isDesktop: false),
                SizedBox(
                  // height: MediaQuery.of(context).size.height * 0.4,
                  child: SingleChildScrollView(
                    child: Row(
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Primary.primary,
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(6),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      TableTitle(
                                        text: 'item_code'.tr,
                                        width: 140,
                                      ),
                                      TableTitle(
                                        text: 'description'.tr,
                                        width: 140,
                                      ),
                                      TableTitle(
                                        text: 'quantity'.tr,
                                        width: 140,
                                      ),
                                      TableTitle(
                                        text: 'unit_price'.tr,
                                        width: 140,
                                      ),
                                      TableTitle(
                                        text: '${'discount'.tr}%',
                                        width: 140,
                                      ),
                                      TableTitle(text: 'total'.tr, width: 140),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: List.generate(
                                      cont
                                          .transactionsQuotations[quotationIndex]['orderLines']
                                          .length,
                                      (index) => ReusableRowInOrderLinesTable(
                                        index: index,
                                        info:
                                            cont.transactionsQuotations[quotationIndex]['orderLines'][index],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   // width: 4* MediaQuery.of(context).size.width * 0.1,
                //   padding: const EdgeInsets.symmetric(vertical: 15),
                //   decoration: BoxDecoration(
                //     color: Primary.primary,
                //     borderRadius: const BorderRadius.all(Radius.circular(6)),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       TableTitle(
                //         text: 'item_code'.tr,
                //         width: MediaQuery.of(context).size.width * 0.1,
                //       ),
                //       TableTitle(
                //         text: 'description'.tr,
                //         width: MediaQuery.of(context).size.width * 0.3,
                //       ),
                //       TableTitle(
                //         text: 'quantity'.tr,
                //         width: MediaQuery.of(context).size.width * 0.1,
                //       ),
                //       TableTitle(
                //         text: 'unit_price'.tr,
                //         width: MediaQuery.of(context).size.width * 0.1,
                //       ),
                //       TableTitle(
                //         text: '${'discount'.tr}%',
                //         width: MediaQuery.of(context).size.width * 0.1,
                //       ),
                //       TableTitle(
                //         text: 'total'.tr,
                //         width: MediaQuery.of(context).size.width * 0.1,
                //       ),
                //     ],
                //   ),
                // ),
                // Container(
                //   color: Colors.white,
                //   height:200,
                //   // cont.transactionsQuotations[quotationIndex]['orderLines'].length * 75,
                //   // width: 4* MediaQuery.of(context).size.width * 0.1,
                //   child: ListView.builder(
                //     itemCount:
                //     cont
                //         .transactionsQuotations[quotationIndex]['orderLines']
                //         .length, //products is data from back res
                //     itemBuilder:
                //         (context, index) => ReusableRowInOrderLinesTable(
                //       index: index,
                //       info:
                //       cont.transactionsQuotations[quotationIndex]['orderLines'][index],
                //     ),
                //   ),
                // ),
                gapH24,
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'terms_conditions'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          color: TypographyColor.titleTable,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      gapH16,
                      ReusableShowInfoCard(
                        text:
                            cont.transactionsQuotations[quotationIndex]['termsAndConditions'] ??
                            '',
                        // .toString(),
                        width: MediaQuery.of(context).size.width,
                      ),
                      gapH16,
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Primary.p20,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('total_before_vat'.tr),
                          // ReusableShowInfoCard(text: '${quotationController.totalQuotation}', width: MediaQuery.of(context).size.width * 0.1),
                          ReusableShowInfoCard(
                            text:
                                cont.transactionsQuotations[quotationIndex]['totalBeforeVat']
                                    .toString()
                                    .toString(),
                            width: MediaQuery.of(context).size.width * 0.15,
                          ),
                        ],
                      ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('global_disc'.tr),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['globalDiscount']
                                          .toString()
                                          .toString(),
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ),
                              gapW10,
                              ReusableShowInfoCard(
                                text:
                                    cont.transactionsQuotations[quotationIndex]['globalDiscountAmount']
                                        .toString(),
                                width: MediaQuery.of(context).size.width * 0.15,
                              ),
                            ],
                          ),
                        ],
                      ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('special_disc'.tr),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: ReusableShowInfoCard(
                                  text:
                                      cont.transactionsQuotations[quotationIndex]['specialDiscount']
                                          .toString()
                                          .toString(),
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                ),
                              ),
                              gapW10,
                              ReusableShowInfoCard(
                                text:
                                    cont.transactionsQuotations[quotationIndex]['specialDiscountAmount']
                                        .toString(),
                                width: MediaQuery.of(context).size.width * 0.15,
                              ),
                            ],
                          ),
                        ],
                      ),
                      gapH6,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('vat_11'.tr),
                          Row(
                            children: [
                              ReusableShowInfoCard(
                                text:
                                    cont.transactionsQuotations[quotationIndex]['vat']
                                        .toString(),
                                width: MediaQuery.of(context).size.width * 0.15,
                              ),
                              gapW10,
                              ReusableShowInfoCard(
                                text:
                                    cont.transactionsQuotations[quotationIndex]['vatLebanese']
                                        .toString(),
                                width: MediaQuery.of(context).size.width * 0.15,
                              ),
                            ],
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total_amount'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              color: Primary.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            // '${'usd'.tr} 0.00',
                            '${'usd'.tr} ${cont.transactionsQuotations[quotationIndex]['total'].toString()}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Primary.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReusableRowInOrderLinesTable extends StatefulWidget {
  const ReusableRowInOrderLinesTable({
    super.key,
    required this.info,
    required this.index,
  });
  final Map info;
  final int index;

  @override
  State<ReusableRowInOrderLinesTable> createState() =>
      _ReusableRowInOrderLinesTableState();
}

class _ReusableRowInOrderLinesTableState
    extends State<ReusableRowInOrderLinesTable> {
  String itemCode = '';
  getItemFromBack() async {
    var res = await getAnItem('${widget.info['item_id']}');
    if (res['success'] == true) {
      setState(() {
        itemCode = res['data']['mainCode'];
      });
    }
  }

  HomeController homeController = Get.find();
  @override
  void initState() {
    if (widget.info['line_type_id'] == 2) {
      getItemFromBack();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(0)),
      ),
      child:
          widget.info['line_type_id'] == 2
              ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width:
                        homeController.isMobile.value
                            ? 20
                            : MediaQuery.of(context).size.width * 0.02,
                    height: 20,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/newRow.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  ReusableShowInfoCard(
                    text: itemCode,
                    width:
                        homeController.isMobile.value
                            ? 140
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                  ReusableShowInfoCard(
                    text: '${widget.info['item_description'] ?? ''}',
                    width:
                        homeController.isMobile.value
                            ? 140
                            : MediaQuery.of(context).size.width * 0.3,
                  ),
                  ReusableShowInfoCard(
                    text: '${widget.info['item_quantity'] ?? '0'}',
                    width:
                        homeController.isMobile.value
                            ? 140
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                  ReusableShowInfoCard(
                    text: '${widget.info['item_unit_price'] ?? '0'}',
                    width:
                        homeController.isMobile.value
                            ? 140
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                  ReusableShowInfoCard(
                    text: '${widget.info['item_discount'] ?? '0'}',
                    width:
                        homeController.isMobile.value
                            ? 140
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                  ReusableShowInfoCard(
                    text: '${widget.info['item_total'] ?? '0'}',
                    width:
                        homeController.isMobile.value
                            ? 140
                            : MediaQuery.of(context).size.width * 0.1,
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width:
                        homeController.isMobile.value
                            ? 20
                            : MediaQuery.of(context).size.width * 0.02,
                    height: 20,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/newRow.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.82,
                    height: 47,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withAlpha((0.1 * 255).toInt()),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text('      ${widget.info['title'] ?? ''}')],
                    ),
                  ),
                  // ReusableShowInfoCard(text:,width:MediaQuery.of(context).size.width* 0.81 ,),
                ],
              ),
    );
  }
}
