import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_picker_dropdown.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Backend/ClientsBackend/get_client_create_info.dart';
import '../../Backend/ClientsBackend/store_client.dart';
import '../../Backend/get_cities_of_a_specified_country.dart';
import '../../Backend/get_countries.dart';
import '../../Controllers/client_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/dialog_drop_menu.dart';
import '../../Widgets/loading.dart';
import '../../Widgets/page_title.dart';
import '../../Widgets/reusable_btn.dart';
import '../../Widgets/reusable_text_field.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import 'add_new_client.dart';

class CreateClientDialog extends StatefulWidget {
  const CreateClientDialog({super.key});

  @override
  State<CreateClientDialog> createState() =>
      _CreateClientDialogState();
}

class _CreateClientDialogState
    extends State<CreateClientDialog> {
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
  TextEditingController taxIdController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController taxNumberController = TextEditingController();
  TextEditingController internalNoteController = TextEditingController();
  TextEditingController grantedDiscountController = TextEditingController();
  final HomeController homeController = Get.find();

  String paymentTerm = '', selectedPriceListId = '', selectedCountry = '',selectedCity='';
  String selectedPhoneCode = '', selectedMobileCode = '';
  int selectedClientType = 1;
  int selectedTabIndex = 0;
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
  Map data = {};
  bool isClientsInfoFetched = false;
  List<String> pricesListsNames=[];
  List<String> pricesListsCodes=[];
  List<String> pricesListsIds=[];
  getFieldsForCreateClientsFromBack() async {
    var p = await getFieldsForCreateClient();
    if ('$p' != '[]') {
      setState(() {
        data.addAll(p);
        isClientsInfoFetched = true;
        clientNumberController.text=data['clientNumber'];
      });
      for(var priceList in p['pricelists']){
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

  List<String> titles = ['Doctor', 'Miss', 'Mister', 'Maitre', 'Professor'];
  String selectedTitle = '';
  bool isActiveInPosChecked = false;
  bool isBlockedChecked = false;
  final _formKey = GlobalKey<FormState>();

  List<String> countriesNamesList=[];
  bool isCountriesFetched = false;
  List<String> citiesNamesList=[];
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
      isCitiesFetched =false;
      citiesNamesList=[];
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
    setTabsList();
    clientController.contactsList=[];
    clientController.carsList=[];
    clientController.salesPersonController.clear();
    clientController.getAllUsersSalesPersonFromBack();
    getFieldsForCreateClientsFromBack();
    getCountriesFromBack();
    super.initState();
  }
  ClientController clientController=Get.find();

  @override
  Widget build(BuildContext context) {
    // double rowWidth=MediaQuery.of(context).size.width * 0.22;
    // double  textFieldWidth=MediaQuery.of(context).size.width * 0.15;
    return Form(
      key: _formKey,
      child: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.95,
        padding:  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: isClientsInfoFetched
            ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PageTitle(text: 'create_new_client'.tr),
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
                    gapH10,
                    gapH32,
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: ListTile(
                            title: Text('individual'.tr,
                                style: const TextStyle(fontSize: 12)),
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
                            title: Text('company'.tr,
                                style: const TextStyle(fontSize: 12)),
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
                            if(val.isNotEmpty && val.length<7){
                              return '7_digits'.tr;
                            }return null;
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
                                controller: searchController,
                                hintText: 'Doctor, Miss, Mister',
                                inputDecorationTheme: InputDecorationTheme(
                                  // filled: true,
                                  hintStyle: const TextStyle(
                                      fontStyle: FontStyle.italic),
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
                                menuHeight: 250,
                                dropdownMenuEntries: titles
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
                            if(val.isNotEmpty && val.length<9){
                              return '7_digits'.tr;
                            }return null;
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
                            if(value.isNotEmpty && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(value)) {
                              return 'check_format'.tr ;
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
                                width: MediaQuery.of(context).size.width * 0.15,
                                // requestFocusOnTap: false,
                                enableSearch: true,
                                controller: countryController,
                                hintText: '',
                                inputDecorationTheme: InputDecorationTheme(
                                  // filled: true,
                                  hintStyle: const TextStyle(
                                      fontStyle: FontStyle.italic),
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
                                menuHeight: 250,
                                dropdownMenuEntries: countriesNamesList
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
                            :SizedBox(
                            width: MediaQuery.of(context).size.width * 0.22,
                            child: loading()),
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
                            if( selectedClientType==2&& val.isEmpty){
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
                            ?SizedBox(
                          width: MediaQuery.of(context).size.width * 0.22,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('city'.tr),
                              DropdownMenu<String>(
                                width: MediaQuery.of(context).size.width * 0.15,
                                // requestFocusOnTap: false,
                                enableSearch: true,
                                controller: cityController,
                                hintText: '',
                                inputDecorationTheme: InputDecorationTheme(
                                  // filled: true,
                                  hintStyle: const TextStyle(
                                      fontStyle: FontStyle.italic),
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
                                menuHeight: 250,
                                dropdownMenuEntries: citiesNamesList
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
                            width: MediaQuery.of(context).size.width*0.22,
                            child: loading()),
                      ],
                    ),
                    gapH40,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Wrap(
                            spacing: 0.0,
                            direction: Axis.horizontal,
                            children: tabsList
                                .map((element) => ReusableBuildTabChipItem(
                                index: tabsList.indexOf(element),
                                isClicked:selectedTabIndex ==tabsList.indexOf(element),
                                name: element,
                                function: (){
                                  setState(() {
                                    selectedTabIndex = tabsList.indexOf(element);
                                  });
                                },
                                // element['id'],
                                // element['name'],
                                ))
                                .toList()),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.01,
                          vertical: 25),
                      height: 600,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(6),
                            bottomRight: Radius.circular(6)),
                        color: Colors.white,
                      ),
                      child:
                      Column(
                        children: [
                          selectedTabIndex==0
                              ? Column(
                            mainAxisAlignment:
                            MainAxisAlignment.start,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
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
                                controller:
                                grantedDiscountController,
                                textFieldWidth:
                                MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.15,
                                rowWidth: MediaQuery.of(context)
                                    .size
                                    .width *
                                    0.25,
                                onChangedFunc: (val) {},
                                validationFunc: (value) {},
                                text:'granted_discount'.tr,
                              ),
                              gapH20,
                              Row(
                                children: [
                                  Expanded(
                                      child: ListTile(
                                        title: Text('show_in_POS'.tr,
                                            style: const TextStyle(
                                                fontSize: 12)),
                                        leading: Checkbox(
                                          // checkColor: Colors.white,
                                          // fillColor: MaterialStateProperty.resolveWith(getColor),
                                          value: isActiveInPosChecked,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              isActiveInPosChecked =
                                              value!;
                                            });
                                          },
                                        ),
                                      )),
                                ],
                              ),
                              gapH20,
                              Row(
                                children: [
                                  Expanded(
                                      child: ListTile(
                                        title: Text('blocked'.tr,
                                            style: const TextStyle(
                                                fontSize: 12)),
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
                                      )),
                                ],
                              ),
                            ],
                          ):
                      selectedTabIndex==1
                          ?ContactsAndAddressesSection()
                          :selectedTabIndex == 2
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
                                          controller: cont.salesPersonController,
                                          optionsList:
                                          clientController
                                              .salesPersonListNames,
                                          text: 'sales_person'.tr,
                                          hint: 'search'.tr,
                                          rowWidth:
                                          MediaQuery.of(context).size.width *
                                              0.3,
                                          textFieldWidth:
                                          MediaQuery.of(context).size.width *
                                              0.17,
                                          onSelected: (String? val) {
                                            setState(() {
                                              var index = clientController
                                                  .salesPersonListNames
                                                  .indexOf(val!);
                                              clientController.setSelectedSalesPerson
                                                (val,
                                                  clientController
                                                      .salesPersonListId[index]);
                                            });
                                          },
                                        );
                                      }
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
                                      selectedClientType=1;
                                      selectedPhoneCode = '';
                                      selectedMobileCode = '';
                                      paymentTerm = ''; selectedPriceListId = ''; selectedCountry = '';
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
                                      selectedCountry='';
                                      selectedCity='';
                                      emailController.clear();
                                      jobPositionController.clear();
                                      streetController.clear();
                                      isBlockedChecked=false;
                                      isActiveInPosChecked=false;
                                      grantedDiscountController.clear();
                                    });
                                  },
                                  child: Text(
                                    'discard'.tr,
                                    style: TextStyle(
                                        decoration: TextDecoration.underline,
                                        color: Primary.primary),
                                  )),
                              gapW24,
                              ReusableButtonWithColor(
                                  btnText: 'save'.tr,
                                  onTapFunction: () async {
                                    if (_formKey.currentState!.validate()) {
                                      var res = await storeClient(
                                          referenceController.text,
                                          isActiveInPosChecked?'1':'0',
                                          grantedDiscountController.text,
                                          isBlockedChecked?'1':'0',
                                          selectedClientType == 1
                                              ? 'individual'
                                              : 'company',
                                          clientNameController.text,
                                          clientNumberController.text,
                                          selectedCountry,
                                          selectedCity,
                                          '',
                                          '',
                                          streetController.text,
                                          floorBldgController.text,
                                          jobPositionController.text,
                                          selectedPhoneCode.isEmpty?'+961':selectedPhoneCode,
                                          phoneController.text,
                                          selectedMobileCode.isEmpty?'+961':selectedMobileCode,
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
                                          clientController.selectedSalesPersonId.toString(),
                                          paymentTerm,
                                          selectedPriceListId,
                                          internalNoteController.text,
                                          '',
                                          clientController.contactsList);
                                      if (res['success'] == true) {
                                        Get.back();

                                        CommonWidgets.snackBar('Success',
                                            res['message'] );
                                        // Get.back();
                                        // homeController.selectedTab.value =
                                        // 'clients';
                                      } else {
                                        CommonWidgets.snackBar(
                                            'error', res['message'] );
                                      }
                                    }
                                  },
                                  width: 100,
                                  height: 35),
                            ],
                          )
                        ],
                      )
                          ,
                    )
                  ],
                ),
            )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

}








