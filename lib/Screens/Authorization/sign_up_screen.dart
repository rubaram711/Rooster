import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:rooster_app/Locale_Memory/DefaultWareHouse/save_default_warehouse_locally.dart';
import 'package:rooster_app/const/string_extensions.dart';
import '../../Backend/login_api.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Widgets/custom_snak_bar.dart';
import '../../Widgets/reusable_btn.dart';
import '../../const/Sizes.dart';
import '../../const/colors.dart';
import '../welcome_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    // LanguagesController languagesController = Get.find();
    return Scaffold(
      body: ScreenTypeLayout.builder(
        breakpoints: const ScreenBreakpoints(
          tablet: 600,
          desktop: 950,
          watch: 300,
        ),
        mobile:
            (p0) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: const SignForm(isDesktop: false),
                  ),
                  // Stack(
                  //   alignment: Alignment.center,
                  //   children: [
                  //     Image.asset(
                  //       'assets/images/bg22.png',
                  //       width: MediaQuery.of(context).size.width,
                  //       height: MediaQuery.of(context).size.height,
                  //       fit: BoxFit.cover,
                  //     ),
                  //     Image.asset(
                  //       'assets/images/signUp.png',
                  //       width: MediaQuery.of(context).size.width * 0.7,
                  //       height: MediaQuery.of(context).size.height * 0.5,
                  //       fit: BoxFit.contain,
                  //     ),
                  //   ],
                  // )
                ],
              ),
            ),
        tablet:
            (p0) => SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: const SignForm(isDesktop: false),
                  ),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/images/bg22.png',
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        fit: BoxFit.cover,
                      ),
                      Image.asset(
                        'assets/images/signUp.png',
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        desktop:
            (p0) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height,
                  child: const SignForm(isDesktop: true),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/bg22.png',
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: MediaQuery.of(context).size.height,
                      fit: BoxFit.cover,
                    ),
                    Image.asset(
                      'assets/images/signUp.png',
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.5,
                      fit: BoxFit.contain,
                    ),
                    // BgWithDottedBorders(
                    //   width: MediaQuery.of(context).size.width * 0.5,
                    //   height: MediaQuery.of(context).size.height,
                    // ),
                    // Positioned(
                    //     top: MediaQuery.of(context).size.height * 0.4,
                    //     child: HelloTextSectionForSIgnUp(
                    //       btnText: 'sign_up'.tr,
                    //       hello: "hello_signup".tr,
                    //       underHelloDisc: "under_hello_signup_description".tr,
                    //     ))
                  ],
                ),
              ],
            ),
      ),
    );
  }
}

class BgWithDottedBorders extends StatelessWidget {
  const BgWithDottedBorders({
    super.key,
    required this.width,
    required this.height,
  });
  final double width;
  final double height;
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Stack(
        children: [
          Container(width: width, height: height, color: Primary.primary),
          Positioned(
            left: -(width * 0.06),
            bottom: -(width * 0.11),
            child: DottedBorder(
              dashPattern: const [6, 10],
              color: Colors.white.withAlpha((0.8 * 255).toInt()),
              strokeWidth: 5,
              child: SizedBox(
                width: width * 0.2,
                height: width * 0.2,
                child: Center(
                  child: DottedBorder(
                    dashPattern: const [6, 10],
                    color: Colors.white.withAlpha((0.8 * 255).toInt()),
                    strokeWidth: 4,
                    child: SizedBox(width: width * 0.13, height: width * 0.13),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -(width * 0.06),
            top: -(width * 0.11),
            child: DottedBorder(
              dashPattern: const [6, 10],
              color: Colors.white.withAlpha((0.8 * 255).toInt()),
              strokeWidth: 5,
              child: SizedBox(
                width: width * 0.2,
                height: width * 0.2,
                child: Center(
                  child: DottedBorder(
                    dashPattern: const [6, 10],
                    color: Colors.white.withAlpha((0.8 * 255).toInt()),
                    strokeWidth: 4,
                    child: SizedBox(width: width * 0.13, height: width * 0.13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class HelloTextSectionForSIgnUp extends StatelessWidget {
  const HelloTextSectionForSIgnUp({
    super.key,
    required this.hello,
    required this.underHelloDisc,
    required this.btnText,
  });
  final String hello;
  final String underHelloDisc;
  final String btnText;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          hello.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Primary.p0,
          ),
        ),
        gapH16,
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.25,
          child: Text(
            underHelloDisc,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Primary.p0),
          ),
        ),
        gapH16,
        InkWell(
          onTap: () {},
          child: Container(
            // padding: EdgeInsets.all(5),
            width: 100,
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Primary.p0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                btnText,
                style: TextStyle(fontSize: 12, color: Primary.p0),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SignForm extends StatefulWidget {
  const SignForm({super.key, required this.isDesktop});
  final bool isDesktop;

  @override
  State<SignForm> createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  final focus = FocusNode();
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.1,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.isDesktop ? const SizedBox() : gapH32,
            Text(
              "sign_in".tr.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Primary.black,
              ),
            ),

            gapH16,
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.25
                      : MediaQuery.of(context).size.width * 0.8,
              child: Text(
                "under_sign_in".tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Primary.underDescription),
              ),
            ),
            gapH56,
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.65,
              child: TextFormField(
                onFieldSubmitted: (value) {
                  FocusScope.of(context).requestFocus(focus);
                },
                controller: emailController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "email".tr,
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 25, 5),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  errorStyle: const TextStyle(fontSize: 10.0),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(width: 1, color: Colors.red),
                  ),
                ),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'email is required';
                  } else if (!value.trim().isValidEmail) {
                    return 'Invalid email';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    email = value;
                  });
                },
              ),
            ),
            gapH16,
            SizedBox(
              width:
                  widget.isDesktop
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.65,
              child: TextFormField(
                focusNode: focus,
                onFieldSubmitted: (value) async {
                  if (_formKey.currentState!.validate()) {
                    var res = await login(email, password);
                    if (res['success'] == true) {
                      if (res['data']['user']['roles'][0] == 'super-admin') {
                        CommonWidgets.snackBar('error', 'error'.tr);
                      } else {
                        await saveUserInfoLocally(
                          res['data']['accessToken'],
                          '${res['data']['user']['id']}',
                          res['data']['user']['email'],
                          res['data']['user']['name'],
                          '${res['data']['user']['company']['id']}',
                          '${res['data']['user']['company']['name']}',
                        );
                        // print('object ${res['data']['companySettings']}');
                        if (res['data']['companySettings'].isNotEmpty) {
                          // print('object');print(res['data']['companySettings']);
                          await saveCompanySettingsLocally(
                            '${res['data']['companySettings']['costCalculationType'] ?? ''}',
                            '${res['data']['companySettings']['showQuantitiesOnPos'] ?? ''}',
                            res['data']['companySettings']['logo'] ?? '',
                            res['data']['companySettings']['fullCompanyName'] ??
                                '',
                            res['data']['companySettings']['email'] ?? '',
                            res['data']['companySettings']['vat'] ?? '0',
                            res['data']['companySettings']['mobileNumber'] ?? '',
                            res['data']['companySettings']['phoneNumber'] ?? '',
                            res['data']['companySettings']['trn'] ?? '',
                            res['data']['companySettings']['bankInfo'] ?? '',
                            res['data']['companySettings']['address'] ?? '',
                            res['data']['companySettings']['phoneCode'] ?? '',
                            res['data']['companySettings']['mobileCode'] ?? '',
                            res['data']['companySettings']['localPayments'] ?? '',
                            res['data']['companySettings']['primaryCurrency']['name'] ??
                                'USD',
                            '${res['data']['companySettings']['primaryCurrency']['id'] ?? ''}',
                            '${res['data']['companySettings']['primaryCurrency']['symbol'] ?? ''}',
                            '${res['data']['companySettings']['companySubjectToVat'] ?? '1'}',
                            res['data']['companySettings']['posCurrency']['name'] ??
                                'USD',
                            '${res['data']['companySettings']['posCurrency']['id'] ?? ''}',
                            '${res['data']['companySettings']['posCurrency']['symbol'] ?? ''}',
                            '${res['data']['companySettings']['showLogoOnPos'] ?? '0'}',
                          );
                        }
                        await saveDefaultWarehouseInfoLocally(
                          '${res['data']['defaultWarehouse']['id']}',
                          res['data']['defaultWarehouse']['name'],
                          res['data']['defaultWarehouse']['warehouse_number'],
                          res['data']['defaultWarehouse']['address'] ?? '',
                        );
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const WelcomeScreen();
                            },
                          ),
                        );
                      }
                    } else {
                      // ignore: use_build_context_synchronously
                      CommonWidgets.snackBar('error', res['message']);
                    }
                  }
                },
                controller: passwordController,
                cursorColor: Colors.black,
                obscureText: !showPassword,
                decoration: InputDecoration(
                  hintText: "password".tr,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: Icon(
                      showPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: 23,
                    ),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 25, 5),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black.withAlpha((0.1 * 255).toInt()),
                      width: 1,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                  ),
                  errorStyle: const TextStyle(fontSize: 10.0),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    borderSide: BorderSide(width: 1, color: Colors.red),
                  ),
                ),
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return 'password is required';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
              ),
            ),
            gapH56,
            Text(
              "forget_password".tr,
              style: TextStyle(
                fontSize: 16,
                color: Primary.underDescription,
                decoration: TextDecoration.underline,
                decorationColor: Primary.underDescription,
              ),
            ),
            gapH16,
            ReusableButtonWithColor(
              btnText: "sign_in".tr,
              width: 100,
              height: 35,
              onTapFunction: () async {
                if (_formKey.currentState!.validate()) {
                  var res = await login(email, password);
                  if (res['success'] == true) {
                    if (res['data']['user']['roles'][0] == 'super-admin') {
                      CommonWidgets.snackBar('error', 'error'.tr);
                    } else {
                      await saveUserInfoLocally(
                        res['data']['accessToken'],
                        '${res['data']['user']['id']}',
                        res['data']['user']['email'],
                        res['data']['user']['name'],
                        '${res['data']['user']['company']['id']}',
                        '${res['data']['user']['company']['name']}',
                      );
                      // print('object ${res['data']['companySettings']}');
                      if (res['data']['companySettings'].isNotEmpty) {
                        // print('object');print(res['data']['companySettings']);
                        await saveCompanySettingsLocally(
                          '${res['data']['companySettings']['costCalculationType'] ?? ''}',
                          '${res['data']['companySettings']['showQuantitiesOnPos'] ?? ''}',
                          res['data']['companySettings']['logo'] ?? '',
                          res['data']['companySettings']['fullCompanyName'] ??
                              '',
                          res['data']['companySettings']['email'] ?? '',
                          res['data']['companySettings']['vat'] ?? '0',
                          res['data']['companySettings']['mobileNumber'] ?? '',
                          res['data']['companySettings']['phoneNumber'] ?? '',
                          res['data']['companySettings']['trn'] ?? '',
                          res['data']['companySettings']['bankInfo'] ?? '',
                          res['data']['companySettings']['address'] ?? '',
                          res['data']['companySettings']['phoneCode'] ?? '',
                          res['data']['companySettings']['mobileCode'] ?? '',
                          res['data']['companySettings']['localPayments'] ?? '',
                          res['data']['companySettings']['primaryCurrency']['name'] ??
                              'USD',
                          '${res['data']['companySettings']['primaryCurrency']['id'] ?? ''}',
                          '${res['data']['companySettings']['primaryCurrency']['symbol'] ?? ''}',
                          '${res['data']['companySettings']['companySubjectToVat'] ?? '1'}',
                          res['data']['companySettings']['posCurrency']['name'] ??
                              'USD',
                          '${res['data']['companySettings']['posCurrency']['id'] ?? ''}',
                          '${res['data']['companySettings']['posCurrency']['symbol'] ?? ''}',
                          '${res['data']['companySettings']['showLogoOnPos'] ?? '0'}',
                        );
                      }
                      await saveDefaultWarehouseInfoLocally(
                        '${res['data']['defaultWarehouse']['id']}',
                        res['data']['defaultWarehouse']['name'],
                        res['data']['defaultWarehouse']['warehouse_number'],
                        res['data']['defaultWarehouse']['address'] ?? '',
                      );
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return const WelcomeScreen();
                          },
                        ),
                      );
                    }
                  } else {
                    // ignore: use_build_context_synchronously
                    CommonWidgets.snackBar('error', res['message']);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
