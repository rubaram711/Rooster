import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/home_controller.dart';
import '../../Backend/get_cities_of_a_specified_country.dart';
import '../../Backend/get_countries.dart';
import '../../Widgets/reusable_radio_btns.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';

class Suppliers extends StatefulWidget {
  const Suppliers({super.key});

  @override
  State<Suppliers> createState() => _SuppliersState();
}

class _SuppliersState extends State<Suppliers> {
  // late TabController _tabController;

  TextEditingController supplierNameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
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
  // final HomeController homeController = Get.find();

  String paymentTerm = '',
      priceListSelected = '',
      selectedCountry = '',
      selectedCity = '';
  String selectedPhoneCode = '', selectedMobileCode = '';


  int selectedTabIndex = 0;
  List tabsList = ['Settings', 'Accounting'];

  Map data = {};
  bool isClientsInfoFetched = false;

  // getFieldsForCreateClientsFromBack() async {
  //   var p = await getFieldsForCreateClient();
  //   if ('$p' != '[]') {
  //     setState(() {
  //       data.addAll(p);
  //       isClientsInfoFetched = true;
  //     });
  //   }
  // }

  int selectedSupplierType = 1;

  List<String> titles = ['Doctor', 'Miss', 'Mister', 'Maitre', 'Professor'];
  String selectedTitle = '';
  bool isActiveInPosChecked = false;
  bool isBlockedChecked = false;
  final _formKey = GlobalKey<FormState>();
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";
  List<String> acc = [];
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

  // This widget is the root of your application.

  @override
  void initState() {
    // getFieldsForCreateClientsFromBack();
    getCountriesFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.02,
      ),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: GetBuilder<HomeController>(
            builder: (homeCont) {
              double bigRowWidth =
                  homeCont.isMenuOpened
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.width * 0.7;
              double bigTextFieldWidth =
                  homeCont.isMenuOpened
                      ? MediaQuery.of(context).size.width * 0.4
                      : MediaQuery.of(context).size.width * 0.6;
              double smallRowWidth =
                  homeCont.isMenuOpened
                      ? MediaQuery.of(context).size.width * 0.22
                      : MediaQuery.of(context).size.width * 0.27;
              double smallTextFieldWidth =
                  homeCont.isMenuOpened
                      ? MediaQuery.of(context).size.width * 0.15
                      : MediaQuery.of(context).size.width * 0.19;
              double middleRowWidth =
                  homeCont.isMenuOpened
                      ? MediaQuery.of(context).size.width * 0.25
                      : MediaQuery.of(context).size.width * 0.29;
              double middleTextFieldWidth =
                  homeCont.isMenuOpened
                      ? MediaQuery.of(context).size.width * 0.2
                      : MediaQuery.of(context).size.width * 0.25;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create New Supplier",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Primary.primary,
                    ),
                  ),

                  gapH20,
                  ReusableRadioBtns(
                    isRow: true,
                    groupVal: selectedSupplierType,
                    title1: 'individual'.tr,
                    title2: 'company'.tr,
                    func: (value) {
                      setState(() {
                        selectedSupplierType = value!;
                      });
                    },
                    width1: MediaQuery.of(context).size.width * 0.15,
                    width2: MediaQuery.of(context).size.width * 0.15,
                  ),

                  gapH16,
                  const Text(
                    // '${data['supplierNumber'] ?? ''}',
                    "SP000001",
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  gapH16,

                  DialogTextField(
                    textEditingController: supplierNameController,
                    text: '${'Supplier Name*'}*',
                    rowWidth: bigRowWidth,
                    textFieldWidth: bigTextFieldWidth,

                    // rowWidth: MediaQuery.of(context).size.width * 0.5,
                    // textFieldWidth: MediaQuery.of(context).size.width * 0.4,
                    validationFunc: (value) {
                      if (value.isEmpty) {
                        return 'required field';
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
                        text: 'Reference',
                        rowWidth: smallRowWidth,
                        textFieldWidth: smallTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.22,
                        // textFieldWidth:
                        //     MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (val) {},
                      ),
                      PhoneTextField(
                        textEditingController: phoneController,
                        text: 'Phone',
                        rowWidth: middleRowWidth,
                        textFieldWidth: middleTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.25,
                        // textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (String val) {
                          if (val.isNotEmpty && val.length < 6) {
                            return '7_digits';
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
                        text: 'Floor, Bldg',
                        rowWidth: smallRowWidth,
                        textFieldWidth: smallTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.22,
                        // textFieldWidth:
                        //     MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (val) {},
                      ),
                    ],
                  ),

                  gapH10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: smallRowWidth,
                        // width: MediaQuery.of(context).size.width * 0.22,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Title'),
                            DropdownMenu<String>(
                              width: smallTextFieldWidth,
                              // width: MediaQuery.of(context).size.width * 0.15,
                              // requestFocusOnTap: false,
                              enableSearch: true,
                              controller: searchController,
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
                        text: 'Mobile',
                        rowWidth: middleRowWidth,
                        textFieldWidth: middleTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.25,
                        // textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (val) {
                          if (val.isNotEmpty && val.length < 9) {
                            return '7_digits';
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
                        text: 'Street',
                        rowWidth: smallRowWidth,
                        textFieldWidth: smallTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.22,
                        // textFieldWidth:
                        //     MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (val) {},
                        // onChangedFunc: (value){
                        //   setState(() {
                        //     mainDescriptionController.text=value;
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
                        text: 'Job Position',
                        hint: 'Sales Director,Sales...',
                        rowWidth: smallRowWidth,
                        textFieldWidth: smallTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.22,
                        // textFieldWidth:
                        //     MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (val) {},
                      ),
                      DialogTextField(
                        textEditingController: emailController,
                        text: 'Email',
                        hint: 'example@gmail.com',
                        rowWidth: middleRowWidth,
                        textFieldWidth: middleTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.25,
                        // textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (String value) {
                          if (value.isNotEmpty &&
                              !RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              ).hasMatch(value)) {
                            return 'check_format';
                          }
                        },
                      ),
                      // DialogTextField(
                      //   textEditingController: cityController,
                      //   text: 'city'.tr,
                      //   rowWidth: MediaQuery.of(context).size.width * 0.22,
                      //   textFieldWidth:
                      //       MediaQuery.of(context).size.width * 0.15,
                      //   validationFunc: (val) {},
                      // ),
                      isCountriesFetched
                          ? SizedBox(
                            width: smallRowWidth,
                            // width: MediaQuery.of(context).size.width * 0.22,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('country'),
                                DropdownMenu<String>(
                                  width: smallTextFieldWidth,
                                  // MediaQuery.of(context).size.width * 0.15,
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
                          // DialogDropMenu(
                          //   optionsList: countriesNamesList,
                          //   controller: countryController,
                          //   isDetectedHeight: true,
                          //   text: 'country'.tr,
                          //   hint: '',
                          //   rowWidth: MediaQuery.of(context).size.width * 0.22,
                          //   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                          //   onSelected: (val) {
                          //     setState(() {
                          //       selectedCountry = val;
                          //       getCitiesFromBack(val);
                          //     });
                          //   },
                          // )
                          : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            // child: loading()
                          ),
                    ],
                  ),
                  gapH10,

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DialogTextField(
                        textEditingController: taxNumberController,
                        text: 'tax number',
                        rowWidth: smallRowWidth,
                        textFieldWidth: smallTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.22,
                        // textFieldWidth:
                        //     MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (String val) {
                          if (selectedSupplierType == 2 && val.isEmpty) {
                            return 'required field';
                          }
                          return null;
                        },
                      ),
                      DialogTextField(
                        textEditingController: websiteController,
                        text: 'website',
                        hint: 'www.example.com',
                        rowWidth: middleRowWidth,
                        textFieldWidth: middleTextFieldWidth,
                        // rowWidth: MediaQuery.of(context).size.width * 0.25,
                        // textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (String value) {
                          // if(value.isNotEmpty && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          //     .hasMatch(value)) {
                          //   return 'check_format'.tr ;
                          // }return null;
                        },
                      ),

                      // CountryTextField(
                      //   onChangedFunc: (val){},
                      //   validationFunc:  (val){},
                      //   text: 'country'.tr,
                      //   rowWidth: MediaQuery.of(context).size.width*0.22,
                      //   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                      //   textEditingController: TextEditingController(),
                      //   onCodeSelected: (val) {
                      //     setState(() {
                      //       selectedCountry = val;
                      //     });
                      //   },),
                      isCitiesFetched
                          ? SizedBox(
                            width: smallRowWidth,
                            // width: MediaQuery.of(context).size.width * 0.22,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('city'.tr),
                                DropdownMenu<String>(
                                  width: smallTextFieldWidth,
                                  // MediaQuery.of(context).size.width * 0.15,
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
                          //     ? DialogDropMenu(
                          //   optionsList: citiesNamesList,
                          //   controller: cityController,
                          //   isDetectedHeight: true,
                          //   text: 'city'.tr,
                          //   hint:selectedCountry.isEmpty? 'select the country first':'',
                          //   rowWidth: MediaQuery.of(context).size.width*0.22,
                          //   textFieldWidth: MediaQuery.of(context).size.width * 0.15,
                          //   onSelected: (val) {
                          //     setState(() {
                          //       selectedCity = val;
                          //     });
                          //   },
                          // )
                          : SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            // child: loading()
                          ),
                    ],
                  ),
                  gapH40,

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
                    height: 300,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      children: [
                        selectedTabIndex == 0
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.29,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Granted Discount'),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.15,
                                        child: TextFormField(
                                          // textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                  20,
                                                  0,
                                                  25,
                                                  10,
                                                ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                      (0.2 * 255).toInt(),
                                                    ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(9),
                                                  ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                      (0.4 * 255).toInt(),
                                                    ),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(9),
                                                  ),
                                            ),
                                            errorStyle: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                            focusedErrorBorder:
                                                const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                        Radius.circular(9),
                                                      ),
                                                  borderSide: BorderSide(
                                                    width: 1,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                          ),
                                          controller: grantedDiscountController,
                                          keyboardType:
                                              const TextInputType.numberWithOptions(
                                                decimal: false,
                                                signed: true,
                                              ),
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.allow(
                                              RegExp('[0-9.]'),
                                            ),
                                            // WhitelistingTextInputFormatter.digitsOnly
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                gapH20,
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: const Text(
                                          "Show in POS",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        leading: Checkbox(
                                          activeColor: Primary.primary,
                                          value: isActiveInPosChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isActiveInPosChecked = value!;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                gapH10,
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: const Text(
                                          'blocked',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        leading: Checkbox(
                                          activeColor: Primary.primary,
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
                                ),
                                gapH10,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'discard',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Primary.primary,
                                        ),
                                      ),
                                    ),
                                    gapW24,
                                    TextButton(
                                      style: ButtonStyle(
                                        alignment: Alignment.center,
                                        backgroundColor: WidgetStatePropertyAll(
                                          Primary.primary,
                                        ),
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Primary.p0,
                                            ),
                                        overlayColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (states.contains(
                                                WidgetState.hovered,
                                              )) {
                                                return Primary.p0.withAlpha(
                                                  (0.04 * 255).toInt(),
                                                );
                                              }
                                              if (states.contains(
                                                    WidgetState.focused,
                                                  ) ||
                                                  states.contains(
                                                    WidgetState.pressed,
                                                  )) {
                                                return Primary.primary
                                                    .withAlpha(
                                                      (0.12 * 255).toInt(),
                                                    );
                                              }
                                              return null; // Defer to the widget's default.
                                            }),
                                      ),
                                      onPressed: () {},
                                      child: const Text('    Save    '),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            : selectedTabIndex == 1
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.29,
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [Text('Account #')],
                                  ),
                                ),
                                gapH20,
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.29,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // const Text(
                                      //   'Account #',
                                      // ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.15,
                                        child: DropdownMenu<String>(
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
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
                                            contentPadding:
                                                const EdgeInsets.fromLTRB(
                                                  20,
                                                  0,
                                                  25,
                                                  5,
                                                ),
                                            // outlineBorder: BorderSide(color: Colors.black,),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                      (0.2 * 255).toInt(),
                                                    ),
                                                width: 1,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(9),
                                                  ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: Primary.primary
                                                    .withAlpha(
                                                      (0.4 * 255).toInt(),
                                                    ),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                    Radius.circular(9),
                                                  ),
                                            ),
                                          ),
                                          // menuStyle: ,
                                          menuHeight: 250,
                                          dropdownMenuEntries:
                                              acc.map<
                                                DropdownMenuEntry<String>
                                              >((String option) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              }).toList(),
                                          enableFilter: true,
                                          onSelected: (String? val) {
                                            setState(() {
                                              // selectedCountry = val!;
                                              // getCitiesFromBack(val);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                gapH100,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {},
                                      child: Text(
                                        'discard',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Primary.primary,
                                        ),
                                      ),
                                    ),
                                    gapW24,
                                    TextButton(
                                      style: ButtonStyle(
                                        alignment: Alignment.center,
                                        backgroundColor: WidgetStatePropertyAll(
                                          Primary.primary,
                                        ),
                                        foregroundColor:
                                            WidgetStateProperty.all<Color>(
                                              Primary.p0,
                                            ),
                                        overlayColor:
                                            WidgetStateProperty.resolveWith<
                                              Color?
                                            >((Set<WidgetState> states) {
                                              if (states.contains(
                                                WidgetState.hovered,
                                              )) {
                                                return Primary.p0.withAlpha(
                                                  (0.04 * 255).toInt(),
                                                );
                                              }
                                              if (states.contains(
                                                    WidgetState.focused,
                                                  ) ||
                                                  states.contains(
                                                    WidgetState.pressed,
                                                  )) {
                                                return Primary.primary
                                                    .withAlpha(
                                                      (0.12 * 255).toInt(),
                                                    );
                                              }
                                              return null; // Defer to the widget's default.
                                            }),
                                      ),
                                      onPressed: () {},
                                      child: const Text('    Save    '),
                                    ),
                                  ],
                                ),
                              ],
                            )
                            : const Text(".,"),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
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
              name,
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

//
// Widget _buildDropdownItem(Country country) => SizedBox(
// // width:widget.textFieldWidth*0.3,
//   child: Row(children: [
//     SizedBox(
// // width: widget.textFieldWidth * 0.2 ,
//         child: CountryPickerUtils.getDefaultFlagImage(country)),
//     SizedBox(
// // width widget.textFieldWidth * 0.2 ,
//       child: Text(
//         "+${country.phoneCode}",
//         style: const TextStyle(fontSize: 13),
//       ),
//     ),
//   ]),
// );
//
//

class CountryTextField extends StatefulWidget {
  const CountryTextField({
    super.key,
    required this.onChangedFunc,
    required this.validationFunc,
    required this.text,
    required this.rowWidth,
    required this.textFieldWidth,
    required this.textEditingController,
    this.hint = '',
    required this.onCodeSelected,
  });
  final Function onChangedFunc;
  final Function validationFunc;
  final Function onCodeSelected;
  final String text;
  final String hint;
  final double rowWidth;
  final double textFieldWidth;
  final TextEditingController textEditingController;

  @override
  State<CountryTextField> createState() => _CountryTextFieldState();
}

class _CountryTextFieldState extends State<CountryTextField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.rowWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.text),
          SizedBox(
            width: widget.textFieldWidth,
            child: TextFormField(
              cursorColor: Colors.black,
              controller: widget.textEditingController,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                contentPadding: const EdgeInsets.fromLTRB(10, 0, 25, 5),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    width: 1,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                    width: 2,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(9)),
                ),
                errorStyle: const TextStyle(fontSize: 10.0),
                focusedErrorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(9)),
                  borderSide: BorderSide(width: 1, color: Colors.red),
                ),
              ),
              // onTap: (){
              //   showCountryPicker(
              //     context: context,
              //     // showPhoneCode: true, // optional. Shows phone code before the country name.
              //     onSelect: ( country) {
              //     },
              //   );
              //   // widget.onChangedFunc(value);
              // },
              onChanged: (value) => widget.onChangedFunc(value),
            ),
          ),
        ],
      ),
    );
  }
}
