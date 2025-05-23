import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String selectedBtn = 'last24hour'.tr;
  List quotationsList=[
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
      'order':'00006'
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
      'order':'00004'
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
      'order':'00002'
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
      'order':'00006'
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
      'order':'00006'
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
      'order':'00006'
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
      'order':'00006'
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
      'order':'00006'
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
      'order':'00006'
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
      'order':'00006'
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
      'order':'00006'
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
    }


  ];
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.02),
      height: MediaQuery.of(context).size.height * 0.85,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PageTitle(text: 'dashboard'.tr),
              ],
            ),
            gapH24,
            Row(
              children: [
                underTitleBtn('last24hour'.tr, () {
                  setState(() {
                    selectedBtn = 'last24hour'.tr;
                  });
                }, selectedBtn),
                gapW16,
                underTitleBtn('last_weeks'.tr, () {
                  setState(() {
                    selectedBtn = 'last_weeks'.tr;
                  });
                }, selectedBtn),
                gapW16,
                underTitleBtn('last_month'.tr, () {
                  setState(() {
                    selectedBtn = 'last_month'.tr;
                  });
                }, selectedBtn),
                gapW16,
                underTitleBtn('last_year'.tr, () {
                  setState(() {
                    selectedBtn = 'last_year'.tr;
                  });
                }, selectedBtn),
              ],
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ReusableRatesCard(
                              text: 'quotations'.tr,
                              extension: '',
                              image: 'assets/images/quotations.png',
                              number: '80',
                            ),
                            ReusableRatesCard(
                              text: 'orders'.tr,
                              extension: '%',
                              image: 'assets/images/orders.png',
                              number: '70',
                            ),
                            ReusableRatesCard(
                              text: 'revenue'.tr,
                              extension: 'usd'.tr,
                              image: 'assets/images/revenue.png',
                              number: '80.000',
                            ),
                            ReusableRatesCard(
                              text: 'average_order'.tr,
                              extension: 'usd'.tr,
                              image: 'assets/images/averageOrder.png',
                              number: '80',
                            ),
                          ],
                        ),
                        gapH24,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(9))),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'top_quotations'.tr,
                                    style: TextStyle(
                                        fontSize: 17, color: Primary.primary),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.13,
                                    child: ReusableSearchTextField(
                                      hint: '${"search".tr}...',
                                      textEditingController: searchController,
                                      onChangedFunc: () {},
                                      validationFunc: () {},
                                    ),
                                  ),
                                ],
                              ),
                              Divider(
                                color: Others.divider,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width:  MediaQuery.of(context).size.width * 0.07,
                                    child: Center(
                                      child: Text(
                                        'quotation'.tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: TypographyColor.titleTable),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.07,
                                    child: Center(
                                      child: Text(
                                        'customer'.tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: TypographyColor.titleTable),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.07,
                                    child: Center(
                                      child: Text(
                                        'salesperson'.tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: TypographyColor.titleTable),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.07,
                                    child: Center(
                                      child: Text(
                                        'revenue'.tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: TypographyColor.titleTable),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.07,
                                    child: Center(
                                      child: Text(
                                        'due_date'.tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: TypographyColor.titleTable),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.05,
                                    child: Center(
                                      child: Text(
                                        'status'.tr,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: TypographyColor.titleTable),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                color: Colors.white,
                                height: 150,
                                child: ListView.builder(
                                  itemCount: 3,
                                  itemBuilder: (context, index) => Column(
                                    children: [
                                      Divider(
                                        color: Others.divider,
                                      ),
                                      Row(
                                        children: [
                                          TopQuotationAsRowInTable(
                                            isDesktop: true,
                                            info: quotationsList[index],
                                            index: index,
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Container(
                                              // padding: EdgeInsets.all(5),
                                              width:  MediaQuery.of(context).size.width * 0.05,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: TypographyColor
                                                      .titleTable,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'details'.tr,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: TypographyColor
                                                          .titleTable),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )),
                gapW24,
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.22,
                    height: 350,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(9))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'overview'.tr,
                            style:
                                TextStyle(fontSize: 17, color: Primary.primary),
                          ),
                          gapH8,
                          const Text('Lorem ipsum dolor sit amet consectetur'),
                          gapH10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.23,
                                  child: Image.asset('assets/images/chart1.png')),
                            ],
                          ),
                          gapH10,
                          Text(
                            'profit'.tr,
                            style:
                                TextStyle(fontSize: 17, color: Primary.primary),
                          ),
                          gapH8,
                          const Text('Lorem ipsum dolor sit amet consectetur')
                        ],
                      ),
                    )),
              ],
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.36,
                    height: 300,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(9))),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'monthly_sales'.tr,
                            style:
                            TextStyle(fontSize: 17, color: Primary.primary),
                          ),
                          gapH10,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width * 0.33,
                                  height: MediaQuery.of(context).size.height * 0.25,
                                  child: Image.asset('assets/images/chart2.png')),
                            ],
                          ),
                          gapH10,
                        ],
                      ),
                    )),
                gapW24,
                Container(
                  padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01,vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.36,
                  height: 300,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.all(Radius.circular(9))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.start,
                        children: [
                          Text(
                            'top_sales_order'.tr,
                            style: TextStyle(
                                fontSize: 17, color: Primary.primary),
                          ),
                        ],
                      ),
                      gapH16,
                      Divider(
                        color: Others.divider,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'order'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'customer'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'salesperson'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'revenue'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.05,
                            child: Center(
                              child: Text(
                                'status'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        height: 150,
                        child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Divider(
                                color: Others.divider,
                              ),
                              TopSalesOrderAsRowInTable(
                                info: quotationsList[index],
                                index: index,
                              ),
                            ],
                          ),
                        ),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.235,
                  height: 270,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.all(Radius.circular(9))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Text(
                            'top_countries'.tr,
                            style: TextStyle(
                                fontSize: 17, color: Primary.primary),
                          ),
                        ],
                      ),
                      gapH16,
                      Divider(
                        color: Others.divider,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'country'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'orders'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'revenue'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        height: 150,
                        child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Divider(color: Others.divider,),
                              TopSalesCountriesAsRowInTable(
                                info: quotationsList[index],
                                index: index,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // gapW24,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.235,
                  height: 270,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.all(Radius.circular(9))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Text(
                            'top_products'.tr,
                            style: TextStyle(
                                fontSize: 17, color: Primary.primary),
                          ),
                        ],
                      ),
                      gapH16,
                      Divider(color: Others.divider,),
                      Row(
                        children: [
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'country'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'orders'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'revenue'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        height: 150,
                        child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Divider(color: Others.divider,),
                              TopSalesCountriesAsRowInTable(
                                info: quotationsList[index],
                                index: index,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // gapW24,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.235,
                  height: 270,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.all(Radius.circular(9))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        children: [
                          Text(
                            'top_customers'.tr,
                            style: TextStyle(
                                fontSize: 17, color: Primary.primary),
                          ),
                        ],
                      ),
                      gapH16,
                      Divider(color: Others.divider,),
                      Row(
                        children: [
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'country'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'orders'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                          SizedBox(
                            width:  MediaQuery.of(context).size.width * 0.07,
                            child: Center(
                              child: Text(
                                'revenue'.tr,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TypographyColor.titleTable),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.white,
                        height: 150,
                        child: ListView.builder(
                          itemCount: 3,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Divider(color: Others.divider,),
                              TopSalesCountriesAsRowInTable(
                                info: quotationsList[index],
                                index: index,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            gapH48
          ],
        ),
      ),
    );
  }

  underTitleBtn(String text, Function onTap, String selectedBtn) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Text(
        text,
        style: TextStyle(
          color: text == selectedBtn
              ? Primary.primary
              : TypographyColor.titleTable,
        ),
      ),
    );
  }
}

class ReusableRatesCard extends StatelessWidget {
  const ReusableRatesCard(
      {super.key,
      required this.image,
      required this.text,
      required this.number,
      required this.extension,
        this.isDesktop=true});
  final String image;
  final String text;
  final String number;
  final String extension;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Container(
      width:isDesktop? MediaQuery.of(context).size.width * 0.12:MediaQuery.of(context).size.width*0.4,
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.01),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(9))),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                    width:isDesktop? MediaQuery.of(context).size.width * 0.025:MediaQuery.of(context).size.width*0.05,
                    child: Image.asset(image)),
                gapW10,
                SizedBox(
                  width:isDesktop? MediaQuery.of(context).size.width * 0.06:MediaQuery.of(context).size.width*0.3,
                  child: Text(
                    text,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TypographyColor.titleTable),
                  ),
                ),
              ],
            ),
            gapH10,
            Row(
              children: [
                Text(
                  number,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: TypographyColor.titleTable),
                ),
                gapW4,
                Text(extension),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TopQuotationAsRowInTable extends StatelessWidget {
  const TopQuotationAsRowInTable(
      {super.key, required this.info, required this.index, required this.isDesktop});
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TableItem(
          isDesktop: isDesktop,
          text: '${info['order'] ?? ''}',
          width:isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.12,
        ),
        TableItem(
          isDesktop: isDesktop,
          text: '${info['customer'] ?? ''}',
          width: isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.12,
        ),
         TableItem(
           isDesktop: isDesktop,
          text: 'Jad al Deek', //'${info['salesperson'] ?? ''}',
          width: isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.15,
        ),
         TableItem(
           isDesktop: isDesktop,
          text: '200.000',
          width: isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.12,
        ),
         TableItem(
           isDesktop: isDesktop,
          text: '04.06.2023',
          width:  isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.13,
        ),
        SizedBox(
          width: isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.11,
          child: Center(
            child: CircleAvatar(
              radius: 6,
              backgroundColor: info['status'] == 'Pending'
                  ? Others.orangeStatusColor
                  : info['status'] == 'Cancelled'
                      ? Others.redStatusColor
                      : Others.greenStatusColor,
            ),
          ),
        ),
      ],
    );
  }
}


class TopSalesOrderAsRowInTable extends StatelessWidget {
  const TopSalesOrderAsRowInTable(
      {super.key, required this.info, required this.index, this.isDesktop=true});
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TableItem(
          text: '${info['order'] ?? ''}',
          width:isDesktop? MediaQuery.of(context).size.width * 0.07 :MediaQuery.of(context).size.width * 0.16,
        ),
        TableItem(
          text: '${info['customer'] ?? ''}',
          width: isDesktop? MediaQuery.of(context).size.width * 0.07 :MediaQuery.of(context).size.width * 0.16,
        ),
        TableItem(
          text: 'Jad al Deek', //'${info['salesperson'] ?? ''}',
          width: isDesktop? MediaQuery.of(context).size.width * 0.07 :MediaQuery.of(context).size.width * 0.19,
        ),
        TableItem(
          text: '200.000\$',
          width: isDesktop? MediaQuery.of(context).size.width * 0.07 :MediaQuery.of(context).size.width * 0.16,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.05,
          child: Center(
            child: CircleAvatar(
              radius: 6,
              backgroundColor: info['status'] == 'Pending'
                  ? Others.orangeStatusColor
                  : info['status'] == 'Cancelled'
                      ? Others.redStatusColor
                      : Others.greenStatusColor,
            ),
          ),
        ),
      ],
    );
  }
}

class TopSalesCountriesAsRowInTable extends StatelessWidget {
  const TopSalesCountriesAsRowInTable(
      {super.key, required this.info, required this.index, this.isDesktop=true});
  final Map info;
  final int index;
  final bool isDesktop;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TableItem(
          text: index==0?'Lebanon':index==1?'France':'qatar',
          width:isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.25,
        ),
         TableItem(
          text: 'Abed Nahouli',
          width: isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.25,
        ),
         TableItem(
          text: '200.000\$',
          width: isDesktop?  MediaQuery.of(context).size.width * 0.07: MediaQuery.of(context).size.width * 0.25,
        ),
      ],
    );
  }
}




class MobileDashboard extends StatefulWidget {
  const MobileDashboard({super.key});

  @override
  State<MobileDashboard> createState() => _MobileDashboardState();
}

class _MobileDashboardState extends State<MobileDashboard> {
  String selectedBtn = 'last24hour'.tr;
  List quotationsList=[
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Pending',
    },
    {
      'number':'Q230000019',
      'creation':'29/11/2023',
      'customer':'QUASAR',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Cancelled',
    },  {
      'number':'Q230000017',
      'creation':'27/11/2023',
      'customer':'Nahhouli',
      'salesperson':'',
      'task':'No Records',
      'total':'166.50',
      'status':'Quotation Sent',
    }


  ];
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height * 0.01,),
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PageTitle(text: 'dashboard'.tr),
              ],
            ),
            gapH24,
            Row(
              children: [
                underTitleBtn('last24hour'.tr, () {
                  setState(() {
                    selectedBtn = 'last24hour'.tr;
                  });
                }, selectedBtn),
                gapW16,
                underTitleBtn('last_weeks'.tr, () {
                  setState(() {
                    selectedBtn = 'last_weeks'.tr;
                  });
                }, selectedBtn),
                gapW16,
                underTitleBtn('last_month'.tr, () {
                  setState(() {
                    selectedBtn = 'last_month'.tr;
                  });
                }, selectedBtn),
                gapW16,
                underTitleBtn('last_year'.tr, () {
                  setState(() {
                    selectedBtn = 'last_year'.tr;
                  });
                }, selectedBtn),
              ],
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ReusableRatesCard(
                  isDesktop: false,
                  text: 'quotations'.tr,
                  extension: '',
                  image: 'assets/images/quotations.png',
                  number: '80',
                ),
                ReusableRatesCard(
                  isDesktop: false,
                  text: 'orders'.tr,
                  extension: '%',
                  image: 'assets/images/orders.png',
                  number: '70',
                ),
              ],
            ),
            gapH16,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ReusableRatesCard(
                  isDesktop: false,
                  text: 'revenue'.tr,
                  extension: 'usd'.tr,
                  image: 'assets/images/revenue.png',
                  number: '80.000',
                ),
                ReusableRatesCard(
                  isDesktop: false,
                  text: 'average_order'.tr,
                  extension: 'usd'.tr,
                  image: 'assets/images/averageOrder.png',
                  number: '80',
                ),
              ],
            ),
            gapH24,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(9))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'top_quotations'.tr,
                        style: TextStyle(
                            fontSize: 17, color: Primary.primary),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4,
                        child: ReusableSearchTextField(
                          hint: '${"search".tr}...',
                          textEditingController: searchController,
                          onChangedFunc: () {},
                          validationFunc: () {},
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Others.divider,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: Center(
                          child: Text(
                            'quotation'.tr,
                            style: TextStyle(
                              fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: Center(
                          child: Text(
                            'customer'.tr,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        child: Center(
                          child: Text(
                            'salesperson'.tr,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: Center(
                          child: Text(
                            'revenue'.tr,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.13,
                        child: Center(
                          child: Text(
                            'due_date'.tr,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.11,
                        child: Center(
                          child: Text(
                            'status'.tr,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    height: 160,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Divider(
                            color: Others.divider,
                          ),
                          Row(
                            children: [
                              TopQuotationAsRowInTable(
                                isDesktop: false,
                                info: quotationsList[index],
                                index: index,
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  // padding: EdgeInsets.all(5),
                                  width: 50,
                                  height: 25,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: TypographyColor
                                          .titleTable,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'details'.tr,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: TypographyColor
                                              .titleTable),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapH24,
            SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 350,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'overview'.tr,
                        style:
                        TextStyle(fontSize: 17, color: Primary.primary),
                      ),
                      gapH8,
                      const Text('Lorem ipsum dolor sit amet consectetur'),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/chart1.png'),
                        ],
                      ),
                      gapH10,
                      Text(
                        'profit'.tr,
                        style:
                        TextStyle(fontSize: 17, color: Primary.primary),
                      ),
                      gapH8,
                      const Text('Lorem ipsum dolor sit amet consectetur')
                    ],
                  ),
                )),
            gapH16,
            SizedBox(
              // width: MediaQuery.of(context).size.width * 0.36,
                height: 300,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(9))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'monthly_sales'.tr,
                        style:
                        TextStyle(fontSize: 17, color: Primary.primary),
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/chart2.png',width: MediaQuery.of(context).size.width * 0.5,height: 200,),
                        ],
                      ),
                      gapH10,
                    ],
                  ),
                )),
            gapH16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              // width: MediaQuery.of(context).size.width * 0.36,
              height: 350,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(9))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      Text(
                        'top_sales_order'.tr,
                        style: TextStyle(
                            fontSize: 17, color: Primary.primary),
                      ),
                    ],
                  ),
                  gapH16,
                  Divider(
                    color: Others.divider,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.16,
                        child: Center(
                          child: Text(
                            'order'.tr,
                            style: TextStyle(
                              fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.16,
                        child: Center(
                          child: Text(
                            'customer'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.19,
                        child: Center(
                          child: Text(
                            'salesperson'.tr,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.16,
                        child: Center(
                          child: Text(
                            'revenue'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.16,
                        child: Center(
                          child: Text(
                            'status'.tr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    height: 200,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Divider(
                            color: Others.divider,
                          ),
                          TopSalesOrderAsRowInTable(
                            isDesktop:false,
                            info: quotationsList[index],
                            index: index,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapH16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              // width: MediaQuery.of(context).size.width * 0.235,
              height: 270,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(9))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      Text(
                        'top_countries'.tr,
                        style: TextStyle(
                            fontSize: 17, color: Primary.primary),
                      ),
                    ],
                  ),
                  gapH16,
                  Divider(
                    color: Others.divider,
                  ),
                  Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'country'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'orders'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'revenue'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    height: 150,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Divider(color: Others.divider,),
                          TopSalesCountriesAsRowInTable(
                            isDesktop:false,
                            info: quotationsList[index],
                            index: index,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapH16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              // width: MediaQuery.of(context).size.width * 0.235,
              height: 270,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(9))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      Text(
                        'top_products'.tr,
                        style: TextStyle(
                            fontSize: 17, color: Primary.primary),
                      ),
                    ],
                  ),
                  gapH16,
                  Divider(color: Others.divider,),
                  Row(
                    children: [
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'country'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'orders'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'revenue'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    height: 150,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Divider(color: Others.divider,),
                          TopSalesCountriesAsRowInTable(
                            isDesktop:false,
                            info: quotationsList[index],
                            index: index,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapH16,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
              // width: MediaQuery.of(context).size.width * 0.235,
              height: 270,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.all(Radius.circular(9))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      Text(
                        'top_customers'.tr,
                        style: TextStyle(
                            fontSize: 17, color: Primary.primary),
                      ),
                    ],
                  ),
                  gapH16,
                  Divider(color: Others.divider,),
                  Row(
                    children: [
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'country'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'orders'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:  MediaQuery.of(context).size.width * 0.25,
                        child: Center(
                          child: Text(
                            'revenue'.tr,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: TypographyColor.titleTable),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.white,
                    height: 150,
                    child: ListView.builder(
                      itemCount: 3,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Divider(color: Others.divider,),
                          TopSalesCountriesAsRowInTable(
                            isDesktop:false,
                            info: quotationsList[index],
                            index: index,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapH48
          ],
        ),
      ),
    );
  }

  underTitleBtn(String text, Function onTap, String selectedBtn) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Text(
        text,
        style: TextStyle(
          color: text == selectedBtn
              ? Primary.primary
              : TypographyColor.titleTable,
        ),
      ),
    );
  }
}