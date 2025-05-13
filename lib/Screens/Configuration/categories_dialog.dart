import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../const/Sizes.dart';
import '../../../const/colors.dart';
import '../../Backend/CategoriesBackend/delete_category.dart';
import '../../Backend/CategoriesBackend/edit_category.dart';
import '../../Backend/CategoriesBackend/get_categories.dart';
import '../../Backend/CategoriesBackend/store_category.dart';
import '../../Controllers/categories_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/products_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../Widgets/table_item.dart';
import '../../Widgets/table_title.dart';
// ignore: depend_on_referenced_packages


TextEditingController searchCategoryController = TextEditingController();
TextEditingController oldCatNameController = TextEditingController();

class CategoriesDialogContent extends StatefulWidget {
  const CategoriesDialogContent({super.key});

  @override
  State<CategoriesDialogContent> createState() =>
      _CategoriesDialogContentState();
}

class _CategoriesDialogContentState
    extends State<CategoriesDialogContent> {
  // int selectedTabIndex = 0;
  // ExchangeRatesController exchangeRatesController=Get.find();
  CategoriesController categoriesController=Get.find();
  HomeController homeController=Get.find();
  List tabsList = [
    'categories',
    'create_category'
  ];

  List tabsContent = [
    const CategoriesTab(),
    const CreateCategoryTab(),
  ];
  @override
  void initState() {
    // exchangeRatesController.getExchangeRatesListAndCurrenciesFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoriesController>(
      builder: (cont) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.9,
          margin:   EdgeInsets.symmetric(horizontal:homeController.isMobile.value ?10: 50, vertical: 15),
          // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DialogTitle(text: 'categories'.tr),
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
              tabsContent[cont.selectedTabIndex],
            ],
          ),
        );
      }
    );
  }
  Widget _buildTabChipItem(String name, int index) {
    return GetBuilder<CategoriesController>(
      builder: (cont) {
        return GestureDetector(
          onTap: () {
            cont.setSelectedTabIndex(index);
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
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              decoration: BoxDecoration(
                  color: cont.selectedTabIndex == index ? Primary.p20 : Colors.white,
                  border: cont.selectedTabIndex == index
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
    );
  }



}




class CategoriesTab extends StatefulWidget {
  const CategoriesTab({super.key});

  @override
  State<CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<CategoriesTab> {
  CategoriesController categoriesController = Get.find();
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
    categoriesController.getCategoriesFromBack();
  }
  final HomeController homeController = Get.find();
  @override
  void initState() {
    searchCategoryController.clear();
    categoriesController.getCategoriesFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoriesController>(
        builder: (cont) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                gapH16,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.5: MediaQuery.of(context).size.width * 0.8,
                      child: ReusableSearchTextField(
                        hint: '${"search".tr}...',
                        textEditingController: searchCategoryController,
                        onChangedFunc: (val) {
                          _onChangeHandler(val);
                        },
                        validationFunc: (val) {},
                      ),
                    ),
                  ],
                ),
                gapH32,
                cont.isCategoriesFetched
                    ?
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                          MediaQuery.of(context).size.width * 0.01,
                          vertical: 15),
                      decoration: BoxDecoration(
                          color: Primary.primary,
                          borderRadius:
                          const BorderRadius.all(Radius.circular(6))),
                      child: Row(
                        children: [
                          TableTitle(
                            text: 'category_name'.tr,
                            width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                          ),
                          TableTitle(
                            text: 'sub_categories'.tr,
                            width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: ListView.builder(
                        itemCount: cont.categoriesList.length,
                        itemBuilder: (context, index) =>
                            _categoryAsRowInTable(
                                cont.categoriesList[index],
                                index,
                                cont.categoriesList[index]['children']
                            ),
                      ),
                    ),
                  ],
                )
                    : const Center(child: CircularProgressIndicator()),
              ],
            ),
          );
        }
    );
  }
  _categoryAsRowInTable(Map category, int index,List categoriesNameList) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.01, vertical: 10),
      decoration: BoxDecoration(
          color: (index % 2 == 0) ? Primary.p10 : Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(0))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TableItem(
                text: '${category['category_name'] ?? ''}',
                width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
              ),
              SizedBox(
                width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width * 0.15,
                child:   DropdownMenu(
                  width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.28: MediaQuery.of(context).size.width *
                      0.15,
                  // requestFocusOnTap: false,
                  enableSearch: false,
                  // controller: selectedRootController,
                  // hintText: '${'search'.tr}...',
                  menuHeight: 250,
                  dropdownMenuEntries: categoriesNameList
                      .map<DropdownMenuEntry>(
                          ( option) {
                        return DropdownMenuEntry(
                          enabled: false,
                          value: option['category_name'],
                          label: option['category_name'],
                        );
                      }).toList(),
                  // enableFilter: true,
                  // onSelected: (String? val) {
                  //   setState(() {
                  //     selectedItem = val!;
                  //     var index =
                  //     categoriesNameList.indexOf(val);
                  //     selectedCategoryId =
                  //     categoriesIdsList[index];
                  //   });
                  // },
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    categoriesController.setSelectedCategory(category);
                    showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => const AlertDialog(
                          backgroundColor: Colors.white,
                          contentPadding: EdgeInsets.all(0),
                          titlePadding: EdgeInsets.all(0),
                          actionsPadding: EdgeInsets.all(0),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(9)),
                          ),
                          elevation: 0,
                          content: EditCategoryDialogContent(isMobile: false,),
                        ));
                  },
                  child: Icon(
                    Icons.mode_edit_outlined,
                    color: Primary.primary,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.05,
                child: InkWell(
                  onTap: () async {
                    var res = await deleteCategory(
                        '${category['id']}');
                    if ('${res['success']}' == 'true') {
                      categoriesController.getCategoriesFromBack();
                      CommonWidgets.snackBar('Success',
                          res['message']);
                    } else {
                      CommonWidgets.snackBar(
                          'error',   res['message']);
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
        ],
      ),
    );
  }
}




TextEditingController catNameController = TextEditingController();
TextEditingController selectedRootController = TextEditingController();
class CreateCategoryTab extends StatefulWidget {
  const CreateCategoryTab({super.key});

  @override
  State<CreateCategoryTab> createState() =>
      _CreateCategoryTabState();
}

class _CreateCategoryTabState
    extends State<CreateCategoryTab> {
  int selectedTabIndex = 0;
  final HomeController homeController = Get.find();
  final CategoriesController categoriesController = Get.find();
  final ProductController productController = Get.find();
  bool isYesClicked=false;
  List<String> categoriesNameList = [];
  List categoriesIdsList = [];
  String selectedCategoryId = '';
  String? selectedItem = '';
  bool isCategoriesFetched=false;
  getCategoriesFromBack() async {
    setState(() {
      categoriesNameList = [];
      categoriesIdsList = [];
      isCategoriesFetched=false;
      selectedItem = '';
      selectedCategoryId = '';
    });
    var p = await getCategories('');
    setState(() {
      for (var cat in p) {
        categoriesNameList.add('${cat['category_name']}');
        categoriesIdsList.add('${cat['id']}');
      }
      isCategoriesFetched = true;
    });
  }
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    catNameController.clear();
    selectedRootController.clear();
    getCategoriesFromBack();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.65,
      // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
      // padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH32,
          Form(
            key: _formKey,
            child: DialogTextField(
              textEditingController: catNameController,
              text: '${'category_name'.tr}*',
              rowWidth: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.6: MediaQuery.of(context).size.width * 0.4,
              textFieldWidth:  MediaQuery.of(context).size.width * 0.25,
              validationFunc: (String value){
                if(value.isEmpty){
                  return 'required_field'.tr;
                }return null;
              },
            ),
          ),
          gapH40,
          Wrap(
            children: [
              Text('is_it_sub'.tr),
              gapW20,
              InkWell(
                  onTap: (){
                    setState(() {
                      isYesClicked=true;
                    });
                  },
                  child:Container(
                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                    color: isYesClicked?Colors.green:Colors.grey,
                    child: Text('yes'.tr),
                  )
              ) ,
              gapW12,
              InkWell(
                  onTap: (){
                    setState(() {
                      isYesClicked=false;
                    });
                  },
                  child:Container(
                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                    color: !isYesClicked?Colors.green:Colors.grey,
                    child: Text('no'.tr),
                  )
              )
            ],
          ),
          gapH32,
          isYesClicked?
          isCategoriesFetched?SizedBox(
            width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.7:  MediaQuery.of(context).size.width * 0.4,
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text('${'main_category_name'.tr}*'),
                DropdownMenu<String>(
                  width: homeController.isMobile.value? MediaQuery.of(context).size.width * 0.3: MediaQuery.of(context).size.width *
                      0.25,
                  // requestFocusOnTap: false,
                  enableSearch: true,
                  controller: selectedRootController,
                  // hintText: '${'search'.tr}...',
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
                      borderRadius: const BorderRadius.all(
                          Radius.circular(9)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Primary.primary
                              .withAlpha((0.4 * 255).toInt()),
                          width: 2),
                      borderRadius: const BorderRadius.all(
                          Radius.circular(9)),
                    ),
                  ),
                  // menuStyle: ,
                  menuHeight: 250,
                  dropdownMenuEntries: categoriesNameList
                      .map<DropdownMenuEntry<String>>(
                          (String option) {
                        return DropdownMenuEntry<String>(
                          value: option,
                          label: option,
                        );
                      }).toList(),
                  enableFilter: true,
                  onSelected: (String? val) {
                    setState(() {
                      selectedItem = val!;
                      var index =
                      categoriesNameList.indexOf(val);
                      selectedCategoryId =
                      categoriesIdsList[index];
                    });
                  },
                ),
              ],
            ),
          ):const CircularProgressIndicator()

              :const SizedBox(),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: (){
                    setState(() {
                      catNameController.clear();
                      selectedRootController.clear();
                    });
                  },
                  child: Text('discard'.tr,style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Primary.primary
                  ),)),
              gapW24,
              ReusableButtonWithColor(btnText: 'save'.tr, onTapFunction: ()async{
                if(_formKey.currentState!.validate()) {
                  var res = await storeCategory(
                      catNameController.text, selectedCategoryId);
                  if (res['success'] == true) {
                    // Get.back();
                    // homeController.selectedTab.value =
                    // 'categories';
                    categoriesController.setSelectedTabIndex(0);
                    categoriesController.getCategoriesFromBack();
                    CommonWidgets.snackBar('Success',
                        res['message'] );
                    catNameController.clear();
                  } else {
                    CommonWidgets.snackBar('error',
                        res['message']);
                  }
                }
              }, width: 100, height: 35),
            ],
          )
        ],
      ),
    );
  }


}




class EditCategoryDialogContent extends StatefulWidget {
  const EditCategoryDialogContent({super.key, required this.isMobile});
  final bool isMobile;
  @override
  State<EditCategoryDialogContent> createState() =>
      _EditCategoryDialogContentState();
}

class _EditCategoryDialogContentState extends State<EditCategoryDialogContent> {
  final HomeController homeController = Get.find();
  final CategoriesController categoriesController = Get.find();

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoriesController>(
        builder: (cont) {
          return Container(
            color: Colors.white,
            height: 250,
            // width: MediaQuery.of(context).size.width * 0.8,
            // height: MediaQuery.of(context).size.height * 0.9,
            // margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 30),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DialogTitle(text: 'edit_category'.tr),
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
                gapH32,
                Form(
                  key: _formKey,
                  child: DialogTextField(
                    textEditingController: oldCatNameController,
                    text: '${'category_name'.tr}*',
                    // rowWidth: MediaQuery.of(context).size.width * 0.4,
                    // textFieldWidth: MediaQuery.of(context).size.width * 0.25,
                    textFieldWidth:widget.isMobile? MediaQuery.of(context).size.width * 0.2 : MediaQuery.of(context).size.width * 0.15,
                    rowWidth:widget.isMobile?  MediaQuery.of(context).size.width * 0.5 : MediaQuery.of(context).size.width * 0.25,
                    validationFunc: (String value) {
                      if (value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                ),
                // gapH20,
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.4,
                //   child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //     Text('check_children'.tr),
                //     SizedBox(
                //       width: MediaQuery.of(context).size.width * 0.25,
                //       child: DropDownMultiSelect(
                //         onChanged: (List<String> val) {
                //           setState(() {
                //             cont.setSelectedSubCategories(val);
                //           });
                //         },
                //         options: categoriesController.categoriesNameList,
                //         selectedValues: cont.selectedSubCategories,
                //         decoration:   InputDecoration(
                //           contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 5),
                //           // outlineBorder: BorderSide(color: Colors.black,),
                //           enabledBorder: OutlineInputBorder(
                //             borderSide:
                //             BorderSide(color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                //             borderRadius: const BorderRadius.all(Radius.circular(9)),
                //           ),
                //           focusedBorder: OutlineInputBorder(
                //             borderSide:
                //             BorderSide(color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                //             borderRadius: const BorderRadius.all(Radius.circular(9)),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ]),
                // ),
                const Spacer(),
                ReusableButtonWithColor(
                    btnText: 'apply'.tr,
                    radius: 9,
                    onTapFunction: () async {
                      if(_formKey.currentState!.validate()) {
                        var res = await editCategory(oldCatNameController.text, '${categoriesController.selectedCategory['id']}');
                        Get.back();
                        if ('${res['success']}' == 'true') {
                          categoriesController.getCategoriesFromBack();
                          CommonWidgets.snackBar(
                              'Success', res['message']);
                        } else {
                          CommonWidgets.snackBar('error', res['message']);
                        }
                      }
                    },
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: 50)
              ],
            ),
          );
        }
    );
  }


}