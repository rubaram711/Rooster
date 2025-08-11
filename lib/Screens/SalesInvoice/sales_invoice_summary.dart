import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/SalesInvoiceBackend/update_sales_invoice.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/pending_docs_review_controller.dart';
import 'package:rooster_app/Controllers/sales_invoice_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Screens/SalesInvoice/print_sales_invoice.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';
import '../../const/urls.dart';

import 'update_sales_invoice_dialog.dart';

class SalesInvoiceSummary extends StatefulWidget {
  const SalesInvoiceSummary({super.key});

  @override
  State<SalesInvoiceSummary> createState() => _SalesInvoiceSummaryState();
}

class _SalesInvoiceSummaryState extends State<SalesInvoiceSummary> {
  final TextEditingController filterController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  final ExchangeRatesController exchangeRatesController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();

  double listViewLength = 100;
  String selectedNumberOfRows = '10';
  int selectedNumberOfRowsAsInt = 10;
  int start = 1;
  bool isArrowBackClicked = false;
  bool isArrowForwardClicked = false;
  final HomeController homeController = Get.find();
  final SalesInvoiceController salesInvoiceController = Get.find();
  bool isNumberOrderedUp = true;
  bool isCreationOrderedUp = true;
  bool isCustomerOrderedUp = true;
  bool isSalespersonOrderedUp = true;
  String searchValue = '';
  Timer? searchOnStoppedTyping;
  bool isSalesInvoiceFetched = false;
  onChangeHandler(value) {
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
    setState(() {
      searchValue = value;
    });
    await salesInvoiceController.getAllSalesInvoiceFromBackWithoutExcept();
  }

  TaskController taskController = Get.find();
  int selectedTabIndex = 0;
  List tabsList = ['all_sales_invoices'];
  String searchValueInTasks = '';
  Timer? searchOnStoppedTypingInTasks;

  _onChangeTaskSearchHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTypingInTasks != null) {
      setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
    }
    setState(
      () =>
          searchOnStoppedTypingInTasks = Timer(
            duration,
            () => searchOnTask(value),
          ),
    );
  }

  searchOnTask(value) async {
    setState(() {
      searchValueInTasks = value;
    });
    await taskController.getAllTasksFromBack(value);
  }

  _salesInvoiceSearchHandler(value) {
    const duration = Duration(
      milliseconds: 800,
    ); // set the duration that you want call search() after that.
    if (searchOnStoppedTypingInTasks != null) {
      setState(() => searchOnStoppedTypingInTasks!.cancel()); // clear timer
    }
    setState(
      () =>
          searchOnStoppedTypingInTasks = Timer(
            duration,
            () => searchOnSalesInvoice(value),
          ),
    );
  }

  searchOnSalesInvoice(value) async {
    salesInvoiceController.setSearchInSalesInvoicesController(value);
    await salesInvoiceController.getAllSalesInvoiceFromBack();
  }

  Future<void> generatePdfFromImageUrl() async {
    String companyLogo = await getCompanyLogoFromPref();

    // 1. Download image
    final response = await http.get(Uri.parse(companyLogo));
    if (response.statusCode != 200) {
      throw Exception('Failed to load image');
    }

    final Uint8List imageBytes = response.bodyBytes;
    // String companyLogo = await getCompanyLogoFromPref();
    // final Uint8List logoBytes = await fetchImage(
    //   companyLogo,
    // );
    salesInvoiceController.setLogo(imageBytes);
  }

  @override
  void initState() {
    generatePdfFromImageUrl();
    salesInvoiceController.itemsMultiPartList = [];
    salesInvoiceController.salesPersonListNames = [];
    salesInvoiceController.salesPersonListId = [];
    exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    salesInvoiceController.getAllUsersSalesPersonFromBack();
    salesInvoiceController.getFieldsForCreateSalesInvoiceFromBack();
    salesInvoiceController.searchInSalesInvoicesController.text = '';
    listViewLength =
        Sizes.deviceHeight *
        (0.09 * salesInvoiceController.salesInvoicesList1.length);
    salesInvoiceController.getAllSalesInvoiceFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SalesInvoiceController>(
      builder: (cont) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PageTitle(text: 'sales_invoices'.tr),
                    ReusableButtonWithColor(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: 45,
                      onTapFunction: () {
                        homeController.selectedTab.value = 'new_sales_invoice';
                      },
                      btnText: 'create_sales_invoice'.tr,
                    ),
                  ],
                ),
                gapH24,
                SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.59,
                  child: ReusableSearchTextField(
                    hint: '${"search".tr}...',
                    textEditingController: cont.searchInSalesInvoicesController,
                    onChangedFunc: (value) {
                      if (selectedTabIndex == 1) {
                        _onChangeTaskSearchHandler(value);
                      } else {
                        _salesInvoiceSearchHandler(value);
                      }
                    },
                    validationFunc: () {},
                  ),
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
                                (element) => ReusableBuildTabChipItem(
                                  index: tabsList.indexOf(element),
                                  function: () {
                                    setState(() {
                                      selectedTabIndex = tabsList.indexOf(
                                        element,
                                      );
                                    });
                                  },
                                  isClicked:
                                      selectedTabIndex ==
                                      tabsList.indexOf(element),
                                  name: element,
                                ),
                              )
                              .toList(),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      //   padding:
                      //       const EdgeInsets.symmetric(vertical: 15),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          tableTitleWithOrderArrow(
                            'number'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isNumberOrderedUp = !isNumberOrderedUp;
                                isNumberOrderedUp
                                    ? cont.salesInvoicesList1.sort(
                                      (a, b) => a['salesInvoiceNumber']
                                          .compareTo(b['salesInvoiceNumber']),
                                    )
                                    : cont.salesInvoicesList1.sort(
                                      (a, b) => b['salesInvoiceNumber']
                                          .compareTo(a['salesInvoiceNumber']),
                                    );
                              });
                            },
                          ),
                          tableTitleWithOrderArrow(
                            'creation'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isCreationOrderedUp = !isCreationOrderedUp;
                                isCreationOrderedUp
                                    ? cont.salesInvoicesList1.sort(
                                      (a, b) => a['createdAtDate'].compareTo(
                                        b['createdAtDate'],
                                      ),
                                    )
                                    : cont.salesInvoicesList1.sort(
                                      (a, b) => b['createdAtDate'].compareTo(
                                        a['createdAtDate'],
                                      ),
                                    );
                              });
                            },
                          ),

                          tableTitleWithOrderArrow(
                            'customer'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isCustomerOrderedUp = !isCustomerOrderedUp;
                                isCustomerOrderedUp
                                    ? cont.salesInvoicesList1.sort(
                                      (a, b) => '${a['client']['name']}'
                                          .compareTo('${b['client']['name']}'),
                                    )
                                    : cont.salesInvoicesList1.sort(
                                      (a, b) => '${b['client']['name']}'
                                          .compareTo('${a['client']['name']}'),
                                    );
                              });
                            },
                          ),
                          tableTitleWithOrderArrow(
                            'salesperson'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isSalespersonOrderedUp =
                                    !isSalespersonOrderedUp;
                                isSalespersonOrderedUp
                                    ? cont.salesInvoicesList1.sort(
                                      (a, b) => a['salesperson']['name']
                                          .compareTo(b['salesperson']['name']),
                                    )
                                    : cont.salesInvoicesList1.sort(
                                      (a, b) => b['salesperson']['name']
                                          .compareTo(a['salesperson']['name']),
                                    );
                              });
                            },
                          ),
                          tableTitleWithOrderArrow(
                            'warehouse'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isSalespersonOrderedUp =
                                    !isSalespersonOrderedUp;
                                isSalespersonOrderedUp
                                    ? cont.salesInvoicesList1.sort(
                                      (
                                        a,
                                        b,
                                      ) => a['deliveredFromWarehouse']['name']
                                          .compareTo(
                                            b['deliveredFromWarehouse']['name'],
                                          ),
                                    )
                                    : cont.salesInvoicesList1.sort(
                                      (
                                        a,
                                        b,
                                      ) => b['deliveredFromWarehouse']['name']
                                          .compareTo(
                                            a['deliveredFromWarehouse']['name'],
                                          ),
                                    );
                              });
                            },
                          ),

                          TableTitle(
                            text: 'total'.tr,
                            width:
                                MediaQuery.of(context).size.width * 0.06, //085
                          ),
                          TableTitle(
                            text: 'cur'.tr,
                            isCentered: false,
                            width:
                                MediaQuery.of(context).size.width * 0.04, //085
                          ),
                          TableTitle(
                            text: 'status'.tr,
                            width: 90, //085
                          ),
                          TableTitle(
                            text: 'more_options'.tr,
                            width: MediaQuery.of(context).size.width * 0.11,
                          ),
                          tableTitleWithOrderArrow(
                            'delivery_date'.tr,
                            MediaQuery.of(context).size.width * 0.07,
                            () {
                              setState(() {
                                isCreationOrderedUp = !isCreationOrderedUp;
                                isCreationOrderedUp
                                    ? cont.salesInvoicesList1.sort(
                                      (a, b) => a['delivery_date'].compareTo(
                                        b['delivery_date'],
                                      ),
                                    )
                                    : cont.salesInvoicesList1.sort(
                                      (a, b) => b['delivery_date'].compareTo(
                                        a['delivery_date'],
                                      ),
                                    );
                              });
                            },
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.01,
                          ),
                        ],
                      ),
                    ),
                    cont.isSalesInvoiceFetched
                        ? Container(
                          color: Colors.white,
                          // height: listViewLength,
                          height:
                              MediaQuery.of(context).size.height *
                              0.4, //listViewLength
                          child: ListView.builder(
                            itemCount: cont.salesInvoicesList1.length,
                            itemBuilder:
                                (context, index) => Column(
                                  children: [
                                    SalesInvoiceAsRowInTable(
                                      info: cont.salesInvoicesList1[index],
                                      index: index,
                                    ),
                                    const Divider(),
                                  ],
                                ),
                          ),
                        )
                        : const CircularProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
          child:
              clickedTitle == text
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        text.length > 8 ? '${text.substring(0, 8)}...' : text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      isClicked
                          ? const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                          )
                          : const Icon(
                            Icons.arrow_drop_up,
                            color: Colors.white,
                          ),
                    ],
                  )
                  : hoverTitle == text
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${text.length > 7 ? text.substring(0, 6) : text}...',
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.5 * 255).toInt()),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withAlpha((0.5 * 255).toInt()),
                      ),
                    ],
                  )
                  : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
      ),
    );
  }
}

class SalesInvoiceAsRowInTable extends StatefulWidget {
  const SalesInvoiceAsRowInTable({
    super.key,
    required this.info,
    required this.index,
    this.isDesktop = true,
  });
  final Map info;
  final int index;
  final bool isDesktop;

  @override
  State<SalesInvoiceAsRowInTable> createState() =>
      _SalesInvoiceAsRowInTableState();
}

class _SalesInvoiceAsRowInTableState extends State<SalesInvoiceAsRowInTable> {
  String itemName = '';
  double itemPrice = 0;
  double itemTotal = 0;
  double totalAllItems = 0;
  String itemBrand = '';
  String itemImage = '';
  String itemDescription = '';
  String qty = '0.0';
  double discountOnAllItem = 0.0;
  double totalPriceAfterDiscount = 0.0;
  double additionalSpecialDiscount = 0.0;
  double totalPriceAfterSpecialDiscount = 0.0;
  double totalPriceAfterSpecialDiscountBysalesInvoiceCurrency = 0.0;
  double vatBySalesInvoiceCurrency = 0.0;
  double finalPriceBySalesInvoiceCurrency = 0.0;
  List itemsInfoPrint = [];
  Map salesInvoiceItemInfo = {};

  String brand = '';

  final HomeController homeController = Get.find();
  final SalesInvoiceController salesInvoiceController = Get.find();
  final PendingDocsReviewController pendingDocsController = Get.find();

  String diss = '0';
  double totalBeforeVatvValue = 0.0;
  double globalDiscountValue = 0.0;
  double specialDiscountValue = 0.0;
  double specialDisc = 0.0;
  double res = 0.0;
  bool isNewSalesInvoice = true;
  bool isNewSalesOrder = true;

  ExchangeRatesController exchangeRatesController = Get.find();

  String cashMethodId = '';
  String clientId = '';
  String pricelistId = '';
  String salespersonId = ' ';
  String commissionMethodId = '';
  String currencyId = ' ';
  String warehouseId = ' ';

  late Uint8List imageFile;
  bool isLoading = false; // Add loading state

  @override
  void initState() {
    imageFile = Uint8List(0);
    if (widget.info['cashingMethod'] != null) {
      cashMethodId = '${widget.info['cashingMethod']['id']}';
    }
    if (widget.info['deliveredFromWarehouse'] != null) {
      warehouseId = '${widget.info['deliveredFromWarehouse']['id']}';
    }
    if (widget.info['commissionMethod'] != null) {
      commissionMethodId = '${widget.info['commissionMethod']['id']}';
    }
    if (widget.info['currency'] != null) {
      currencyId = '${widget.info['currency']['id']}';
    }
    if (widget.info['client'] != null) {
      clientId = widget.info['client']['id'].toString();
    }
    if (widget.info['pricelist'] != null) {
      pricelistId = widget.info['pricelist']['id'].toString();
    }
    if (widget.info['salesperson'] != null) {
      salespersonId = widget.info['salesperson']['id'].toString();
    }
    // salesInvoiceController.getAllSalesInvoiceFromBack();
    // pendingDocsController.getAllPendingDocs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [
            TableItem(
              text: '${widget.info['salesInvoiceNumber'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            TableItem(
              text: '${widget.info['createdAtDate'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),

            TableItem(
              text:
                  widget.info['client'] == null
                      ? ''
                      : '${widget.info['client']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            TableItem(
              text:
                  widget.info['salesperson'] == null
                      ? ''
                      : '${widget.info['salesperson']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            TableItem(
              text:
                  widget.info['deliveredFromWarehouse'] == null
                      ? ''
                      : '${widget.info['deliveredFromWarehouse']['name'] ?? ''}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Text(
                      numberWithComma('${widget.info['total'] ?? ''}'),
                      style: TextStyle(
                        fontSize: 12,
                        color: TypographyColor.textTable,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            TableItem(
              text: '${widget.info['currency']['name'] ?? ''}',
              isCentered: false,
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.04
                      : 150,
            ),
            SizedBox(
              width: widget.isDesktop ? 90 : 150,
              child: Center(
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 1,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        widget.info['status'] == "pending"
                            ? Others.orangeStatusColor
                            : widget.info['status'] == 'cancelled'
                            ? Others.redStatusColor
                            : widget.info['status'] == 'sent'
                            ? Colors.blue
                            : Others.greenStatusColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.info['status'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            GetBuilder<SalesInvoiceController>(
              builder: (cont) {
                return SizedBox(
                  width:
                      widget.isDesktop
                          ? MediaQuery.of(context).size.width * 0.11
                          : 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Tooltip(
                        message: 'preview'.tr,
                        child: InkWell(
                          onTap: () async {
                            itemsInfoPrint = [];
                            salesInvoiceItemInfo = {};
                            totalAllItems = 0;
                            cont.totalAllItems = 0;
                            totalAllItems = 0;
                            cont.totalAllItems = 0;
                            totalPriceAfterDiscount = 0;
                            additionalSpecialDiscount = 0;
                            totalPriceAfterSpecialDiscount = 0;
                            totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
                                0;
                            vatBySalesInvoiceCurrency = 0;
                            vatBySalesInvoiceCurrency = 0;
                            finalPriceBySalesInvoiceCurrency = 0;
                            for (var item in widget.info['orderLines']) {
                              if ('${item['line_type_id']}' == '2') {
                                qty = item['item_quantity'];
                                var map =
                                    cont.itemsMap[item['item_id'].toString()];
                                itemName = map['item_name'];
                                itemPrice = double.parse(
                                  '${item['item_unit_price'] ?? '0'}',
                                );
                                //     map['unitPrice'] ?? 0.0;
                                // formatDoubleWithCommas(map['unitPrice']);
                                itemDescription = item['item_description'];
                                itemImage =
                                    '${map['images']}' != '[]' &&
                                            map['images'] != null
                                        ? '$baseImage${map['images'][0]['img_url']}'
                                        : '';
                                // itemCurrencyName = map['currency']['name'];
                                // itemCurrencySymbol = map['currency']['symbol'];
                                // itemCurrencyLatestRate =
                                //     map['currency']['latest_rate'];
                                if (map['itemGroups'] != null) {
                                  var firstBrandObject = map['itemGroups']
                                      .firstWhere(
                                        (obj) =>
                                            obj["root_name"]?.toLowerCase() ==
                                            "brand".toLowerCase(),
                                        orElse: () => null,
                                      );
                                  brand =
                                      firstBrandObject == null
                                          ? ''
                                          : firstBrandObject['name'] ?? '';
                                }
                                itemTotal = double.parse(
                                  '${item['item_total']}',
                                );
                                // itemTotal = double.parse(qty) * itemPrice;
                                totalAllItems += itemTotal;
                                salesInvoiceItemInfo = {
                                  'line_type_id': '2',
                                  'item_name': itemName,
                                  'item_description': itemDescription,
                                  'item_quantity': qty,
                                  'item_discount': item['item_discount'] ?? '0',
                                  'item_unit_price': formatDoubleWithCommas(
                                    itemPrice,
                                  ),
                                  'item_total': formatDoubleWithCommas(
                                    itemTotal,
                                  ),
                                  'item_image': itemImage,
                                  'item_brand': brand,
                                  'combo_image': '',
                                  'combo_brand': '',
                                  'title': '',
                                  'isImageList': false,
                                  'note': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(salesInvoiceItemInfo);
                              } else if ('${item['line_type_id']}' == '3') {
                                var qty = item['combo_quantity'];

                                var ind = cont.combosIdsList.indexOf(
                                  item['combo_id'].toString(),
                                );
                                var itemName = cont.combosNamesList[ind];
                                var itemPrice = double.parse(
                                  '${item['combo_unit_price'] ?? 0.0}',
                                );
                                var itemDescription = item['combo_description'];

                                var itemTotal = double.parse(
                                  '${item['combo_total']}',
                                );
                                var combosmap =
                                    cont.combosMap[item['combo_id'].toString()];
                                var comboImage =
                                    '${combosmap['image']}' != '' &&
                                            combosmap['image'] != null &&
                                            combosmap['image'].isNotEmpty
                                        ? '${combosmap['image']}'
                                        : 'no has image';

                                var combobrand =
                                    combosmap['brand'] ?? 'brand not found';
                                totalAllItems += itemTotal;
                                var quotationItemInfo = {
                                  'line_type_id': '3',
                                  'item_name': itemName,
                                  'item_description': itemDescription,
                                  'item_quantity': qty,
                                  'item_unit_price': formatDoubleWithCommas(
                                    itemPrice,
                                  ),
                                  'item_discount':
                                      item['combo_discount'] ?? '0',
                                  'item_total': formatDoubleWithCommas(
                                    itemTotal,
                                  ),
                                  'note': '',
                                  'item_image': '',
                                  'item_brand': '',
                                  'combo_image': comboImage,
                                  'combo_brand': combobrand,
                                  'isImageList': false,
                                  'title': '',
                                  'image': '',
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '1') {
                                var quotationItemInfo = {
                                  'line_type_id': '1',
                                  'item_name': '',
                                  'item_description': '',
                                  'item_quantity': '',
                                  'item_unit_price': '',
                                  'item_discount': '0',
                                  'item_total': '',
                                  'item_image': '',
                                  'item_brand': '',
                                  'combo_image': '',
                                  'combo_brand': '',
                                  'note': '',
                                  'isImageList': false,
                                  'title': item['title'],
                                  'image': '',
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '5') {
                                var quotationItemInfo = {
                                  'line_type_id': '5',
                                  'item_name': '',
                                  'item_description': '',
                                  'item_quantity': '',
                                  'item_unit_price': '',
                                  'item_discount': '0',
                                  'item_total': '',
                                  'item_image': '',
                                  'item_brand': '',
                                  'combo_image': '',
                                  'combo_brand': '',
                                  'title': '',
                                  'note': item['note'],
                                  'isImageList': false,
                                  'image': '',
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              } else if ('${item['line_type_id']}' == '4') {
                                var quotationItemInfo = {
                                  'line_type_id': '4',
                                  'item_name': '',
                                  'item_description': '',
                                  'item_quantity': '',
                                  'item_unit_price': '',
                                  'item_discount': '0',
                                  'item_total': '',
                                  'item_image': '',
                                  'item_brand': '',
                                  'combo_image': '',
                                  'combo_brand': '',
                                  'title': '',
                                  'note': '',
                                  'image': '$baseImage${item['image']}',
                                  'isImageList': false,
                                };
                                itemsInfoPrint.add(quotationItemInfo);
                              }
                            }

                            totalPriceAfterDiscount =
                                totalAllItems - discountOnAllItem;
                            additionalSpecialDiscount =
                                totalPriceAfterDiscount *
                                double.parse(
                                  widget.info['specialDiscount'] ?? '0',
                                ) /
                                100;
                            totalPriceAfterSpecialDiscount =
                                totalPriceAfterDiscount -
                                additionalSpecialDiscount;
                            totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
                                totalPriceAfterSpecialDiscount;
                            vatBySalesInvoiceCurrency =
                                '${widget.info['vatExempt']}' == '1'
                                    ? 0
                                    : (totalPriceAfterSpecialDiscountBysalesInvoiceCurrency *
                                            double.parse(
                                              await getCompanyVatFromPref(),
                                            )) /
                                        100;
                            finalPriceBySalesInvoiceCurrency =
                                totalPriceAfterSpecialDiscountBysalesInvoiceCurrency +
                                vatBySalesInvoiceCurrency;

                            var salesOrderNumber = '';
                            var quotNumber = '';
                            widget.info['salesorder'] == null
                                ? salesOrderNumber = ''
                                : salesOrderNumber =
                                    widget
                                        .info['salesorder']['salesorderNumber'];

                            salesOrderNumber == ''
                                ? quotNumber = ''
                                : quotNumber =
                                    widget
                                        .info['salesorder']['quotation']['quotationNumber'];

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  // print('widget.info[ ${widget.info['termsAndConditions']}');
                                  return PrintSalesInvoice(
                                    quotationNumber: quotNumber,
                                    salesOrderNumber: salesOrderNumber,
                                    isPrintedAs0:
                                        '${widget.info['printedAsPercentage']}' ==
                                                '1'
                                            ? true
                                            : false,
                                    isVatNoPrinted:
                                        '${widget.info['notPrinted']}' == '1'
                                            ? true
                                            : false,
                                    isPrintedAsVatExempt:
                                        '${widget.info['printedAsVatExempt']}' ==
                                                '1'
                                            ? true
                                            : false,
                                    isInSalesInvoice: true,
                                    salesInvoiceNumber:
                                        widget.info['salesInvoiceNumber'] ?? '',
                                    creationDate:
                                        widget.info['valueDate'] ?? '',
                                    ref: widget.info['reference'] ?? '',
                                    receivedUser: '',
                                    senderUser: homeController.userName,
                                    status: widget.info['status'] ?? '',
                                    totalBeforeVat:
                                        widget.info['totalBeforeVat'] ?? '',
                                    discountOnAllItem:
                                        discountOnAllItem.toString(),
                                    totalAllItems:
                                    // totalAllItems.toString()  ,
                                    formatDoubleWithCommas(totalAllItems),

                                    globalDiscount:
                                        widget.info['globalDiscount'] ?? '0.00',

                                    totalPriceAfterDiscount:
                                        formatDoubleWithCommas(
                                          totalPriceAfterDiscount,
                                        ),
                                    additionalSpecialDiscount:
                                        additionalSpecialDiscount
                                            .toStringAsFixed(2),
                                    totalPriceAfterSpecialDiscount:
                                        formatDoubleWithCommas(
                                          totalPriceAfterSpecialDiscount,
                                        ),
                                    // itemCurrencyName: itemCurrencyName,
                                    // itemCurrencySymbol: itemCurrencySymbol,
                                    // itemCurrencyLatestRate:
                                    //     itemCurrencyLatestRate,
                                    totalPriceAfterSpecialDiscountBySalesInvoiceCurrency:
                                        formatDoubleWithCommas(
                                          totalPriceAfterSpecialDiscountBysalesInvoiceCurrency,
                                        ),

                                    vatBySalesInvoiceCurrency:
                                        formatDoubleWithCommas(
                                          vatBySalesInvoiceCurrency,
                                        ),
                                    finalPriceBySalesInvoiceCurrency:
                                        formatDoubleWithCommas(
                                          finalPriceBySalesInvoiceCurrency,
                                        ),
                                    specialDisc: specialDisc.toString(),
                                    specialDiscount:
                                        widget.info['specialDiscount'] ?? '0',
                                    specialDiscountAmount:
                                        widget.info['specialDiscountAmount'] ??
                                        '',
                                    salesPerson:
                                        widget.info['salesperson'] != null
                                            ? widget.info['salesperson']['name']
                                            : '---',
                                    salesInvoiceCurrency:
                                        widget.info['currency']['name'] ?? '',
                                    salesInvoiceCurrencySymbol:
                                        widget.info['currency']['symbol'] ?? '',
                                    salesInvoiceCurrencyLatestRate:
                                        widget
                                            .info['currency']['latest_rate'] ??
                                        '',
                                    clientPhoneNumber:
                                        widget.info['client'] != null
                                            ? widget.info['client']['phoneNumber'] ??
                                                '---'
                                            : "---",
                                    clientName:
                                        widget.info['client']['name'] ?? '',
                                    termsAndConditions:
                                        widget.info['termsAndConditions'] ?? '',
                                    itemsInfoPrint: itemsInfoPrint,
                                  );
                                },
                              ),
                            );
                          },
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Primary.primary,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'modify'.tr,
                        child: InkWell(
                          onTap: () async {
                            showDialog<String>(
                              context: context,
                              builder:
                                  (BuildContext context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(9.0),
                                      ),
                                    ),
                                    elevation: 0.0,
                                    content: UpdateSalesInvoiceDialog(
                                      index: widget.index,
                                      info: widget.info,
                                      fromPage: 'salesInvoiceSummary',
                                    ),
                                  ),
                            );
                          },
                          child: Icon(Icons.edit, color: Primary.primary),
                        ),
                      ),

                      Tooltip(
                        message: 'send'.tr,
                        child: InkWell(
                          onTap: () async {
                            Map<int, Map<String, dynamic>> orderLines1 = {};
                            List<int> orderedKeys = [];
                            Map<int, dynamic> orderLinesMap = {
                              for (
                                int i = 0;
                                i < widget.info['orderLines'].length;
                                i++
                              )
                                (i + 1): widget.info['orderLines'][i],
                            };

                            for (int i = 0; i < orderLinesMap.length; i++) {
                              orderedKeys.add(i + 1);
                              Map<String, dynamic> selectedOrderLine =
                                  orderLinesMap[i + 1];
                              orderLines1[i + 1] = {};
                              if (selectedOrderLine['line_type_id'] == 1) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';

                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] = '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 2) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] =
                                    selectedOrderLine['item_id']?.toString() ??
                                    '';

                                orderLines1[i + 1]!['itemName'] =
                                    selectedOrderLine['item_name'] ?? '';
                                orderLines1[i + 1]!['item_main_code'] =
                                    selectedOrderLine['item_main_code'] ?? '';
                                orderLines1[i + 1]!['item_discount'] =
                                    selectedOrderLine['item_discount']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_description'] =
                                    selectedOrderLine['item_description'] ?? '';
                                orderLines1[i + 1]!['item_quantity'] =
                                    selectedOrderLine['item_quantity']
                                        ?.toString() ??
                                    '';

                                orderLines1[i + 1]!['item_unit_price'] =
                                    selectedOrderLine['item_unit_price']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_total'] =
                                    selectedOrderLine['item_total']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 3) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1
                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] =
                                    selectedOrderLine['combo_name'] ?? '';
                                orderLines1[i + 1]!['item_main_code'] =
                                    selectedOrderLine['combo_code'] ?? '';
                                orderLines1[i + 1]!['item_discount'] =
                                    selectedOrderLine['combo_discount']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_description'] =
                                    selectedOrderLine['combo_description'] ??
                                    '';
                                orderLines1[i + 1]!['item_quantity'] =
                                    selectedOrderLine['combo_quantity']
                                        ?.toString() ??
                                    '';

                                orderLines1[i + 1]!['item_unit_price'] =
                                    selectedOrderLine['combo_unit_price']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_total'] =
                                    selectedOrderLine['combo_total']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] =
                                    selectedOrderLine['combo_id']?.toString() ??
                                    '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 4) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';

                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] = '';
                                orderLines1[i + 1]!['note'] = '';
                                if (selectedOrderLine['image'] != null &&
                                    selectedOrderLine['image'].isNotEmpty) {
                                  try {
                                    final response = await http.get(
                                      Uri.parse(
                                        '$baseImage${selectedOrderLine['image']}',
                                      ),
                                    );

                                    if (response.statusCode == 200) {
                                      imageFile = response.bodyBytes;
                                    } else {
                                      imageFile = Uint8List(
                                        0,
                                      ); // Set to empty if loading fails
                                    }
                                  } catch (e) {
                                    imageFile = Uint8List(
                                      0,
                                    ); // Set to empty if loading fails
                                  }
                                } else {
                                  imageFile = Uint8List(
                                    0,
                                  ); // Set to empty if no image URL
                                }
                                orderLines1[i + 1]!['image'] = imageFile;
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 5) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';

                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] = '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                            }

                            var res = await updateSalesInvoice(
                              '${widget.info['id']}',
                              false,
                              '${widget.info['reference'] ?? ''}',
                              clientId,

                              '${widget.info['valueDate'] ?? ''}',
                              warehouseId,
                              '', //todo paymentTermsController.text,
                              pricelistId,
                              currencyId,
                              '${widget.info['termsAndConditions']}',
                              salespersonId,
                              commissionMethodId,
                              cashMethodId,
                              '${widget.info['commissionRate'] ?? ''}',
                              '${widget.info['commissionTotal'] ?? ''}',
                              '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
                              '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
                              '${widget.info['specialDiscount'] ?? '0'}', // calculated
                              '${widget.info['globalDiscountAmount'] ?? ''}',
                              '${widget.info['globalDiscount'] ?? ''}',
                              '${widget.info['vat'] ?? ''}', //vat
                              '${widget.info['vatLebanese'] ?? ''}',
                              '${widget.info['total'] ?? ''}',
                              '${widget.info['vatExempt'] ?? ''}',
                              '${widget.info['notPrinted'] ?? ''}',
                              '${widget.info['printedAsVatExempt'] ?? ''}',
                              '${widget.info['printedAsPercentage'] ?? ''}',
                              '${widget.info['vatInclusivePrices'] ?? ''}',
                              '${widget.info['beforeVatPrices'] ?? ''}',

                              '${widget.info['code'] ?? ''}',

                              'sent', // status,
                              // salesInvoiceController.newRowMap,
                              orderLines1,
                              '${widget.info['inputDate'] ?? ''}',
                              '${widget.info['invoiceDeliveryDate'] ?? ''}',
                              orderedKeys,
                            );
                            if (res['success'] == true) {
                              // pendingDocsController.getAllPendingDocs();
                              salesInvoiceController
                                  .getAllSalesInvoiceFromBack();
                              homeController.selectedTab.value =
                                  "sales_invoice_summary";
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
                            }
                          },
                          child: Icon(
                            Icons.send,
                            color: Primary.primary,
                            size: 17.00,
                          ),
                        ),
                      ),
                      Tooltip(
                        message: 'cancel'.tr,
                        child: InkWell(
                          onTap: () async {
                            Map<int, Map<String, dynamic>> orderLines1 = {};
                            List<int> orderedKeys = [];
                            Map<int, dynamic> orderLinesMap = {
                              for (
                                int i = 0;
                                i < widget.info['orderLines'].length;
                                i++
                              )
                                (i + 1): widget.info['orderLines'][i],
                            };

                            for (int i = 0; i < orderLinesMap.length; i++) {
                              orderedKeys.add(i + 1);
                              Map<String, dynamic> selectedOrderLine =
                                  orderLinesMap[i + 1];
                              orderLines1[i + 1] = {};
                              if (selectedOrderLine['line_type_id'] == 1) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';

                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] = '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 2) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] =
                                    selectedOrderLine['item_id']?.toString() ??
                                    '';

                                orderLines1[i + 1]!['itemName'] =
                                    selectedOrderLine['item_name'] ?? '';
                                orderLines1[i + 1]!['item_main_code'] =
                                    selectedOrderLine['item_main_code'] ?? '';
                                orderLines1[i + 1]!['item_discount'] =
                                    selectedOrderLine['item_discount']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_description'] =
                                    selectedOrderLine['item_description'] ?? '';
                                orderLines1[i + 1]!['item_quantity'] =
                                    selectedOrderLine['item_quantity']
                                        ?.toString() ??
                                    '';

                                orderLines1[i + 1]!['item_unit_price'] =
                                    selectedOrderLine['item_unit_price']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_total'] =
                                    selectedOrderLine['item_total']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 3) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1
                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] =
                                    selectedOrderLine['combo_name'] ?? '';
                                orderLines1[i + 1]!['item_main_code'] =
                                    selectedOrderLine['combo_code'] ?? '';
                                orderLines1[i + 1]!['item_discount'] =
                                    selectedOrderLine['combo_discount']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_description'] =
                                    selectedOrderLine['combo_description'] ??
                                    '';
                                orderLines1[i + 1]!['item_quantity'] =
                                    selectedOrderLine['combo_quantity']
                                        ?.toString() ??
                                    '';

                                orderLines1[i + 1]!['item_unit_price'] =
                                    selectedOrderLine['combo_unit_price']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_total'] =
                                    selectedOrderLine['combo_total']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['title'] =
                                    selectedOrderLine['title'] ?? '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] =
                                    selectedOrderLine['combo_id']?.toString() ??
                                    '';
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 4) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';

                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] = '';
                                orderLines1[i + 1]!['note'] = '';
                                if (selectedOrderLine['image'] != null &&
                                    selectedOrderLine['image'].isNotEmpty) {
                                  try {
                                    final response = await http.get(
                                      Uri.parse(
                                        '$baseImage${selectedOrderLine['image']}',
                                      ),
                                    );

                                    if (response.statusCode == 200) {
                                      imageFile = response.bodyBytes;
                                    } else {
                                      imageFile = Uint8List(
                                        0,
                                      ); // Set to empty if loading fails
                                    }
                                  } catch (e) {
                                    imageFile = Uint8List(
                                      0,
                                    ); // Set to empty if loading fails
                                  }
                                } else {
                                  imageFile = Uint8List(
                                    0,
                                  ); // Set to empty if no image URL
                                }
                                orderLines1[i + 1]!['image'] = imageFile;
                                // Add more fields as needed
                              }
                              if (selectedOrderLine['line_type_id'] == 5) {
                                // Map the fields you want to copy from selectedOrderLine to orderLines1

                                orderLines1[i + 1]!['line_type_id'] =
                                    selectedOrderLine['line_type_id']
                                        ?.toString() ??
                                    '';
                                orderLines1[i + 1]!['item_id'] = '';

                                orderLines1[i + 1]!['itemName'] = '';
                                orderLines1[i + 1]!['item_main_code'] = '';
                                orderLines1[i + 1]!['item_discount'] = '0';
                                orderLines1[i + 1]!['item_description'] = '';
                                orderLines1[i + 1]!['item_quantity'] = '0';

                                orderLines1[i + 1]!['item_unit_price'] = '0';
                                orderLines1[i + 1]!['item_total'] = '0';
                                orderLines1[i + 1]!['title'] = '';
                                orderLines1[i + 1]!['note'] =
                                    selectedOrderLine['note'] ?? '';
                                orderLines1[i + 1]!['combo'] = '';
                                // Add more fields as needed
                              }
                            }

                            var res = await updateSalesInvoice(
                              '${widget.info['id']}',
                              false,
                              '${widget.info['reference'] ?? ''}',
                              clientId,

                              '${widget.info['valueDate'] ?? ''}',
                              warehouseId,
                              '', //todo paymentTermsController.text,
                              pricelistId,
                              currencyId,
                              '${widget.info['termsAndConditions']}',
                              salespersonId,
                              commissionMethodId,
                              cashMethodId,
                              '${widget.info['commissionRate'] ?? ''}',
                              '${widget.info['commissionTotal'] ?? ''}',
                              '${widget.info['totalBeforeVat'] ?? '0.0'}', //total before vat
                              '${widget.info['specialDiscountAmount'] ?? '0'}', // inserted by user
                              '${widget.info['specialDiscount'] ?? '0'}', // calculated
                              '${widget.info['globalDiscountAmount'] ?? ''}',
                              '${widget.info['globalDiscount'] ?? ''}',
                              '${widget.info['vat'] ?? ''}', //vat
                              '${widget.info['vatLebanese'] ?? ''}',
                              '${widget.info['total'] ?? ''}',
                              '${widget.info['vatExempt'] ?? ''}',
                              '${widget.info['notPrinted'] ?? ''}',
                              '${widget.info['printedAsVatExempt'] ?? ''}',
                              '${widget.info['printedAsPercentage'] ?? ''}',
                              '${widget.info['vatInclusivePrices'] ?? ''}',
                              '${widget.info['beforeVatPrices'] ?? ''}',

                              '${widget.info['code'] ?? ''}',

                              'cancelled', // status,

                              orderLines1,
                              '${widget.info['inputDate'] ?? ''}',
                              '${widget.info['invoiceDeliveryDate'] ?? ''}',
                              orderedKeys,
                            );
                            if (res['success'] == true) {
                              // pendingDocsController.getAllPendingDocs();
                              salesInvoiceController
                                  .getAllSalesInvoiceFromBack();
                              homeController.selectedTab.value =
                                  "sales_invoice_summary";
                              CommonWidgets.snackBar('Success', res['message']);
                            } else {
                              CommonWidgets.snackBar('error', res['message']);
                            }
                          },
                          child: Icon(
                            Icons.cancel_outlined,
                            color: Primary.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ReusableMore(
                  //   itemsList: [
                  //     PopupMenuItem<String>(
                  //       value: '1',
                  //       onTap: () async {
                  //         itemsInfoPrint = [];
                  //         salesInvoiceItemInfo = {};
                  //         totalAllItems = 0;
                  //         cont.totalAllItems = 0;
                  //         totalAllItems = 0;
                  //         cont.totalAllItems = 0;
                  //         totalPriceAfterDiscount = 0;
                  //         additionalSpecialDiscount = 0;
                  //         totalPriceAfterSpecialDiscount = 0;
                  //         totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
                  //             0;
                  //         vatBySalesInvoiceCurrency = 0;
                  //         vatBySalesInvoiceCurrency = 0;
                  //         finalPriceBySalesInvoiceCurrency = 0;
                  //
                  //         for (var item in widget.info['orderLines']) {
                  //           if ('${item['line_type_id']}' == '2') {
                  //             qty = item['item_quantity'];
                  //             var map =
                  //                 cont.itemsMap[item['item_id'].toString()];
                  //             itemName = map['item_name'];
                  //             itemPrice = double.parse(
                  //               '${item['item_unit_price'] ?? '0'}',
                  //             );
                  //             //     map['unitPrice'] ?? 0.0;
                  //             // formatDoubleWithCommas(map['unitPrice']);
                  //
                  //             itemDescription = item['item_description'];
                  //
                  //             itemImage =
                  //                 '${map['images']}' != '[]'
                  //                     ? '$baseImage${map['images'][0]['img_url']}'
                  //                     : '';
                  //             // itemCurrencyName = map['currency']['name'];
                  //             // itemCurrencySymbol = map['currency']['symbol'];
                  //             // itemCurrencyLatestRate =
                  //             //     map['currency']['latest_rate'];
                  //             var firstBrandObject = map['itemGroups']
                  //                 .firstWhere(
                  //                   (obj) =>
                  //                       obj["root_name"]?.toLowerCase() ==
                  //                       "brand".toLowerCase(),
                  //                   orElse: () => null,
                  //                 );
                  //             brand =
                  //                 firstBrandObject == null
                  //                     ? ''
                  //                     : firstBrandObject['name'] ?? '';
                  //             itemTotal = double.parse('${item['item_total']}');
                  //             // itemTotal = double.parse(qty) * itemPrice;
                  //             totalAllItems += itemTotal;
                  //             salesInvoiceItemInfo = {
                  //               'line_type_id': '2',
                  //               'item_name': itemName,
                  //               'item_description': itemDescription,
                  //               'item_quantity': qty,
                  //               'item_discount': item['item_discount'] ?? '0',
                  //               'item_unit_price': formatDoubleWithCommas(
                  //                 itemPrice,
                  //               ),
                  //               'item_total': formatDoubleWithCommas(itemTotal),
                  //               'item_image': itemImage,
                  //               'item_brand': brand,
                  //               'title': '',
                  //               'isImageList': false,
                  //               'note': '',
                  //               'image': '',
                  //             };
                  //             itemsInfoPrint.add(salesInvoiceItemInfo);
                  //           } else if ('${item['line_type_id']}' == '3') {
                  //             var qty = item['item_quantity'];
                  //             // var map =
                  //             // cont
                  //             //     .combosMap[item['combo_id']
                  //             //     .toString()];
                  //             var ind = cont.combosIdsList.indexOf(
                  //               item['combo_id'].toString(),
                  //             );
                  //             var itemName = cont.combosNamesList[ind];
                  //             var itemPrice = double.parse(
                  //               '${item['combo_price'] ?? 0.0}',
                  //             );
                  //             var itemDescription = item['combo_description'];
                  //
                  //             var itemTotal = double.parse(
                  //               '${item['combo_total']}',
                  //             );
                  //             // double.parse(qty) * itemPrice;
                  //             var salesInvoiceItemInfo = {
                  //               'line_type_id': '3',
                  //               'item_name': itemName,
                  //               'item_description': itemDescription,
                  //               'item_quantity': qty,
                  //               'item_unit_price': formatDoubleWithCommas(
                  //                 itemPrice,
                  //               ),
                  //               'item_discount': item['combo_discount'] ?? '0',
                  //               'item_total': formatDoubleWithCommas(itemTotal),
                  //               'note': '',
                  //               'item_image': '',
                  //               'item_brand': '',
                  //               'isImageList': false,
                  //               'title': '',
                  //               'image': '',
                  //             };
                  //             itemsInfoPrint.add(salesInvoiceItemInfo);
                  //           } else if ('${item['line_type_id']}' == '1') {
                  //             var salesInvoiceItemInfo = {
                  //               'line_type_id': '1',
                  //               'item_name': '',
                  //               'item_description': '',
                  //               'item_quantity': '',
                  //               'item_unit_price': '',
                  //               'item_discount': '0',
                  //               'item_total': '',
                  //               'item_image': '',
                  //               'item_brand': '',
                  //               'note': '',
                  //               'isImageList': false,
                  //               'title': item['title'],
                  //               'image': '',
                  //             };
                  //             itemsInfoPrint.add(salesInvoiceItemInfo);
                  //           } else if ('${item['line_type_id']}' == '5') {
                  //             var salesInvoiceItemInfo = {
                  //               'line_type_id': '5',
                  //               'item_name': '',
                  //               'item_description': '',
                  //               'item_quantity': '',
                  //               'item_unit_price': '',
                  //               'item_discount': '0',
                  //               'item_total': '',
                  //               'item_image': '',
                  //               'item_brand': '',
                  //               'title': '',
                  //               'note': item['note'],
                  //               'isImageList': false,
                  //               'image': '',
                  //             };
                  //             itemsInfoPrint.add(salesInvoiceItemInfo);
                  //           } else if ('${item['line_type_id']}' == '4') {
                  //             var salesInvoiceItemInfo = {
                  //               'line_type_id': '4',
                  //               'item_name': '',
                  //               'item_description': '',
                  //               'item_quantity': '',
                  //               'item_unit_price': '',
                  //               'item_discount': '0',
                  //               'item_total': '',
                  //               'item_image': '',
                  //               'item_brand': '',
                  //               'title': '',
                  //               'note': '',
                  //               'image': '$baseImage${item['image']}',
                  //               'isImageList': false,
                  //             };
                  //             itemsInfoPrint.add(salesInvoiceItemInfo);
                  //           }
                  //         }
                  //         // var primaryCurrency = await getCompanyPrimaryCurrencyFromPref();
                  //         // var result = exchangeRatesController
                  //         //     .exchangeRatesList
                  //         //     .firstWhere(
                  //         //       (item) =>
                  //         //   item["currency"] == primaryCurrency,
                  //         //   orElse: () => null,
                  //         // );
                  //         // var primaryLatestRate=
                  //         // result != null
                  //         //     ? '${result["exchange_rate"]}'
                  //         //     : '1';
                  //         // discountOnAllItem =
                  //         //     totalAllItems *
                  //         //     double.parse(
                  //         //       widget.info['globalDiscount'] ?? '0',
                  //         //     ) /
                  //         //     100;
                  //
                  //         totalPriceAfterDiscount =
                  //             totalAllItems - discountOnAllItem;
                  //         additionalSpecialDiscount =
                  //             totalPriceAfterDiscount *
                  //             double.parse(
                  //               widget.info['specialDiscount'] ?? '0',
                  //             ) /
                  //             100;
                  //         totalPriceAfterSpecialDiscount =
                  //             totalPriceAfterDiscount -
                  //             additionalSpecialDiscount;
                  //         totalPriceAfterSpecialDiscountBysalesInvoiceCurrency =
                  //             totalPriceAfterSpecialDiscount;
                  //         vatBySalesInvoiceCurrency =
                  //             '${widget.info['vatExempt']}' == '1'
                  //                 ? 0
                  //                 : (totalPriceAfterSpecialDiscountBysalesInvoiceCurrency *
                  //                         double.parse(
                  //                           await getCompanyVatFromPref(),
                  //                         )) /
                  //                     100;
                  //         finalPriceBySalesInvoiceCurrency =
                  //             totalPriceAfterSpecialDiscountBysalesInvoiceCurrency;
                  //         vatBySalesInvoiceCurrency;
                  //
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //             builder: (BuildContext context) {
                  //               return PrintSalesInvoice(
                  //                 isPrintedAs0:
                  //                     '${widget.info['printedAsPercentage']}' ==
                  //                             '1'
                  //                         ? true
                  //                         : false,
                  //                 isVatNoPrinted:
                  //                     '${widget.info['notPrinted']}' == '1'
                  //                         ? true
                  //                         : false,
                  //                 isPrintedAsVatExempt:
                  //                     '${widget.info['printedAsVatExempt']}' ==
                  //                             '1'
                  //                         ? true
                  //                         : false,
                  //                 isInSalesInvoice: true,
                  //                 salesInvoiceNumber:
                  //                     widget.info['salesInvoiceNumber'] ?? '',
                  //                 creationDate: widget.info['valueDate'] ?? '',
                  //                 ref: widget.info['reference'] ?? '',
                  //                 receivedUser: '',
                  //                 senderUser: homeController.userName,
                  //                 status: widget.info['status'] ?? '',
                  //                 totalBeforeVat:
                  //                     widget.info['totalBeforeVat'] ?? '',
                  //                 discountOnAllItem:
                  //                     discountOnAllItem.toString(),
                  //                 totalAllItems:
                  //                 // totalAllItems.toString()  ,
                  //                 formatDoubleWithCommas(
                  //                   totalPriceAfterDiscount,
                  //                 ),
                  //
                  //                 globalDiscount:
                  //                     widget.info['globalDiscount'] ?? '0',
                  //
                  //                 totalPriceAfterDiscount:
                  //                     formatDoubleWithCommas(
                  //                       totalPriceAfterDiscount,
                  //                     ),
                  //                 additionalSpecialDiscount:
                  //                     additionalSpecialDiscount.toStringAsFixed(
                  //                       2,
                  //                     ),
                  //                 totalPriceAfterSpecialDiscount:
                  //                     formatDoubleWithCommas(
                  //                       totalPriceAfterSpecialDiscount,
                  //                     ),
                  //                 // itemCurrencyName: itemCurrencyName,
                  //                 // itemCurrencySymbol: itemCurrencySymbol,
                  //                 // itemCurrencyLatestRate:
                  //                 //     itemCurrencyLatestRate,
                  //                 totalPriceAfterSpecialDiscountBysalesInvoiceCurrency:
                  //                     formatDoubleWithCommas(
                  //                       totalPriceAfterSpecialDiscountBysalesInvoiceCurrency,
                  //                     ),
                  //
                  //                 vatBySalesInvoiceCurrency:
                  //                     formatDoubleWithCommas(
                  //                       vatBySalesInvoiceCurrency,
                  //                     ),
                  //                 finalPriceBySalesInvoiceCurrency:
                  //                     formatDoubleWithCommas(
                  //                       finalPriceBySalesInvoiceCurrency,
                  //                     ),
                  //                 specialDisc: specialDisc.toString(),
                  //                 specialDiscount:
                  //                     widget.info['specialDiscount'] ?? '0',
                  //                 specialDiscountAmount:
                  //                     widget.info['specialDiscountAmount'] ??
                  //                     '',
                  //                 salesPerson:
                  //                     widget.info['salesperson'] != null
                  //                         ? widget.info['salesperson']['name']
                  //                         : '---',
                  //                 salesInvoiceCurrency:
                  //                     widget.info['currency']['name'] ?? '',
                  //                 salesInvoiceCurrencySymbol:
                  //                     widget.info['currency']['symbol'] ?? '',
                  //                 salesInvoiceCurrencyLatestRate:
                  //                     widget.info['currency']['latest_rate'] ??
                  //                     '',
                  //                 clientPhoneNumber:
                  //                     widget.info['client'] != null
                  //                         ? widget.info['client']['phoneNumber'] ??
                  //                             '---'
                  //                         : "---",
                  //                 clientName:
                  //                     widget.info['client']['name'] ?? '',
                  //                 termsAndConditions:
                  //                     widget.info['termsAndConditions'] ?? '',
                  //                 itemsInfoPrint: itemsInfoPrint,
                  //               );
                  //             },
                  //           ),
                  //         );
                  //       },
                  //       child: Text('preview'.tr),
                  //     ),
                  //     PopupMenuItem<String>(
                  //       value: '2',
                  //       onTap: () async {
                  //         showDialog<String>(
                  //           context: context,
                  //           builder:
                  //               (BuildContext context) => AlertDialog(
                  //                 backgroundColor: Colors.white,
                  //                 shape: const RoundedRectangleBorder(
                  //                   borderRadius: BorderRadius.all(
                  //                     Radius.circular(9.0),
                  //                   ),
                  //                 ),
                  //                 elevation: 0.0,
                  //                 content: UpdateSalesInvoiceDialog(
                  //                   index: widget.index,
                  //                   info: widget.info,
                  //                 ),
                  //               ),
                  //         );
                  //       },
                  //       child: Text('Update'.tr),
                  //     ),
                  //   ],
                  // ),
                );
              },
            ),
            TableItem(
              text: '${widget.info['invoiceDeliveryDate'] ?? '---'}',
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.07
                      : 150,
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.01),
          ],
        ),
      ),
    );
  }
}
