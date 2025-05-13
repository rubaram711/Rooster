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


List tabsList = [
  'general',
];

List tabsContent = [
  const GeneralTabInSubReferences(),
];

class SubReferencesDialogContent extends StatefulWidget {
  const SubReferencesDialogContent({super.key});

  @override
  State<SubReferencesDialogContent> createState() =>
      _SubReferencesDialogContentState();
}

class _SubReferencesDialogContentState
    extends State<SubReferencesDialogContent> {
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
              DialogTitle(text: 'sub_references'.tr),
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
                      controller.clear();
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
TextEditingController controller = TextEditingController();
class GeneralTabInSubReferences extends StatefulWidget {
  const GeneralTabInSubReferences({super.key});

  @override
  State<GeneralTabInSubReferences> createState() => _GeneralTabInSubReferencesState();
}

class _GeneralTabInSubReferencesState extends State<GeneralTabInSubReferences> {
  List infoList=[
    {
      'code':'Color',
      'name':'Size',
    },{
      'code':'Color',
      'name':'Size',
    },
  ];
  List shortDescList=[
    {
      'code':'R',
      'description':'RED',
      'short_description':'RED'
    },{
      'code':'B',
      'description':'BLUE',
      'short_description':'BLUE'
    },
  ];
  bool is1Checked = false;
  bool is2Checked = false;
  bool is3Checked = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
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
                width: MediaQuery.of(context).size.width * 0.1,
              ),
              TableTitle(
                text: 'name'.tr,
                width: MediaQuery.of(context).size.width * 0.1,
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
          height: MediaQuery.of(context).size.height * 0.15,
          child: ListView.builder(
            itemCount: infoList.length, //products is data from back res
            itemBuilder: (context, index) => groupAsRowInTable(
              infoList[index],
              index,
              infoList.length,
            ),
          ),
        ),
        gapH16,
        ReusableAddCard(
          text: 'new_sub_references'.tr,
          onTap: () {},
        ),
        gapH16,
        DialogTextField(
          textEditingController: controller,
          text: 'sub_reference_type'.tr,
          rowWidth:  MediaQuery.of(context).size.width * 0.3,
          textFieldWidth:  MediaQuery.of(context).size.width * 0.15,
          validationFunc: (){} ,),
        gapH16,
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('when_printing_subrefs_print'.tr,style:const TextStyle(fontWeight:FontWeight.bold )),
              gapW16,
              Expanded(
                child: ListTile(
                  title: Text('code'.tr,style:const TextStyle(fontSize: 12)),
                  leading: Checkbox(
                    // checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: is1Checked,
                    onChanged: (bool? value) {
                      setState(() {
                        is1Checked = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('short_description'.tr,style:const TextStyle(fontSize: 12)),
                  leading: Checkbox(
                    // checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: is2Checked,
                    onChanged: (bool? value) {
                      setState(() {
                        is2Checked = value!;
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('long_description'.tr,style:const TextStyle(fontSize: 12)),
                  leading: Checkbox(
                    // checkColor: Colors.white,
                    // fillColor: MaterialStateProperty.resolveWith(getColor),
                    value: is3Checked,
                    onChanged: (bool? value) {
                      setState(() {
                        is3Checked = value!;
                      });
                    },
                  ),
                ),
              ),]),
        ),
        gapH16,
        is2Checked? Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.28,
              child: Column(
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
                          width: MediaQuery.of(context).size.width * 0.05,
                        ),
                        TableTitle(
                          text: 'description'.tr,
                          width: MediaQuery.of(context).size.width * 0.08,
                        ),
                        TableTitle(
                          text: 'short_description'.tr,
                          width: MediaQuery.of(context).size.width * 0.08,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    height: MediaQuery.of(context).size.height * 0.12,
                    child: ListView.builder(
                      itemCount: shortDescList.length, //products is data from back res
                      itemBuilder: (context, index) => shortDescAsRowInTable(
                        shortDescList[index],
                        index,
                        shortDescList.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            gapW32,
            Column(
              children: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    // padding: EdgeInsets.all(5),
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Primary.primary,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mode_edit_outlined,color: Primary.primary,),
                        gapW10,
                        Text(
                          'modify_r_value'.tr,
                          style: TextStyle(fontSize: 12, color: Primary.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                gapH10,
                InkWell(
                  onTap: () {},
                  child: Container(
                    // padding: EdgeInsets.all(5),
                    width: 200,
                    height: 35,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Primary.primary,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline,color: Primary.primary,),
                        gapW10,
                        Text(
                          'delete_r_value'.tr,
                          style: TextStyle(fontSize: 12, color: Primary.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ):const SizedBox()
      ],
    );
  }

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
            width: MediaQuery.of(context).size.width * 0.1,
          ),
          TableItem(
            text: '${altCode['name'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.1,
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

  shortDescAsRowInTable(Map altCode, int index, int altCodesListLength) {
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
            width: MediaQuery.of(context).size.width * 0.05,
          ),
          TableItem(
            text: '${altCode['description'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.08,
          ),
          TableItem(
            text: '${altCode['short_description'] ?? ''}',
            width: MediaQuery.of(context).size.width * 0.08,
          ),
        ],
      ),
    );
  }
}



