import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Backend/ClientsBackend/get_client_create_info.dart';
import 'package:rooster_app/Backend/get_cities_of_a_specified_country.dart';
import 'package:rooster_app/Backend/get_countries.dart';
import 'package:rooster_app/Widgets/loading.dart';
import '../../Backend/ClientsBackend/store_client.dart';
import '../../Controllers/home_controller.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';

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
    // 'contacts_addresses',
    // 'sales',
    // 'internal_note',
    'settings',
    'sales',
  ];
  Map data = {};
  List<String> pricesListsNames=[];
  List<String> pricesListsCodes=[];
  List<String> pricesListsIds=[];
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
      for(var priceList in p['pricelists']){
        pricesListsNames.add(priceList['title']);
        pricesListsIds.add('${priceList['id']}');
        pricesListsCodes.add('${priceList['code']}');
      }
    }
  }

  List<String> titles = ['Doctor', 'Miss', 'Mister', 'Maitre', 'Professor'];
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

  @override
  void initState() {
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
                  gapH16,
                  // Text(
                  //   '${data['clientNumber'] ?? ''}',
                  //   style: const TextStyle(
                  //       fontSize: 36, fontWeight: FontWeight.bold),
                  // ),
                  DialogTextField(
                    textEditingController: clientNumberController,
                    text: '${'client_code'.tr}*',
                    rowWidth: MediaQuery.of(context).size.width * 0.5,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.4,
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
                    rowWidth: MediaQuery.of(context).size.width * 0.5,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.4,
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
                        rowWidth: MediaQuery.of(context).size.width * 0.22,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (val) {},
                      ),
                      PhoneTextField(
                        textEditingController: phoneController,
                        text: 'phone'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.25,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.2,
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
                        rowWidth: MediaQuery.of(context).size.width * 0.22,
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
                        width: MediaQuery.of(context).size.width * 0.22,
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
                        rowWidth: MediaQuery.of(context).size.width * 0.25,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (val) {
                          if (val.isNotEmpty && val.length < 9) {
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
                      // DialogTextField(
                      //   textEditingController: mobileController,
                      //   text: 'mobile'.tr,
                      //   rowWidth:  MediaQuery.of(context).size.width * 0.22,
                      //   textFieldWidth:  MediaQuery.of(context).size.width * 0.15,
                      //   validationFunc: (){},
                      //   onChangedFunc: (value){
                      //     setState(() {
                      //       // mainDescriptionController.text=value;
                      //     });
                      //   },),
                      DialogTextField(
                        textEditingController: streetController,
                        text: 'street'.tr,
                        rowWidth: MediaQuery.of(context).size.width * 0.22,
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
                        rowWidth: MediaQuery.of(context).size.width * 0.22,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.15,
                        validationFunc: (val) {},
                      ),
                      DialogTextField(
                        textEditingController: emailController,
                        text: 'email'.tr,
                        hint: 'example@gmail.com',
                        rowWidth: MediaQuery.of(context).size.width * 0.25,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (String value) {
                          if (value.isNotEmpty &&
                              !RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                              ).hasMatch(value)) {
                            return 'check_format'.tr;
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
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('country'.tr),
                                DropdownMenu<String>(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
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
                            width: MediaQuery.of(context).size.width * 0.22,
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
                        rowWidth: MediaQuery.of(context).size.width * 0.22,
                        textFieldWidth:
                            MediaQuery.of(context).size.width * 0.15,
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
                        rowWidth: MediaQuery.of(context).size.width * 0.25,
                        textFieldWidth: MediaQuery.of(context).size.width * 0.2,
                        validationFunc: (String value) {
                          // if(value.isNotEmpty && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          //     .hasMatch(value)) {
                          //   return 'check_format'.tr ;
                          // }return null;
                        },
                      ),

                      isCitiesFetched
                          ? SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('city'.tr),
                                DropdownMenu<String>(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
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
                                // SizedBox(
                                //   width:  MediaQuery.of(context)
                                //       .size
                                //       .width *
                                //       0.25,
                                //   child: Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Text(
                                //         'granted_discount'.tr,
                                //       ),
                                //       SizedBox(
                                //         width:   MediaQuery.of(context)
                                //             .size
                                //             .width *
                                //             0.15,
                                //         child: TextFormField(
                                //           // textAlign: TextAlign.center,
                                //           decoration: InputDecoration(
                                //             contentPadding: const EdgeInsets.fromLTRB(20, 0, 25, 10),
                                //             enabledBorder: OutlineInputBorder(
                                //               borderSide: BorderSide(
                                //                   color: Primary.primary.withAlpha((0.2 * 255).toInt()), width: 1),
                                //               borderRadius:
                                //               const BorderRadius.all(Radius.circular(9)),
                                //             ),
                                //             focusedBorder: OutlineInputBorder(
                                //               borderSide: BorderSide(
                                //                   color: Primary.primary.withAlpha((0.4 * 255).toInt()), width: 2),
                                //               borderRadius:
                                //               const BorderRadius.all(Radius.circular(9)),
                                //             ),
                                //             errorStyle: const TextStyle(
                                //               fontSize: 10.0,
                                //             ),
                                //             focusedErrorBorder: const OutlineInputBorder(
                                //               borderRadius: BorderRadius.all(Radius.circular(9)),
                                //               borderSide: BorderSide(width: 1, color: Colors.red),
                                //             ),
                                //           ),
                                //           controller: grantedDiscountController,
                                //           keyboardType: const TextInputType.numberWithOptions(
                                //             decimal: false,
                                //             signed: true,
                                //           ),
                                //           inputFormatters: <TextInputFormatter>[
                                //             FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                                //             // WhitelistingTextInputFormatter.digitsOnly
                                //           ],
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
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
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  child: Column(
                                    children: [
                                      DialogDropMenu(
                                        optionsList: const [''],
                                        text: '${'sales_person'.tr}*',
                                        hint: '',
                                        rowWidth:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        textFieldWidth:
                                            MediaQuery.of(context).size.width *
                                            0.17,
                                        onSelected: () {},
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
                                        optionsList:pricesListsCodes ,
                                        text: 'pricelist'.tr,
                                        hint: '',
                                        rowWidth:
                                            MediaQuery.of(context).size.width *
                                            0.3,
                                        textFieldWidth:
                                            MediaQuery.of(context).size.width *
                                            0.17,
                                        onSelected: (val) {
                                          var index=pricesListsCodes.indexOf(val);
                                          setState(() {
                                            selectedPriceListId = pricesListsIds[index];
                                          });
                                        },
                                      ),
                                    ],
                                  ),
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
                                    '',
                                    paymentTerm,
                                    selectedPriceListId,
                                    internalNoteController.text,
                                    '',
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
                  Row(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
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
                        width: MediaQuery.of(context).size.width * 0.45,
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
                  gapH10,
                  PhoneTextField(
                    globalKey: mobileKey,
                    textEditingController: mobileController,
                    text: 'mobile'.tr,
                    rowWidth: MediaQuery.of(context).size.width * 0.9,
                    textFieldWidth: MediaQuery.of(context).size.width * 0.55,
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
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
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
                                    '',
                                    paymentTerm,
                                    priceListSelected,
                                    internalNoteController.text,
                                    '',
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
