// ignore_for_file: unused_local_variable

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rooster_app/Binding/binding.dart';
import 'package:rooster_app/translation/localization/localization.dart';
import 'Controllers/home_controller.dart';
import 'Locale_Memory/save_user_info_locally.dart';
import 'Screens/Authorization/sign_up_screen.dart';
import 'Screens/welcome_screen.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

var id = '';
getInfoFromPref() async {
  id = await getIdFromPref();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await getInfoFromPref();
  runApp(const MyApp());
  // runApp(
  //     DevicePreview(
  //       enabled: !kReleaseMode,
  //       builder: (context) => const MyApp(), // Wrap your app
  //     ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.put(HomeController());
    return ScreenUtilInit(
      designSize: const Size(1600, 729),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialBinding: MyBinding(),
          scrollBehavior: MyCustomScrollBehavior(),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
            useMaterial3: true,
            textTheme: GoogleFonts.openSansTextTheme(
              Theme.of(context).textTheme.copyWith(
                bodyLarge: TextStyle(fontSize: 12.sp),
                bodyMedium: TextStyle(fontSize: 12.sp),
                bodySmall: TextStyle(fontSize: 12.sp),
                displayLarge: TextStyle(fontSize: 12.sp),
                displayMedium: TextStyle(fontSize: 12.sp),
                displaySmall: TextStyle(fontSize: 12.sp),
                headlineLarge: TextStyle(fontSize: 12.sp),
                headlineMedium: TextStyle(fontSize: 12.sp),
                headlineSmall: TextStyle(fontSize: 12.sp),
                titleLarge: TextStyle(fontSize: 12.sp),
                titleMedium: TextStyle(fontSize: 12.sp),
                titleSmall: TextStyle(fontSize: 12.sp),
                labelLarge: TextStyle(fontSize: 12.sp),
                labelMedium: TextStyle(fontSize: 12.sp),
                labelSmall: TextStyle(fontSize: 12.sp),
              ), //// Apply Open Sans to all text
            ),
          ),
          localizationsDelegates: const [
            quill.FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('ar'), // Arabic
          ],
          translations: AppLocalization(),
          locale: const Locale('en'),
          fallbackLocale: const Locale('en'),
          useInheritedMediaQuery: true,
          home: id != '' ? const WelcomeScreen() : const SignUpScreen(),
        );
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
