import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ClientsBackend/get_client_create_info.dart';
import 'package:rooster_app/Backend/get_cities_of_a_specified_country.dart';
import 'package:rooster_app/Backend/get_countries.dart';
import 'package:rooster_app/Controllers/client_controller.dart';
import 'package:rooster_app/Widgets/loading.dart';
import 'package:rooster_app/Widgets/reusable_add_card.dart';
import 'package:rooster_app/const/cars_constants.dart';
import '../../Backend/ClientsBackend/store_client.dart';
import '../../Controllers/garage_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_drop_down_menu.dart';
import '../../Widgets/reusable_radio_btns.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../../const/functions.dart';
import '../garage/add_attribute.dart';

List<String> titles = ['Doctor', 'Miss', 'Mister', 'Maitre', 'Professor'];

class AddNewClient extends StatefulWidget {
  const AddNewClient({super.key});

  @override
  State<AddNewClient> createState() => _AddNewClientState();
}

class _AddNewClientState extends State<AddNewClient> {
  TextEditingController searchController = TextEditingController();
  TextEditingController priceListController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController clientNumberController = TextEditingController();
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
  List tabsList = [
    // 'internal_note',
    'settings',
    'contacts_and_addresses',
    'sales',
    'accounting',
    // 'cars',
  ];
  setTabsList() async {
    var isItGarage = await getIsItGarageFromPref();
    if (isItGarage == '1') {
      tabsList.add('cars');
    }
  }

  Map data = {};
  List<String> pricesListsNames = [];
  List<String> pricesListsCodes = [];
  List<String> pricesListsIds = [];
  bool isClientsInfoFetched = false;
  String copyOfClientNumber = '';
  getFieldsForCreateClientsFromBack() async {
    var p = await getFieldsForCreateClient();
    if ('$p' != '[]') {
      setState(() {
        data.addAll(p);
        isClientsInfoFetched = true;
        clientNumberController.text = data['clientNumber'];
        copyOfClientNumber = data['clientNumber'];
      });
      for (var priceList in p['pricelists']) {
        if (priceList['code'] == 'STANDARD') {
          selectedPriceListId = '${priceList['id']}';
          priceListController.text = priceList['code'];
        }
        pricesListsNames.add(priceList['title']);
        pricesListsIds.add('${priceList['id']}');
        pricesListsCodes.add('${priceList['code']}');
      }
    }
  }

  String selectedTitle = '';
  bool isActiveInPosChecked = false;
  bool isBlockedChecked = false;
  final _formKey = GlobalKey<FormState>();
  String countryValue = "";
  String stateValue = "";
  String cityValue = "";
  String address = "";

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

  ClientController clientController = Get.find();

  @override
  void initState() {
    setTabsList();
    clientController.contactsList = [];
    clientController.salesPersonController.clear();
    clientController.getAllUsersSalesPersonFromBack();
    getFieldsForCreateClientsFromBack();
    getCountriesFromBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return isClientsInfoFetched
        ? Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.02,
          ),
          height: MediaQuery.of(context).size.height * 0.85,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(text: 'create_new_client'.tr),
                  // gapH32,
                  // const AddPhotoCircle(),
                  gapH32,
                  ReusableRadioBtns(
                    isRow: true,
                    groupVal: selectedClientType,
                    title1: 'individual'.tr,
                    title2: 'company'.tr,
                    func: (value) {
                      setState(() {
                        selectedClientType = value!;
                      });
                    },
                    width1: MediaQuery.of(context).size.width * 0.15,
                    width2: MediaQuery.of(context).size.width * 0.15,
                  ),
                  gapH16,
                  // Text(
                  //   '${data['clientNumber'] ?? ''}',
                  //   style: const TextStyle(
                  //       fontSize: 36, fontWeight: FontWeight.bold),
                  // ),
                  GetBuilder<HomeController>(
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
                          DialogTextField(
                            textEditingController: clientNumberController,
                            text: '${'client_code'.tr}*',
                            rowWidth: bigRowWidth,
                            textFieldWidth: bigTextFieldWidth,
                            validationFunc: (value) {
                              if (value.isEmpty) {
                                return 'required_field'.tr;
                              }
                              return null;
                            },
                          ),
                          gapH16,
                          DialogTextField(
                            textEditingController: clientNameController,
                            text: '${'client_name'.tr}*',
                            rowWidth: bigRowWidth,
                            textFieldWidth: bigTextFieldWidth,
                            // MediaQuery.of(context).size.width * 0.4,
                            validationFunc: (value) {
                              if (value.isEmpty) {
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
                                rowWidth: smallRowWidth,
                                textFieldWidth: smallTextFieldWidth,
                                validationFunc: (val) {},
                              ),
                              PhoneTextField(
                                textEditingController: phoneController,
                                text: 'phone'.tr,
                                rowWidth: middleRowWidth,
                                textFieldWidth: middleTextFieldWidth,
                                validationFunc: (String val) {
                                  if (val.isNotEmpty && val.length < 6) {
                                    return '6_digits'.tr;
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
                                rowWidth: smallRowWidth,
                                textFieldWidth: smallTextFieldWidth,
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('title'.tr),
                                    DropdownMenu<String>(
                                      width: smallTextFieldWidth,
                                      // requestFocusOnTap: false,
                                      enableSearch: true,
                                      controller: titleController,
                                      hintText: 'Doctor, Miss, Mister',
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
                                          titles.map<DropdownMenuEntry<String>>(
                                            (String option) {
                                              return DropdownMenuEntry<String>(
                                                value: option,
                                                label: option,
                                              );
                                            },
                                          ).toList(),
                                      enableFilter: false,
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
                                rowWidth: middleRowWidth,
                                textFieldWidth: middleTextFieldWidth,
                                validationFunc: (val) {
                                  if (val.isNotEmpty && val.length < 6) {
                                    return '6_digits'.tr;
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
                                rowWidth: smallRowWidth,
                                textFieldWidth: smallTextFieldWidth,
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
                                rowWidth: smallRowWidth,
                                textFieldWidth: smallTextFieldWidth,
                                validationFunc: (val) {},
                              ),
                              DialogTextField(
                                textEditingController: emailController,
                                text: 'email'.tr,
                                hint: 'example@gmail.com',
                                rowWidth: middleRowWidth,
                                textFieldWidth: middleTextFieldWidth,
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
                                    width: smallRowWidth,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('country'.tr),
                                        DropdownMenu<String>(
                                          width: smallTextFieldWidth,
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
                                              countriesNamesList.map<
                                                DropdownMenuEntry<String>
                                              >((String option) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              }).toList(),
                                          enableFilter: false,
                                          onSelected: (String? val) {
                                            setState(() {
                                              countryController.text=val!;
                                              selectedCountry = val;
                                              getCitiesFromBack(val);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox(
                                    width: smallRowWidth,
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
                                rowWidth: smallRowWidth,
                                textFieldWidth: smallTextFieldWidth,
                                validationFunc: (String val) {
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
                                rowWidth: middleRowWidth,
                                textFieldWidth: middleTextFieldWidth,
                                validationFunc: (String value) {
                                  // if(value.isNotEmpty && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  //     .hasMatch(value)) {
                                  //   return 'check_format'.tr ;
                                  // }return null;
                                },
                              ),

                              isCitiesFetched
                                  ? SizedBox(
                                    width: smallRowWidth,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('city'.tr),
                                        DropdownMenu<String>(
                                          width: smallTextFieldWidth,
                                          // requestFocusOnTap: false,
                                          enableSearch: true,
                                          controller: cityController,
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
                                              citiesNamesList.map<
                                                DropdownMenuEntry<String>
                                              >((String option) {
                                                return DropdownMenuEntry<
                                                  String
                                                >(value: option, label: option);
                                              }).toList(),
                                          enableFilter: false,
                                          onSelected: (String? val) {
                                            setState(() {
                                              cityController.text=val!;
                                              selectedCity = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                  : SizedBox(
                                    width: smallRowWidth,
                                    child: loading(),
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
                                            // element['id'],
                                            // element['name'],
                                            tabsList.indexOf(element),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
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
                        selectedTabIndex == 0
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ReusableInputNumberField(
                                  controller: grantedDiscountController,
                                  textFieldWidth:
                                      MediaQuery.of(context).size.width * 0.15,
                                  rowWidth:
                                      MediaQuery.of(context).size.width * 0.25,
                                  onChangedFunc: (val) {},
                                  validationFunc: (value) {},
                                  text: 'granted_discount'.tr,
                                ),
                                gapH20,
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                          'show_in_POS'.tr,
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
                                  ],
                                ),
                                gapH20,
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                          'blocked'.tr,
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
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        textFieldWidth:
                                            MediaQuery.of(context).size.width *
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
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        textFieldWidth:
                                            MediaQuery.of(context).size.width *
                                            0.17,
                                        onSelected: (val) {
                                          var index = pricesListsCodes.indexOf(
                                            val,
                                          );
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
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  priceListController.clear();
                                  selectedClientType = 1;
                                  selectedPhoneCode = '';
                                  selectedMobileCode = '';
                                  paymentTerm = '';
                                  selectedPriceListId = '';
                                  selectedCountry = '';
                                  grantedDiscountController.clear();
                                  clientNameController.clear();
                                  referenceController.clear();
                                  internalNoteController.clear();
                                  websiteController.clear();
                                  phoneController.clear();
                                  floorBldgController.clear();
                                  titleController.clear();
                                  mobileController.clear();
                                  taxNumberController.clear();
                                  cityController.clear();
                                  countryController.clear();
                                  selectedCountry = '';
                                  selectedCity = '';
                                  emailController.clear();
                                  jobPositionController.clear();
                                  streetController.clear();
                                  isBlockedChecked = false;
                                  isActiveInPosChecked = false;
                                  grantedDiscountController.clear();
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
                                  var res = await storeClient(
                                    referenceController.text,
                                    isActiveInPosChecked ? '1' : '0',
                                    grantedDiscountController.text.replaceAll(
                                      ',',
                                      '',
                                    ),
                                    isBlockedChecked ? '1' : '0',
                                    selectedClientType == 1
                                        ? 'individual'
                                        : 'company',
                                    clientNameController.text,
                                    clientNumberController.text ==
                                            copyOfClientNumber
                                        ? ''
                                        : clientNumberController.text,
                                    selectedCountry,
                                    selectedCity,
                                    '',
                                    '',
                                    streetController.text,
                                    floorBldgController.text,
                                    jobPositionController.text,
                                    selectedPhoneCode.isEmpty
                                        ? '+961'
                                        : selectedPhoneCode,
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
                                    clientController.selectedSalesPersonId
                                        .toString(),
                                    paymentTerm,
                                    selectedPriceListId,
                                    internalNoteController.text,
                                    '',
                                    clientController.contactsList,
                                    clientController.carsList,
                                  );
                                  if (res['success'] == true) {
                                    CommonWidgets.snackBar(
                                      'Success',
                                      res['message'],
                                    );
                                    homeController.selectedTab.value =
                                        'clients';
                                  } else {
                                    CommonWidgets.snackBar(
                                      'error',
                                      res['message'],
                                    );
                                  }
                                }
                              },
                              width: 100,
                              height: 35,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        : const CircularProgressIndicator();
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

class ContactsAndAddressesSection extends StatefulWidget {
  const ContactsAndAddressesSection({super.key});

  @override
  State<ContactsAndAddressesSection> createState() =>
      _ContactsAndAddressesSectionState();
}

class _ContactsAndAddressesSectionState
    extends State<ContactsAndAddressesSection> {
  ClientController clientController = Get.find();
  addNewContact() {
    Map contact = {
      'type': '1',
      'name': '',
      'title': '',
      'jobPosition': '',
      'deliveryAddress': '',
      'phoneCode': '+961',
      'phoneNumber': '',
      'extension': '',
      'mobileCode': '+961',
      'mobileNumber': '',
      'email': '',
      'note': '',
      'internalNote': '',
    };
    clientController.addToContactsList(contact);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return Column(
          children: [
            SizedBox(
              height: cont.contactsList.isEmpty ? 20 : 420,
              child: ListView.builder(
                itemCount: cont.contactsList.length,
                itemBuilder:
                    (context, index) => ReusableContactSection(index: index),
              ),
            ),
            gapH16,
            ReusableAddCard(
              text: 'add_new_contact'.tr,
              onTap: () {
                addNewContact();
              },
            ),
          ],
        );
      },
    );
  }
}

class ReusableContactSection extends StatefulWidget {
  const ReusableContactSection({super.key, required this.index});
  final int index;
  @override
  State<ReusableContactSection> createState() => _ReusableContactSectionState();
}

class _ReusableContactSectionState extends State<ReusableContactSection> {
  ClientController clientController = Get.find();
  String selectedContactsPhoneCode = '', selectedContactsMobileCode = '';
  int selectedContactAndAddressType = 1;
  String selectedContactsTitle = '';

  TextEditingController contactsNameController = TextEditingController();
  TextEditingController contactsPhoneController = TextEditingController();
  TextEditingController contactsTitleController = TextEditingController();
  TextEditingController contactsMobileController = TextEditingController();
  TextEditingController contactsJobPositionController = TextEditingController();
  TextEditingController contactsAddressController = TextEditingController();
  TextEditingController contactsEmailController = TextEditingController();
  TextEditingController contactsNoteController = TextEditingController();
  TextEditingController contactsExtController = TextEditingController();
  @override
  void initState() {
    // selectedContactAndAddressType=int.parse('${clientController.contactsList[widget.index]['type']??1}');
    selectedContactsPhoneCode =
        clientController.contactsList[widget.index]['phoneCode'] ?? '+961';
    selectedContactsMobileCode =
        clientController.contactsList[widget.index]['mobileCode'] ?? '+961';
    contactsNameController.text =
        clientController.contactsList[widget.index]['name'];
    contactsTitleController.text =
        clientController.contactsList[widget.index]['title'];
    selectedContactsTitle =
        clientController.contactsList[widget.index]['title'];
    contactsPhoneController.text =
        clientController.contactsList[widget.index]['phoneNumber'];
    contactsMobileController.text =
        clientController.contactsList[widget.index]['mobileNumber'];
    contactsJobPositionController.text =
        clientController.contactsList[widget.index]['jobPosition'];
    contactsAddressController.text =
        clientController.contactsList[widget.index]['deliveryAddress'];
    contactsEmailController.text =
        clientController.contactsList[widget.index]['email'];
    contactsNoteController.text =
        clientController.contactsList[widget.index]['internalNote'];
    contactsExtController.text =
        clientController.contactsList[widget.index]['extension'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return Container(
          margin: const EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Primary.primary.withAlpha((0.2 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row(
              //   children: [
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width * 0.15,
              //       child: ListTile(
              //         title: Text(
              //           'contact'.tr,
              //           style: const TextStyle(fontSize: 12),
              //         ),
              //         leading: Radio(
              //           value: 1,
              //           groupValue: selectedContactAndAddressType,
              //           onChanged: (value) {
              //             setState(() {
              //               selectedContactAndAddressType = value!;
              //             });
              //             cont.updateContactType(widget.index,'${value!}');
              //           },
              //         ),
              //       ),
              //     ),
              //     SizedBox(
              //       width: MediaQuery.of(context).size.width * 0.15,
              //       child: ListTile(
              //         title: Text(
              //           'delivery_address'.tr,
              //           style: const TextStyle(fontSize: 12),
              //         ),
              //         leading: Radio(
              //           value: 2,
              //           groupValue: selectedContactAndAddressType,
              //           onChanged: (value) {
              //             setState(() {
              //               selectedContactAndAddressType = value!;
              //             });
              //             cont.updateContactType(widget.index,'${value!}');
              //           },
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              // gapH10,
              Text(
                'Contact Selection used to add the contact information of personnel within the company (e.g., CEO, CFO, ...).',
              ),
              gapH28,
              GetBuilder<HomeController>(
                builder: (homeCont) {
                  double miniRowWidth =
                      homeCont.isMenuOpened
                          ? MediaQuery.of(context).size.width * 0.19
                          : MediaQuery.of(context).size.width * 0.25;
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController: contactsNameController,
                            text: 'name'.tr,
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateContactName(widget.index, val);
                            },
                          ),
                          PhoneTextField(
                            textEditingController: contactsPhoneController,
                            text: 'phone'.tr,
                            initialValue: selectedContactsPhoneCode,
                            rowWidth: middleRowWidth,
                            textFieldWidth: middleTextFieldWidth,
                            validationFunc: (String val) {
                              if (val.isNotEmpty && val.length < 6) {
                                return '6_digits'.tr;
                              }
                              return null;
                            },
                            onCodeSelected: (value) {
                              cont.updateContactPhoneCode(
                                widget.index,
                                '$value',
                              );
                              setState(() {
                                selectedContactsPhoneCode = value;
                              });
                            },
                            onChangedFunc: (value) {
                              cont.updateContactPhoneNumber(
                                widget.index,
                                '$value',
                              );
                            },
                          ),
                          DialogTextField(
                            textEditingController: contactsExtController,
                            text: 'ext'.tr,
                            rowWidth: miniRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateContactExtension(widget.index, val);
                            },
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: smallRowWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('title'.tr),
                                DropdownMenu<String>(
                                  width: smallTextFieldWidth,
                                  // requestFocusOnTap: false,
                                  enableSearch: true,
                                  controller: contactsTitleController,
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
                                  enableFilter: false,
                                  onSelected: (String? val) {
                                    setState(() {
                                      selectedContactsTitle = val!;
                                    });
                                    cont.updateContactTitle(widget.index, val!);
                                  },
                                ),
                              ],
                            ),
                          ),
                          PhoneTextField(
                            textEditingController: contactsMobileController,
                            text: 'mobile'.tr,
                            initialValue: selectedContactsMobileCode,
                            rowWidth: middleRowWidth,
                            textFieldWidth: middleTextFieldWidth,
                            validationFunc: (val) {
                              if (val.isNotEmpty && val.length < 6) {
                                return '6_digits'.tr;
                              }
                              return null;
                            },
                            onCodeSelected: (value) {
                              setState(() {
                                selectedContactsMobileCode = value;
                              });
                              cont.updateContactMobileCode(
                                widget.index,
                                '${value!}',
                              );
                            },
                            onChangedFunc: (value) {
                              cont.updateContactMobileNumber(
                                widget.index,
                                '${value!}',
                              );
                            },
                          ),
                          DialogTextField(
                            textEditingController: contactsAddressController,
                            text: 'address'.tr,
                            rowWidth: miniRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateContactDeliveryAddress(
                                widget.index,
                                val,
                              );
                            },
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController:
                                contactsJobPositionController,
                            text: 'job_position'.tr,
                            hint: 'Sales Director,Sales...',
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateContactJobPosition(widget.index, val);
                            },
                          ),
                          DialogTextField(
                            textEditingController: contactsEmailController,
                            text: 'email'.tr,
                            hint: 'example@gmail.com',
                            rowWidth: middleRowWidth,
                            textFieldWidth: middleTextFieldWidth,
                            validationFunc: (String value) {
                              if (value.isNotEmpty &&
                                  !RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                                  ).hasMatch(value)) {
                                return 'check_format'.tr;
                              }
                            },
                            onChangedFunc: (val) {
                              cont.updateContactEmail(widget.index, val);
                            },
                          ),
                          SizedBox(width: miniRowWidth),
                        ],
                      ),
                    ],
                  );
                },
              ),
              gapH48,
              TextField(
                controller: contactsNoteController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: 'note.....',
                  hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      width: 1,
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                    ),
                  ),
                ),
                onChanged: (val) {
                  cont.updateContactNote(widget.index, val);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CarsSection extends StatefulWidget {
  const CarsSection({super.key});
  @override
  State<CarsSection> createState() => _CarsSectionState();
}

class _CarsSectionState extends State<CarsSection> {
  ClientController clientController = Get.find();
  addNewCar() {
    Map car = {
      'odometer': '',
      'registration': '', //unique
      'year': '',
      'color': {},
      'model': {},
      'brand': {},
      'chassis_no': '', //number
      'rating': '',
      'comment': '',
      'car_fax': '',
      'technician': {},
    };
    clientController.addToCarsList(car);
  }

  @override
  void initState() {


    if (!clientController.isAttributesFetched) {
      clientController.getAllCarsAttributesFromBack();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return cont.isAttributesFetched
            ? Column(
              children: [
                SizedBox(
                  height: cont.carsList.isEmpty ? 20 : 360,
                  child: ListView.builder(
                    itemCount: cont.carsList.length,
                    itemBuilder:
                        (context, index) => ReusableCarSection(index: index),
                  ),
                ),
                gapH16,
                ReusableAddCard(
                  text: 'add_new_car'.tr,
                  onTap: () {
                    addNewCar();
                    // print('addCar');
                    // print(cont.carsList);
                  },
                ),
              ],
            )
            : Center(child: loading());
      },
    );
  }
}

class ReusableCarSection extends StatefulWidget {
  const ReusableCarSection({super.key, required this.index});
  final int index;
  @override
  State<ReusableCarSection> createState() => _ReusableCarSectionState();
}

class _ReusableCarSectionState extends State<ReusableCarSection> {
  ClientController clientController = Get.find();
  List<String> years = [];
  TextEditingController faxController = TextEditingController();
  TextEditingController odometerController = TextEditingController();
  TextEditingController colorController = TextEditingController();
  TextEditingController technicianController = TextEditingController();
  TextEditingController chassisNoController = TextEditingController();
  TextEditingController registrationController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController commentController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController ratingController = TextEditingController();

  GarageController garageController = Get.find();
  List<String> carsModelsNames=[];
  List<String> carsModelsIds=[];
  getModelsOnlyMatchWithSelectedBrand(String selectedBrandId){
    setState(() {
      carsModelsNames=[];
      carsModelsIds=[];
      clientController.isModelsFetched=false;
      carsModelsNames     = clientController.extractModelsNamesWithCondition(selectedBrandId);
      carsModelsIds       = clientController.extractModelsIdsWithCondition(selectedBrandId);
      clientController.isModelsFetched=true;
    });
  }

  getModelsOnlyMatchWithSelectedBrandWithoutUpdate(String selectedBrandId){
    carsModelsNames=[];
    carsModelsIds=[];
    clientController.isModelsFetched=false;
    carsModelsNames     = clientController.extractModelsNamesWithCondition(selectedBrandId);
    carsModelsIds       = clientController.extractModelsIdsWithCondition(selectedBrandId);
    clientController.isModelsFetched=true;
  }



  @override
  void initState() {
    years = generateYears();
    if (clientController.carsList[widget.index].containsKey('id')) {
      if (clientController.carsList[widget.index]['technician'].isNotEmpty) {
        int techIndex = clientController.carsTechnicianIds.indexOf(
          '${clientController.carsList[widget.index]['technician']['id']}',
        );
        technicianController.text =
            clientController.carsTechnicianNames[techIndex];
      }
      if (clientController.carsList[widget.index]['color'].isNotEmpty) {
        int colorIndex = clientController.carsColorsIds.indexOf(
          '${clientController.carsList[widget.index]['color']['id']}',
        );
        colorController.text = clientController.carsColorsNames[colorIndex];
      }
      if (clientController.carsList[widget.index]['brand'].isNotEmpty) {
        int brandIndex = clientController.carsBrandsIds.indexOf(
          '${clientController.carsList[widget.index]['brand']['id']}',
        );
        brandController.text = clientController.carsBrandsNames[brandIndex];
        getModelsOnlyMatchWithSelectedBrandWithoutUpdate(
          '${clientController.carsList[widget.index]['brand']['id']}',
        );
        if (clientController.carsList[widget.index]['model'].isNotEmpty) {
          int modelIndex = carsModelsIds.indexOf(
            '${clientController.carsList[widget.index]['model']['id']}',
          );
          modelController.text = carsModelsNames[modelIndex];
        }
      }
    } else {
      technicianController.text =
          clientController.carsList[widget.index]['technician'].isEmpty
              ? ''
              : clientController.carsList[widget.index]['technician']['name'];
      colorController.text =
          clientController.carsList[widget.index]['color'].isEmpty
              ? ''
              : clientController.carsList[widget.index]['color'];
      brandController.text =
          clientController.carsList[widget.index]['brand'].isEmpty
              ? ''
              : clientController.carsList[widget.index]['brand'];
      modelController.text =
          clientController.carsList[widget.index]['model'].isEmpty
              ? ''
              : clientController.carsList[widget.index]['model'];
    }
    odometerController.text =
        clientController.carsList[widget.index]['odometer'];
    chassisNoController.text =
        clientController.carsList[widget.index]['chassis_no'];
    registrationController.text =
        clientController.carsList[widget.index]['registration'];
    commentController.text = clientController.carsList[widget.index]['comment'];
    yearController.text = clientController.carsList[widget.index]['year'];
    ratingController.text = clientController.carsList[widget.index]['rating'];
    faxController.text = clientController.carsList[widget.index]['car_fax'];

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClientController>(
      builder: (cont) {
        return Container(
          margin: const EdgeInsets.only(top: 20.0),
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Primary.primary.withAlpha((0.2 * 255).toInt()),
            ),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gapH28,
              GetBuilder<HomeController>(
                builder: (homeCont) {
                  double smallRowWidth =
                      homeCont.isMenuOpened
                          ? MediaQuery.of(context).size.width * 0.22
                          : MediaQuery.of(context).size.width * 0.27;
                  double smallTextFieldWidth =
                      homeCont.isMenuOpened
                          ? MediaQuery.of(context).size.width * 0.15
                          : MediaQuery.of(context).size.width * 0.19;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DialogTextField(
                            textEditingController: registrationController,
                            text: 'registration'.tr,
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateCarRegistration(widget.index, val);
                            },
                          ),
                          DialogTextField(
                            textEditingController: chassisNoController,
                            text: 'chassis_no'.tr,
                            hint: '',
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateCarChassisNo(widget.index, val);
                            },
                          ),
                          DialogTextField(
                            textEditingController: faxController,
                            text: 'car_fax'.tr,
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateCarFax(widget.index, val);
                            },
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableDropDownMenuWithSearch(
                            list: cont.carsBrandsNames,
                            text: 'brand'.tr,
                            hint: '${'search'.tr}...',
                            controller: brandController,
                            onSelected: (String? val) {
                              int index = cont.carsBrandsNames.indexOf(val!);
                              String id = cont.carsBrandsIds[index];
                              cont.updateCarBrand(widget.index, id, val);
                              getModelsOnlyMatchWithSelectedBrand(id);
                            },
                            validationFunc: (value) {
                              // if (value == null || value.isEmpty) {
                              //   return 'select_option'.tr;
                              // }
                              // return null;
                            },
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            clickableOptionText: 'create_new_brand'.tr,
                            isThereClickableOption: true,
                            onTappedClickableOption: () {
                              garageController.setSelectedAttributeText(
                                'brand',
                              );
                              showDialog<String>(
                                context: context,
                                builder:
                                    (BuildContext context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      elevation: 0,
                                      content: AddGarageAttributeDialog(),
                                      // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
                                    ),
                              );
                            },
                          ),
                          cont.isModelsFetched
                              ? ReusableDropDownMenuWithSearch(
                                key: ValueKey( carsModelsNames.length),
                                list:  carsModelsNames,
                                text: 'model'.tr,
                                hint: '${'search'.tr}...',
                                controller: modelController,
                                onSelected: (String? val) {
                                  int index =  carsModelsNames.indexOf(
                                    val!,
                                  );
                                  String id =  carsModelsIds[index];
                                  cont.updateCarModel(widget.index, id, val);
                                },
                                validationFunc: (value) {
                                  // if (value == null || value.isEmpty) {
                                  //   return 'select_option'.tr;
                                  // }
                                  // return null;
                                },
                                rowWidth: smallRowWidth,
                                textFieldWidth: smallTextFieldWidth,
                                clickableOptionText: 'create_new_model'.tr,
                                isThereClickableOption: true,
                                onTappedClickableOption: () {
                                  garageController.setSelectedAttributeText(
                                    'model',
                                  );
                                  showDialog<String>(
                                    context: context,
                                    builder:
                                        (BuildContext context) => AlertDialog(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(9),
                                            ),
                                          ),
                                          elevation: 0,
                                          content: AddGarageAttributeDialog(),
                                          // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
                                        ),
                                  );
                                },
                              )
                              : loading(),
                          SizedBox(
                            width: smallRowWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('year'.tr),
                                DropdownMenu<String>(
                                  width: smallTextFieldWidth,
                                  enableSearch: true,
                                  controller: yearController,
                                  hintText: '${'search'.tr}...',
                                  inputDecorationTheme: InputDecorationTheme(
                                    hintStyle: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      25,
                                      5,
                                    ),
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
                                  menuHeight: 250,
                                  dropdownMenuEntries:
                                      years.map<DropdownMenuEntry<String>>((
                                        String option,
                                      ) {
                                        return DropdownMenuEntry<String>(
                                          value: option,
                                          label: option,
                                        );
                                      }).toList(),
                                  enableFilter: false,
                                  onSelected: (String? val) {
                                    cont.updateCarYear(widget.index, val!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableDropDownMenuWithSearch(
                            list: cont.carsColorsNames,
                            text: 'color'.tr,
                            hint: '${'search'.tr}...',
                            controller: colorController,
                            onSelected: (String? val) {
                              int index = cont.carsColorsNames.indexOf(val!);
                              String id = cont.carsColorsIds[index];
                              cont.updateCarColor(widget.index, id, val);
                            },
                            validationFunc: (value) {
                              // if (value == null || value.isEmpty) {
                              //   return 'select_option'.tr;
                              // }
                              // return null;
                            },
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            clickableOptionText: 'create_new_color'.tr,
                            isThereClickableOption: true,
                            onTappedClickableOption: () {
                              garageController.setSelectedAttributeText(
                                'color',
                              );
                              showDialog<String>(
                                context: context,
                                builder:
                                    (BuildContext context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      elevation: 0,
                                      content: AddGarageAttributeDialog(),
                                      // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
                                    ),
                              );
                            },
                          ),
                          SizedBox(
                            width: smallRowWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('rating'.tr),
                                DropdownMenu<String>(
                                  width: smallTextFieldWidth,
                                  enableSearch: true,
                                  controller: ratingController,
                                  hintText: '${'search'.tr}...',
                                  inputDecorationTheme: InputDecorationTheme(
                                    hintStyle: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                    contentPadding: const EdgeInsets.fromLTRB(
                                      20,
                                      0,
                                      25,
                                      5,
                                    ),
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
                                  menuHeight: 250,
                                  dropdownMenuEntries:
                                      carRatings.map<DropdownMenuEntry<String>>(
                                        (String option) {
                                          return DropdownMenuEntry<String>(
                                            value: option,
                                            label: option,
                                          );
                                        },
                                      ).toList(),
                                  enableFilter: false,
                                  onSelected: (String? val) {
                                    cont.updateCarRating(widget.index, val!);
                                  },
                                ),
                              ],
                            ),
                          ),
                          DialogTextField(
                            textEditingController: odometerController,
                            text: 'odometer'.tr,
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            validationFunc: (val) {},
                            onChangedFunc: (val) {
                              cont.updateCarOdometer(widget.index, val);
                            },
                          ),
                        ],
                      ),
                      gapH10,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ReusableDropDownMenuWithSearch(
                            list: cont.carsTechnicianNames,
                            text: 'technician'.tr,
                            hint: '${'search'.tr}...',
                            controller: technicianController,
                            onSelected: (String? val) {
                              int index = cont.carsTechnicianNames.indexOf(
                                val!,
                              );
                              String id = cont.carsTechnicianIds[index];
                              cont.updateCarTechnician(widget.index, id, val);
                            },
                            validationFunc: (value) {
                              // if (value == null || value.isEmpty) {
                              //   return 'select_option'.tr;
                              // }
                              // return null;
                            },
                            rowWidth: smallRowWidth,
                            textFieldWidth: smallTextFieldWidth,
                            clickableOptionText: 'add_new_technician'.tr,
                            isThereClickableOption: true,
                            onTappedClickableOption: () {
                              garageController.setSelectedAttributeText(
                                'color',
                              );
                              showDialog<String>(
                                context: context,
                                builder:
                                    (BuildContext context) => AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(9),
                                        ),
                                      ),
                                      elevation: 0,
                                      content: AddGarageAttributeDialog(),
                                      // content:widget.idDesktop? const CreateCategoryDialogContent(): const MobileCreateCategoryDialogContent(),
                                    ),
                              );
                            },
                          ),
                          SizedBox(width: smallRowWidth),
                          SizedBox(width: smallRowWidth),
                        ],
                      ),
                      gapH10,
                    ],
                  );
                },
              ),
              gapH10,
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'comment.....',
                  hintStyle: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      color: Primary.primary.withAlpha((0.2 * 255).toInt()),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide(
                      width: 1,
                      color: Primary.primary.withAlpha((0.4 * 255).toInt()),
                    ),
                  ),
                ),
                onChanged: (val) {
                  cont.updateCarComment(widget.index, val);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class MobileAddNewClient extends StatefulWidget {
  const MobileAddNewClient({super.key});

  @override
  State<MobileAddNewClient> createState() => _MobileAddNewClientState();
}

class _MobileAddNewClientState extends State<MobileAddNewClient> {
  TextEditingController searchController = TextEditingController();
  TextEditingController clientNameController = TextEditingController();
  TextEditingController clientNumberController = TextEditingController();
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
  TextEditingController taxIdController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController internalNoteController = TextEditingController();
  TextEditingController grantedDiscountController = TextEditingController();
  final HomeController homeController = Get.find();
  String paymentTerm = '',
      priceListSelected = '',
      selectedCountry = '',
      selectedCity = '';
  String selectedPhoneCode = '', selectedMobileCode = '';
  int selectedClientType = 1;
  int selectedTabIndex = 0;
  List tabsList = [
    // 'contacts_addresses',
    // 'sales',
    // 'internal_note',
    'settings',
  ];
  Map data = {};
  bool isClientsInfoFetched = false;
  String copyOfClientNumber = '';
  getFieldsForCreateClientsFromBack() async {
    var p = await getFieldsForCreateClient();
    if ('$p' != '[]') {
      setState(() {
        data.addAll(p);
        isClientsInfoFetched = true;
        clientNumberController.text = data['clientNumber'];
        copyOfClientNumber = data['clientNumber'];
      });
    }
  }

  List<String> titles = ['Doctor', 'Miss', 'Mister', 'Maitre', 'Professor'];
  String selectedTitle = '';
  bool isActiveInPosChecked = false;
  bool isBlockedChecked = false;
  final _formKey = GlobalKey<FormState>();

  List<String> countriesNamesList = [];
  List<String> citiesNamesList = [];
  bool isCountriesFetched = false;
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

  final clientNameKey = GlobalKey();
  final clientNumberKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final taxNumberKey = GlobalKey();
  final phoneKey = GlobalKey();
  final mobileKey = GlobalKey();
  void _scrollToFirstInvalidField() {
    List<GlobalKey> fieldKeys = [
      clientNumberKey,
      clientNameKey,
      taxNumberKey,
      phoneKey,
      mobileKey,
    ];

    for (var key in fieldKeys) {
      final context = key.currentContext;
      if (context != null) {
        final FormFieldState<dynamic>? field =
            key.currentState as FormFieldState?;
        if (field != null && field.hasError) {
          Scrollable.ensureVisible(
            context,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          break;
        }
      }
    }
  }

  void _validateAndScroll() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollToFirstInvalidField();
    });
  }

  @override
  void initState() {
    getFieldsForCreateClientsFromBack();
    getCountriesFromBack();
    super.initState();
  }

  ClientController clientController = Get.find();
  @override
  Widget build(BuildContext context) {
    return isClientsInfoFetched
        ? Container(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.03,
          ),
          // height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageTitle(text: 'create_new_client'.tr),
                  // gapH32,
                  // const AddPhotoCircle(),
                  gapH32,
                  ReusableRadioBtns(
                    isRow: true,
                    groupVal: selectedClientType,
                    title1: 'individual'.tr,
                    title2: 'company'.tr,
                    func: (value) {
                      setState(() {
                        selectedClientType = value!;
                      });
                    },
                    width1: MediaQuery.of(context).size.width * 0.45,
                    width2: MediaQuery.of(context).size.width * 0.45,
                  ),
                  gapH16,
                  DialogTextField(
                    globalKey: clientNumberKey,
                    textEditingController: clientNumberController,
                    text: '${'client_code'.tr}*',
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (value) {
                      if (value.isEmpty) {
                        return 'required_field'.tr;
                      }
                      return null;
                    },
                  ),
                  gapH16,
                  DialogTextField(
                    globalKey: clientNameKey,
                    textEditingController: clientNameController,
                    text: '${'client_name'.tr}*',
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (value) {
                      if (value.isEmpty) {
                        return 'required_field'.tr;
                      }
                      return null;
                    },
                  ),

                  gapH10,
                  DialogTextField(
                    textEditingController: referenceController,
                    text: 'reference'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (val) {},
                  ),

                  gapH10,
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('title'.tr),
                        DropdownMenu<String>(
                          width: MediaQuery.of(context).size.width * 0.55,
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
                          enableFilter: false,
                          onSelected: (String? val) {
                            setState(() {
                              selectedTitle = val!;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  gapH10,
                  DialogTextField(
                    textEditingController: jobPositionController,
                    text: 'job_position'.tr,
                    hint: 'Sales Director,Sales...',
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (val) {},
                  ),
                  gapH10,
                  DialogTextField(
                    globalKey: taxNumberKey,
                    textEditingController: taxIdController,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    validationFunc: (val) {
                      if (selectedClientType == 2 && val.isEmpty) {
                        return 'required_field'.tr;
                      }
                      return null;
                    },
                    text: 'tax_number'.tr,
                  ),
                  gapH10,
                  PhoneTextField(
                    globalKey: phoneKey,
                    textEditingController: phoneController,
                    text: 'phone'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (val) {
                      if (val.isNotEmpty && val.length < 6) {
                        return '6_digits'.tr;
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
                  gapH10,
                  PhoneTextField(
                    globalKey: mobileKey,
                    textEditingController: mobileController,
                    text: 'mobile'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (val) {
                      if (val.isNotEmpty && val.length < 6) {
                        return '6_digits'.tr;
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
                  gapH10,
                  DialogTextField(
                    textEditingController: emailController,
                    text: 'email'.tr,
                    hint: 'example@gmail.com',
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (String value) {
                      if (value.isNotEmpty &&
                          !RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(value)) {
                        return 'check_format'.tr;
                      }
                      return null;
                    },
                  ),
                  gapH10,
                  DialogTextField(
                    textEditingController: websiteController,
                    text: 'website'.tr,
                    hint: 'www.example.com',
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (String value) {},
                  ),
                  gapH10,
                  DialogTextField(
                    textEditingController: floorBldgController,
                    text: 'floor_bldg'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (val) {},
                  ),
                  gapH10,
                  DialogTextField(
                    textEditingController: streetController,
                    text: 'street'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
                    validationFunc: (val) {},
                  ),
                  gapH10,
                  isCountriesFetched
                      ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('country'.tr),
                            DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.55,
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
                              enableFilter: false,
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
                      : loading(),
                  gapH10,
                  isCitiesFetched
                      ? SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('city'.tr),
                            DropdownMenu<String>(
                              width: MediaQuery.of(context).size.width * 0.55,
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
                              enableFilter: false,
                              onSelected: (String? val) {
                                setState(() {
                                  selectedCity = val!;
                                });
                              },
                            ),
                          ],
                        ),
                      )
                      : loading(),
                  gapH40,
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
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('granted_discount'.tr),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.55,
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
                                        errorStyle: const TextStyle(
                                          fontSize: 10.0,
                                        ),
                                        focusedErrorBorder:
                                            const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
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
                                        // NumberFormatter(),
                                        // WhitelistingTextInputFormatter.digitsOnly
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ReusableInputNumberField(
                            //   controller:
                            //       grantedDiscountController,
                            //   textFieldWidth:
                            //       MediaQuery.of(context)
                            //               .size
                            //               .width *
                            //           0.55,
                            //   rowWidth: MediaQuery.of(context)
                            //       .size
                            //       .width,
                            //   onChangedFunc: (val) {},
                            //   validationFunc: (value) {},
                            //   text:'granted_discount'.tr,
                            // ),
                            gapH20,
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'show_in_POS'.tr,
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
                              ],
                            ),
                            gapH20,
                            Row(
                              children: [
                                Expanded(
                                  child: ListTile(
                                    title: Text(
                                      'blocked'.tr,
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
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedClientType = 1;
                                  selectedPhoneCode = '';
                                  selectedMobileCode = '';
                                  paymentTerm = '';
                                  priceListSelected = '';
                                  selectedCountry = '';
                                  grantedDiscountController.clear();
                                  clientNameController.clear();
                                  referenceController.clear();
                                  internalNoteController.clear();
                                  websiteController.clear();
                                  phoneController.clear();
                                  floorBldgController.clear();
                                  titleController.clear();
                                  mobileController.clear();
                                  taxIdController.clear();
                                  cityController.clear();
                                  countryController.clear();
                                  selectedCountry = '';
                                  selectedCity = '';
                                  emailController.clear();
                                  jobPositionController.clear();
                                  streetController.clear();
                                  isBlockedChecked = false;
                                  isActiveInPosChecked = false;
                                  grantedDiscountController.clear();
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
                                if (!_formKey.currentState!.validate()) {
                                  _validateAndScroll();
                                } else {
                                  var res = await storeClient(
                                    referenceController.text,
                                    isActiveInPosChecked ? '1' : '0',
                                    grantedDiscountController.text,
                                    isBlockedChecked ? '1' : '0',
                                    selectedClientType == 1
                                        ? 'individual'
                                        : 'company',
                                    clientNameController.text,
                                    clientNumberController.text ==
                                            copyOfClientNumber
                                        ? ''
                                        : clientNumberController.text,
                                    selectedCountry,
                                    selectedCity,
                                    '',
                                    '',
                                    streetController.text,
                                    floorBldgController.text,
                                    jobPositionController.text,
                                    selectedPhoneCode.isEmpty
                                        ? '+90'
                                        : selectedPhoneCode,
                                    phoneController.text,
                                    selectedMobileCode.isEmpty
                                        ? '+90'
                                        : selectedMobileCode,
                                    mobileController.text,
                                    emailController.text,
                                    titleController.text,
                                    '',
                                    taxIdController.text,
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
                                    clientController.selectedSalesPersonId
                                        .toString(),
                                    paymentTerm,
                                    priceListSelected,
                                    internalNoteController.text,
                                    '',
                                    clientController.contactsList,
                                    clientController.carsList,
                                  );
                                  if (res['success'] == true) {
                                    CommonWidgets.snackBar(
                                      'Success',
                                      res['message'],
                                    );
                                    homeController.selectedTab.value =
                                        'clients';
                                  } else {
                                    CommonWidgets.snackBar(
                                      'error',
                                      res['message'],
                                    );
                                  }
                                }
                              },
                              width: 100,
                              height: 35,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        : const CircularProgressIndicator();
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
          width: MediaQuery.of(context).size.width * 0.3,
          // height: MediaQuery.of(context).size.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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

// class AddPhotoCircle extends StatefulWidget {
//   const AddPhotoCircle({super.key});
//
//   @override
//   State<AddPhotoCircle> createState() => _AddPhotoCircleState();
// }
//
// class _AddPhotoCircleState extends State<AddPhotoCircle> {
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       child: CircleAvatar(
//         radius: 60,
//         backgroundColor: Primary.p20,
//         child: DottedBorder(
//             borderType: BorderType.Circle,
//             color: Primary.primary,
//             dashPattern: const [5, 10],
//             child: Container(
//                 height: 80,
//                 width: 80,
//                 decoration: const BoxDecoration(shape: BoxShape.circle),
//                 child: Center(
//                   child: Text(
//                     String.fromCharCode(Icons.add_rounded.codePoint),
//                     style: TextStyle(
//                       inherit: false,
//                       color: Primary.primary,
//                       fontSize: 25,
//                       fontWeight: FontWeight.w800,
//                       fontFamily: Icons.space_dashboard_outlined.fontFamily,
//                     ),
//                   ),
//                 ) // Icon(Icons.add,color: Primary.primary,),
//                 )),
//       ),
//     );
//   }
// }

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
              onTap: () {
                showCountryPicker(
                  context: context,
                  // showPhoneCode: true, // optional. Shows phone code before the country name.
                  onSelect: (country) {},
                );
                // widget.onChangedFunc(value);
              },
              onChanged: (value) => widget.onChangedFunc(value),
            ),
          ),
        ],
      ),
    );
  }
}
