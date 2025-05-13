import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/const/Sizes.dart';
import '../../../Widgets/dialog_drop_menu.dart';
import '../../../const/colors.dart';


TextEditingController categoryController = TextEditingController();
class GroupingTabContent extends StatefulWidget {
  const GroupingTabContent({super.key});

  @override
  State<GroupingTabContent> createState() => _GroupingTabContentState();
}

class _GroupingTabContentState extends State<GroupingTabContent> {
  List addedGroupsList=[];
  // int counter = 0;
  // String? selectedItem = 'chair';
  ProductController productController=Get.find();
  HomeController homeController=Get.find();
  @override
  void initState() {
    // productController.reformatGroups();
    // productController.getMenuGroupsNames();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return SizedBox(
            height: homeController.isMobile.value?MediaQuery.of(context).size.height * 0.5:MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                homeController.isMobile.value?SizedBox():gapH28,
                DialogDropMenu(
                  controller: categoryController,
                  optionsList: cont.categoriesNames,
                  text: 'category'.tr,
                  hint: cont.categoriesNames[cont.categoriesIds.indexOf(cont.selectedCategoryId)],
                  rowWidth:homeController.isMobile.value?MediaQuery.of(context).size.height * 0.6: MediaQuery.of(context).size.width * 0.5,
                  textFieldWidth:homeController.isMobile.value?MediaQuery.of(context).size.height * 0.25: MediaQuery.of(context).size.width * 0.35,
                  onSelected:  (String? val) {
                    var index = cont.categoriesNames.indexOf(val!);
                    cont.setSelectedCategoryId(cont.categoriesIds[index]);
                  },
                ),
                gapH24,
                Container(
                  color: Colors.white,
                  height: homeController.isMobile.value?MediaQuery.of(context).size.height * 0.35:MediaQuery.of(context).size.height * 0.45,
                  child: ListView.builder(
                    itemCount: cont.groupsList.length, //products is data from back res
                    itemBuilder: (context, index) => GroupRow(
                      isMobile:homeController.isMobile.value,
                      data: cont.groupsList[index],
                      index: index,
                    ),
                  ),
                ),
                // const Spacer(),
                // ReusableBTNsRow(
                //   onBackClicked: (){
                //     cont.setSelectedTabIndex(1);
                //   },
                //   onDiscardClicked: (){
                //     categoryController.clear();
                //     cont.selectedGroupsIds=[];
                //     for(int i=0;i<cont.groupsList.length;i++){
                //       cont.addSelectedGroupsIdsForShow([],i);
                //       cont.addSelectedGroupsNamesForShow([],i);
                //       cont.textEditingControllerForGroups[i].clear();
                //     }
                //   },
                //   onNextClicked: (){
                //     cont.setSelectedTabIndex(3);
                //   },
                //   onSaveClicked: (){},
                // )
              ],
            ));
      }
    );
  }
  // addedGroupRow(int index){
  //   return Container(
  //     padding:const EdgeInsets.all(10),
  //     width:  MediaQuery.of(context).size.width * 0.05,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //       children: [
  //         Text('${'grouping'.tr} ${NumberToWordsEnglish.convert(index+1)}*'),
  //         Row(
  //           children: [
  //             DropdownMenu<String>(
  //               width: MediaQuery.of(context).size.width * 0.15,
  //               requestFocusOnTap: false,
  //               inputDecorationTheme: InputDecorationTheme(
  //                 // filled: true,
  //                 contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
  //                 // outlineBorder: BorderSide(color: Colors.black,),
  //                 enabledBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(
  //                       color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
  //                   borderRadius:
  //                   const BorderRadius.all(Radius.circular(9)),
  //                 ),
  //                 focusedBorder: OutlineInputBorder(
  //                   borderSide: BorderSide(
  //                       color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
  //                   borderRadius:
  //                   const BorderRadius.all(Radius.circular(9)),
  //                 ),
  //               ),
  //               // menuStyle: ,
  //               dropdownMenuEntries: groupsNamesList
  //                   .map<DropdownMenuEntry<String>>((String option) {
  //                 return DropdownMenuEntry<String>(
  //                   value: option,
  //                   label: option,
  //                 );
  //               }).toList(),
  //               onSelected: (String? val) {
  //                 setState(() {
  //                   selectedItem = val!;
  //                 });
  //               },
  //             ),
  //             SizedBox(
  //               width: MediaQuery.of(context).size.width * 0.03,
  //               child: InkWell(
  //                 onTap: () {
  //                  setState(() {
  //                    addedGroupsList.removeAt(index);
  //                  });
  //                 },
  //                 child: Icon(
  //                   Icons.delete_outline,
  //                   color: Primary.primary,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

}

class GroupRow extends StatefulWidget {
  const GroupRow({super.key, required this.data, required this.index, required this.isMobile});
final Map data;
final int index;
final bool isMobile;
  @override
  State<GroupRow> createState() => _GroupRowState();
}

class _GroupRowState extends State<GroupRow> {
  TextEditingController textEditingController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductController>(
      builder: (cont) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width:widget.isMobile?MediaQuery.of(context).size.width * 0.25:MediaQuery.of(context).size.width * 0.15,child: Text(widget.data['name']),),
              DropdownMenu<String>(
                width:widget.isMobile?MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.19,
                // requestFocusOnTap: false,
                enableSearch: true,
                controller:cont.textEditingControllerForGroups[widget.index],
                hintText: cont.selectedGroupsCodesForShow[widget.index].isNotEmpty? cont.selectedGroupsCodesForShow[widget.index][0]:'',
                inputDecorationTheme:
                InputDecorationTheme(
                  // filled: true,
                  hintStyle: const TextStyle(
                      fontStyle: FontStyle.italic),
                  contentPadding:
                  const EdgeInsets.fromLTRB(
                      20, 0, 25, 5),
                  // outlineBorder: BorderSide(color: Colors.black,),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Primary.primary
                            .withAlpha((0.2 * 255).toInt()),
                        width: 1),
                    borderRadius:
                    const BorderRadius.all(
                        Radius.circular(9)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Primary.primary
                            .withAlpha((0.4 * 255).toInt()),
                        width: 2),
                    borderRadius:
                    const BorderRadius.all(
                        Radius.circular(9)),
                  ),
                ),
                // menuStyle: ,
                menuHeight: 250,
                dropdownMenuEntries: cont
                    .childGroupsCodes[widget.index]
                    .map<DropdownMenuEntry<String>>(
                        (String option) {
                      return DropdownMenuEntry<String>(
                        value: option,
                        label: option,
                      );
                    }).toList(),
                enableFilter: true,
                onSelected: (String? val) {
                  var index = cont.childGroupsCodes[widget.index].indexOf(val!);
                  cont.addIdToSelectedGroupsIdsList(cont.groupsIds[widget.index][index]);
                  cont.addSelectedGroupsIdsForShow([cont.groupsIds[widget.index][index]], widget.index);
                  cont.addSelectedGroupsCodesForShow([val], widget.index);
                  cont.addSelectedGroupsNamesForShow([cont.childGroupsNames[widget.index][index]], widget.index);
                },
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.01),
              Container(
                height:widget.isMobile?55: 47,
                padding:const EdgeInsets.symmetric(horizontal: 10),
                width: widget.isMobile?MediaQuery.of(context).size.width * 0.2:MediaQuery.of(context).size.width * 0.15,
                decoration: BoxDecoration(
                  borderRadius:const BorderRadius.all( Radius.circular(9)),
                  border:   Border.all(color: Colors.black.withAlpha((0.1 * 255).toInt()), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                        cont.selectedGroupsNamesForShow[widget.index].isNotEmpty? cont.selectedGroupsNamesForShow[widget.index][0]:'',
                    ),
                  ],
                ),
              )
              // DialogDropMenu(
              //   controller: textEditingController,
              //   optionsList: cont.groupBranches[widget.index]??[],
              //   text: widget.data['name'],
              //   hint: '',
              //   rowWidth: MediaQuery.of(context).size.width * 0.5,
              //   textFieldWidth: MediaQuery.of(context).size.width * 0.35,
              //   onSelected:  (String? val) {
              //     var index = cont.groupBranches[widget.index].indexOf(val!);
              //     cont.addIdToSelectedGroupsIdsList(cont.groupsIds[widget.index][index]);
              //   },
              // ),
            ],
          ),
        );
      }
    );
  }
}




// class MobileGroupingTabContent extends StatefulWidget {
//   const MobileGroupingTabContent({super.key});
//
//   @override
//   State<MobileGroupingTabContent> createState() => _MobileGroupingTabContentState();
// }
//
// class _MobileGroupingTabContentState extends State<MobileGroupingTabContent> {
//   List addedGroupsList=[];
//   List<String> groupsNamesList=['chair'];
//   int counter = 0;
//   String? selectedItem = 'chair';
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       // height: MediaQuery.of(context).size.height * 0.55,
//       // width: MediaQuery.of(context).size.width * 0.55,
//       child: GetBuilder<ProductController>(
//           builder: (cont) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ReusableAddCard(
//                   text: 'create_code'.tr,
//                   onTap: () {
//                     setState(() {
//                       counter++;
//                       addedGroupsList.add(counter);
//                     });
//                   },
//                 ),
//                 gapH24,
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height * 0.38,
//                   child: GridView.count(
//                     crossAxisCount: 1,
//                     childAspectRatio: Sizes.deviceWidth / 100,
//                     children: List.generate(addedGroupsList.length, (index) {
//                       return addedGroupRow(index);
//                     }),
//                   ),
//                 ),
//                 // const Spacer(),
//                 // ReusableBTNsRow(
//                 //   onBackClicked: (){
//                 //     cont.setSelectedTabIndex(1);
//                 //   },
//                 //   onDiscardClicked: (){
//                 //     categoryController.clear();
//                 //     cont.selectedGroupsIds=[];
//                 //     for(int i=0;i<cont.groupsList.length;i++){
//                 //       cont.addSelectedGroupsIdsForShow([],i);
//                 //       cont.addSelectedGroupsNamesForShow([],i);
//                 //       cont.textEditingControllerForGroups[i].clear();
//                 //     }
//                 //   },
//                 //   onNextClicked: (){
//                 //     cont.setSelectedTabIndex(3);
//                 //   },
//                 //   onSaveClicked: (){},
//                 // )
//               ],
//             );
//         }
//       ),
//     );
//   }
//   addedGroupRow(int index){
//     return Container(
//       padding:const EdgeInsets.all(10),
//       // width:  MediaQuery.of(context).size.width * 0.5,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           Text('${'grouping'.tr} ${NumberToWordsEnglish.convert(index+1)}*'),
//           Row(
//             children: [
//               DropdownMenu<String>(
//                 width: MediaQuery.of(context).size.width * 0.4,
//                 requestFocusOnTap: false,
//                 inputDecorationTheme: InputDecorationTheme(
//                   // filled: true,
//                   contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
//                   // outlineBorder: BorderSide(color: Colors.black,),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
//                     borderRadius:
//                     const BorderRadius.all(Radius.circular(9)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(
//                         color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
//                     borderRadius:
//                     const BorderRadius.all(Radius.circular(9)),
//                   ),
//                 ),
//                 // menuStyle: ,
//                 dropdownMenuEntries: groupsNamesList
//                     .map<DropdownMenuEntry<String>>((String option) {
//                   return DropdownMenuEntry<String>(
//                     value: option,
//                     label: option,
//                   );
//                 }).toList(),
//                 onSelected: (String? val) {
//                   setState(() {
//                     selectedItem = val!;
//                   });
//                 },
//               ),
//               SizedBox(
//                 width: MediaQuery.of(context).size.width * 0.03,
//                 child: InkWell(
//                   onTap: () {
//                    setState(() {
//                      addedGroupsList.removeAt(index);
//                    });
//                   },
//                   child: Icon(
//                     Icons.delete_outline,
//                     color: Primary.primary,
//                   ),
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }
//
// }

