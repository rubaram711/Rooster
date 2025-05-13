import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Widgets/reusable_btn.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/reusable_add_card.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';

TextEditingController commissionGrantedController = TextEditingController();
List tabsList = [
  'general',
  'properties',
];

List tabsContent = [
  const GeneralTabInSalesmen(),
  const PropertiesTabInSalesmen(),
];

class SalesmenDialogContent extends StatefulWidget {
  const SalesmenDialogContent({super.key});

  @override
  State<SalesmenDialogContent> createState() =>
      _SalesmenDialogContentState();
}

class _SalesmenDialogContentState
    extends State<SalesmenDialogContent> {
  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.9,
      margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DialogTitle(text: 'salesmen'.tr),
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
              )
            ],
          ),
          gapH24,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Wrap(
                  spacing: 0.0,
                  direction: Axis.horizontal,
                  children: tabsList
                      .map((element) => _buildTabChipItem(
                      element,
                      // element['id'],
                      // element['name'],
                      tabsList.indexOf(element)))
                      .toList()),
            ],
          ),
          tabsContent[selectedTabIndex],
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: (){
                    setState(() {
                      //todo
                      // codeController.clear();
                      // mainDescriptionController.clear();
                      // shortDescriptionController.clear();
                      // secondLanguageController.clear();
                      // discLineLimitController.clear();
                      // supplierCodeController.clear();
                      // alternativeCodeController.clear();
                      // barcodeController.clear();
                    });
                  },
                  child: Text('discard'.tr,style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Primary.primary
                  ),)),
              gapW24,
              ReusableButtonWithColor(btnText: 'save'.tr, onTapFunction: (){}, width: 100, height: 35),
            ],
          )
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
                    topRight: Radius.circular(9)))),
        child: Container(
          // width: MediaQuery.of(context).size.width * 0.09,
          // height: MediaQuery.of(context).size.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
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
                  offset: const Offset(0, 3),
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


class GeneralTabInSalesmen extends StatefulWidget {
  const GeneralTabInSalesmen({super.key});

  @override
  State<GeneralTabInSalesmen> createState() => _GeneralTabInSalesmenState();
}

class _GeneralTabInSalesmenState extends State<GeneralTabInSalesmen> {
  List infoList=[
    {
      'code':'Jad',
      'name':'Jad',
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          decoration: BoxDecoration(
              color: Primary.primary,
              borderRadius: const BorderRadius.all(Radius.circular(6))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TableTitle(
                text: 'code'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'name'.tr,
                width: MediaQuery.of(context).size.width * 0.07,
              ),
              TableTitle(
                text: 'discontinued'.tr,
                width: MediaQuery.of(context).size.width * 0.06,
              ),
              TableTitle(
                text: '',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height * 0.1,
          child: ListView.builder(
            itemCount: infoList.length, //products is data from back res
            itemBuilder: (context, index) => groupAsRowInTable(
              infoList[index],
              index,
              infoList.length,
            ),
          ),
        ),
        ReusableAddCard(
          text: 'new_salesmen'.tr,
          onTap: () {},
        ),
      ],
    );
  }
bool isChecked=false;
  groupAsRowInTable(Map altCode, int index, int altCodesListLength) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TableItem(
            text: '${altCode['code'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          TableItem(
            text: '${altCode['name'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.07,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.06,
            child:Checkbox(
              // checkColor: Colors.white,
              // fillColor: MaterialStateProperty.resolveWith(getColor),
              value: isChecked,
              onChanged: (bool? value) {
                setState(() {
                  isChecked = value!;
                });
              },
            )
          ),
          TableItem(
            text: '',
            width: MediaQuery.of(context).size.width * 0.47,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.03,
            child: InkWell(
              onTap: () {
                setState(() {
                  // altCodesList.removeAt(index);
                });
              },
              child: Icon(
                Icons.delete_outline,
                color: Primary.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class PropertiesTabInSalesmen extends StatefulWidget {
  const PropertiesTabInSalesmen({super.key});

  @override
  State<PropertiesTabInSalesmen> createState() => _PropertiesTabInSalesmenState();
}

class _PropertiesTabInSalesmenState extends State<PropertiesTabInSalesmen> {
  String selectedCommissionsPayment='upon total cashing of invoice';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        gapH32,
        Row(
          children: [
            ReusableInputNumberField(
              controller: commissionGrantedController,
              textFieldWidth: MediaQuery.of(context).size.width * 0.065,
              rowWidth: MediaQuery.of(context).size.width * 0.165,
              onChangedFunc: () {},
              validationFunc: () {},
              text: 'commission_granted'.tr,
            ),
            gapW32,
            DropdownMenu<String>(
              width: MediaQuery.of(context).size.width * 0.25,
              // requestFocusOnTap: false,
              enableSearch: true,
              hintText: 'on invoice net sales amount total',
              inputDecorationTheme: InputDecorationTheme(
                // filled: true,
                contentPadding:
                const EdgeInsets.fromLTRB(20, 0, 25, 5),
                // outlineBorder: BorderSide(color: Colors.black,),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                      width: 1),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                      width: 2),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(9)),
                ),
              ),
              // menuStyle: ,
              dropdownMenuEntries: ['upon total cashing of invoice']
                  .map<DropdownMenuEntry<String>>(
                      (String option) {
                    return DropdownMenuEntry<String>(
                      value: option,
                      label: option,
                      // enabled: option.label != 'Grey',
                      // style: MenuItemButton.styleFrom(
                      // foregroundColor: color.color,
                      // ),
                    );
                  }).toList(),
              onSelected: (String? val) {
                setState(() {
                  selectedCommissionsPayment = val!;
                });
              },
            ),
          ],
        ),
        gapH16,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('commissions_payment'.tr),
            DropdownMenu<String>(
              width: MediaQuery.of(context).size.width * 0.68,
              // requestFocusOnTap: false,
              enableSearch: true,
              hintText: 'upon total cashing of invoice',
              inputDecorationTheme: InputDecorationTheme(
                // filled: true,
                contentPadding:
                const EdgeInsets.fromLTRB(20, 0, 25, 5),
                // outlineBorder: BorderSide(color: Colors.black,),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                      width: 1),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                      width: 2),
                  borderRadius: const BorderRadius.all(
                      Radius.circular(9)),
                ),
              ),
              // menuStyle: ,
              dropdownMenuEntries: ['upon total cashing of invoice']
                  .map<DropdownMenuEntry<String>>(
                      (String option) {
                    return DropdownMenuEntry<String>(
                      value: option,
                      label: option,
                      // enabled: option.label != 'Grey',
                      // style: MenuItemButton.styleFrom(
                      // foregroundColor: color.color,
                      // ),
                    );
                  }).toList(),
              onSelected: (String? val) {
                setState(() {
                  selectedCommissionsPayment = val!;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}



