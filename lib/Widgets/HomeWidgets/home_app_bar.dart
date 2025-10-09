
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rooster_app/Controllers/discounts_controller.dart';
import 'package:rooster_app/Controllers/inventory_controller.dart';
import 'package:rooster_app/Controllers/sales_order_controller.dart';
import 'package:rooster_app/Screens/Configuration/currencies_and_rates.dart';
import 'package:rooster_app/Screens/Configuration/terms_and_conditions.dart';
import 'package:rooster_app/const/sizes.dart';
import '../../Controllers/cash_trays_controller.dart';
import '../../Controllers/cashing_methods_controller.dart';
import '../../Controllers/categories_controller.dart';
import '../../Controllers/client_controller.dart';
import '../../Controllers/combo_controller.dart';
import '../../Controllers/company_settings_controller.dart';
import '../../Controllers/delivery_controller.dart';
import '../../Controllers/delivery_terms_controller.dart';
import '../../Controllers/exchange_rates_controller.dart';
import '../../Controllers/garage_controller.dart';
import '../../Controllers/groups_controller.dart';
import '../../Controllers/home_controller.dart';
import '../../Controllers/pending_docs_review_controller.dart';
import '../../Controllers/pos_controller.dart';
import '../../Controllers/price_list_controller.dart';
import '../../Controllers/products_controller.dart';
import '../../Controllers/quotation_controller.dart';
import '../../Controllers/roles_and_permissions_controller.dart';
import '../../Controllers/sales_invoice_controller.dart';
import '../../Controllers/session_controller.dart';
import '../../Controllers/settings_controller.dart';
import '../../Controllers/task_controller.dart';
import '../../Controllers/taxation_controller.dart';
import '../../Controllers/terms_and_conditions_controller.dart';
import '../../Controllers/transfer_controller.dart';
import '../../Controllers/users_controller.dart';
import '../../Controllers/warehouse_controller.dart';
import '../../Controllers/languages_controller.dart';
import '../../Controllers/waste_reports_controller.dart';
import '../../Locale_Memory/save_header_2_locally.dart';
import '../../Locale_Memory/save_user_info_locally.dart';
import '../../Screens/Authorization/sign_up_screen.dart';
import '../../Screens/Configuration/cashing_method.dart';
import '../../Screens/Configuration/categories_dialog.dart';
import '../../Screens/Configuration/delivery_terms.dart';
import '../../Screens/Configuration/discounts_dialog.dart';
import '../../Screens/Configuration/groups_dialog.dart';
import '../../Screens/Configuration/payment_terms.dart';
import '../../Screens/Configuration/price_lists_dialog.dart';
import '../../Screens/Configuration/salesmen_dialog.dart';
import '../../Screens/Configuration/settings_content.dart';
import '../../Screens/Configuration/sup_references_dialog.dart';
import '../../Screens/Configuration/taxation_groups_dialog.dart';
import '../../Screens/Configuration/warehouses_dialog.dart';
import '../../Screens/DocsReview/docs_review.dart';
import '../../const/colors.dart';

class AppBarEntry {
  const AppBarEntry(this.title, this.route,
      [this.children = const <AppBarEntry>[]]);
  final String title;
  final String route;
  final List<AppBarEntry> children;
}

// Data to display.
const List<AppBarEntry> data = <AppBarEntry>[
  // AppBarEntry(
  //   'orders',
  //   "/",
  // ),
  // AppBarEntry(
  //   'To invoice',
  //   "/",
  // ),
  AppBarEntry(
    'products',
    "/",
  ),
  AppBarEntry(
    'configuration',
    "/",
    <AppBarEntry>[
      AppBarEntry('discounts', '/discounts'),
      AppBarEntry('currencies_and_rates', '/currencies_and_rates'),
      AppBarEntry('cashing_methods', '/cashing_methods'),
      AppBarEntry('taxation_groups', '/taxation_groups'),
      // AppBarEntry('sub_references', '/sub_references'),
      AppBarEntry('categories', '/categories'),
      AppBarEntry('groups', '/groups'),
      AppBarEntry('payment_terms', '/payment_terms'),
      AppBarEntry('delivery_terms', '/delivery_terms'),
      AppBarEntry('terms_and_conditions', '/terms_and_conditions'),
      // AppBarEntry('salesmen', '/salesmen'),
      // AppBarEntry('warehouses', '/warehouses'),
      AppBarEntry('price_lists', '/price_lists'),
      AppBarEntry('settings', '/settings'),
    ],
  ),
];

Map configDialogs = {
  'discounts': const DiscountsDialogContent(),
  'currencies_and_rates': const CurrenciesAndRatesDialogContent(),
  'cashing_methods': const CashingMethodsDialogContent(),
  'taxation_groups': const TaxationGroupsDialogContent(),
  'sub_references': const SubReferencesDialogContent(),
  'categories': const CategoriesDialogContent(),
  'groups': const GroupsDialogContent(),
  'payment_terms': const PaymentTermsDialogContent(),
  'delivery_terms': const DeliveryTermsDialogContent(),
  'salesmen': const SalesmenDialogContent(),
  'warehouses': const WarehousesDialogContent(),
  'price_lists': const PriceListDialogContent(),
  'terms_and_conditions': const TermsAndConditionsDialogContent(),
  'settings': const SettingsContent(),
};

class AppBarItem extends StatelessWidget {
  const AppBarItem(this.entry, {super.key, required this.context});

  final AppBarEntry entry;
  final BuildContext context;
  Widget _buildTiles(AppBarEntry root) {
    GlobalKey accKey = GlobalKey();
    final HomeController homeController = Get.find();
    if (root.children.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        child: InkWell(
          key: accKey,
          hoverColor: Colors.white,
          onTap: () {
            // if (val == true) {
            final RenderBox renderBox =
                accKey.currentContext?.findRenderObject() as RenderBox;
            final Size size = renderBox.size;
            final Offset offset = renderBox.localToGlobal(Offset.zero);
            showMenu(
              context: context,
              color: Colors.white, //TypographyColor.menuBg,
              surfaceTintColor: Colors.white,
              // shadowColor: Primary.p20,
              // shape: const RoundedRectangleBorder(
              //   side: BorderSide(color: Colors.black26),
              //   borderRadius: BorderRadius.all(
              //     Radius.circular(00.0),
              //   ),
              // ),
              position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + size.height + 15,
                  offset.dx + size.width,
                  offset.dy + size.height),
              items: root.children
                  .map((item) => PopupMenuItem<String>(
                        value: item.title.tr,
                        onTap: () {
                          showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    contentPadding: const EdgeInsets.all(0),
                                    titlePadding: const EdgeInsets.all(0),
                                    actionsPadding: const EdgeInsets.all(0),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(9)),
                                    ),
                                    elevation: 0,
                                    content: configDialogs[item.title],
                                  ));
                        },
                        padding: const EdgeInsets.fromLTRB(20, 5, 90, 5),
                        child: Text(
                          item.title.tr,
                        ),
                      ))
                  .toList(),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                root.title.tr,
                style:
                    TextStyle(fontSize: 15, color: TypographyColor.titleTable),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: TypographyColor.titleTable,
                size: 20,
              )

            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
      child: InkWell(
          focusColor: Colors.white,
          hoverColor: Colors.white,
          onTap: () {
            homeController.selectedTab.value = root.title;
          },
          child: Text(
            root.title,
            style: TextStyle(fontSize: 15, color: TypographyColor.titleTable),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTiles(entry);
  }
}

class HomeAppBarMenus extends StatefulWidget {
  const HomeAppBarMenus({super.key, required this.isDesktop});
  final bool isDesktop;
  @override
  State<HomeAppBarMenus> createState() => _HomeAppBarMenusState();
}

class _HomeAppBarMenusState extends State<HomeAppBarMenus> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.isDesktop
          ? MediaQuery.of(context).size.width * 0.4
          : MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.06,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        itemBuilder: (BuildContext context, int index) => AppBarItem(
          data[index],
          context: context,
        ),
        itemCount: data.length,
      ),
    );
  }
}

const List<AppBarEntry> adminList = <AppBarEntry>[
  AppBarEntry('logout', '/'),
];

class AdminSectionInHomeAppBar extends StatefulWidget {
  const AdminSectionInHomeAppBar({super.key});

  @override
  State<AdminSectionInHomeAppBar> createState() =>
      _AdminSectionInHomeAppBarState();
}

class _AdminSectionInHomeAppBarState extends State<AdminSectionInHomeAppBar> {
  var name = '';
  // var address= '';
  HomeController homeController=Get.find();
  getInfoFromPref() async {
    name = await getNameFromPref();
    var companyName = await getCompanyNameFromPref();
    var address = await getCompanyAddressFromPref();
    homeController.setCompanyName(companyName);
    homeController.setCompanyAddress(address);
    homeController.setName(name);
  }

  @override
  void initState() {
    getInfoFromPref();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey accKey = GlobalKey();
    return Row(
      children: [
        SizedBox(
            height: 31,
            width: 31,
            child: Image.asset('assets/images/notificationsIcon.png')),
        gapW16,
        Container(
          height: 31,
          width: 31,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(4)),
            image: DecorationImage(
              image: AssetImage('assets/images/adminPic.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        gapW10,
        InkWell(
          key: accKey,
          hoverColor: Colors.white,
          onTap: () {
            // if (val == true) {
            final RenderBox renderBox =
                accKey.currentContext?.findRenderObject() as RenderBox;
            final Size size = renderBox.size;
            final Offset offset = renderBox.localToGlobal(Offset.zero);
            showMenu(
              context: context,
              color: Colors.white, //TypographyColor.menuBg,
              surfaceTintColor: Colors.white,
              // shadowColor: Primary.p20,
              // shape: const RoundedRectangleBorder(
              //   side: BorderSide(color: Colors.black26),
              //   borderRadius: BorderRadius.all(
              //     Radius.circular(00.0),
              //   ),
              // ),
              position: RelativeRect.fromLTRB(
                  offset.dx,
                  offset.dy + size.height + 15,
                  offset.dx + size.width,
                  offset.dy + size.height),
              items: adminList
                  .map((item) => PopupMenuItem<String>(
                        onTap: () async {
                          // Navigator.pushReplacement(context, MaterialPageRoute(
                          //     builder: (BuildContext context) {
                          //   return const SignUpScreen();
                          // }));

                          await saveUserInfoLocally('', '', '', '', '','','','','');
                          await saveCompanySettingsLocally('', '','','','', '','','', '','','',);
                          await saveHeader1Locally('', '','', '', '', '', '','','','','','','','','' ,'','' );
                          await saveHeader2Locally('', '','', '', '', '', '','','','','','','','','','','' );

                          // Get.reset();

                          emailController.clear();
                          passwordController.clear();

                          Get.reload<LanguagesController>();
                          Get.reload<HomeController>();
                          Get.reload<ProductController>();
                          Get.reload<CategoriesController>();
                          Get.reload<QuotationController>();
                          Get.reload<TransferController>();
                          Get.reload<PosController>();
                          Get.reload<CashingMethodsController>();
                          Get.reload<WarehouseController>();
                          Get.reload<ExchangeRatesController>();
                          Get.reload<UsersController>();
                          Get.reload<ClientController>();
                          Get.reload<RolesAndPermissionsController>();
                          Get.reload<GroupsController>();
                          Get.reload<SessionController>();
                          Get.reload<InventoryController>();
                          Get.reload<SalesOrderController>();
                          Get.reload<ComboController>();
                          Get.reload<DiscountsController>();
                          Get.reload<TaxationGroupsController>();
                          Get.reload<SalesInvoiceController>();
                          Get.reload<GarageController>();
                          Get.reload<DeliveryTermsController>();
                          Get.reload<TermsAndConditionsController>();
                          Get.reload<DeliveryController>();
                          Get.reload<DocsReview>();
                          Get.reload<PendingDocsReviewController>();
                          Get.reload<CashTraysController>();
                          Get.reload<WasteReportsController>();
                          Get.reload<PriceListController>();
                          Get.reload<TaskController>();
                          Get.reload<CompanySettingsController>();
                          Get.reload<SettingsController>();



                          Get.offAll(() => const SignUpScreen());
                          // Get.delete<LanguagesController>(force: true);
                          // Get.delete<HomeController>(force: true);
                          // Get.delete<ProductController>(force: true);
                          // Get.delete<CategoriesController>(force: true);
                          // Get.delete<QuotationController>(force: true);
                          // Get.delete<TransferController>(force: true);
                          // Get.delete<PosController>(force: true);
                          // Get.delete<CashingMethodsController>(force: true);
                          // Get.delete<WarehouseController>(force: true);
                          // Get.delete<ExchangeRatesController>(force: true);
                          // Get.delete<UsersController>(force: true);
                          // Get.delete<ClientController>(force: true);
                          // Get.delete<RolesAndPermissionsController>(force: true);
                          // Get.delete<GroupsController>(force: true);
                          // Get.delete<SessionController>(force: true);
                          // Get.delete<InventoryController>(force: true);
                          // Get.delete<SalesOrderController>(force: true);
                          // Get.delete<ComboController>(force: true);
                          //
                          // Get.put(LanguagesController());
                          // Get.put(HomeController());
                          // Get.put(ProductController());
                          // Get.put(CategoriesController());
                          // Get.put(QuotationController());
                          // Get.put(TransferController());
                          // Get.put(PosController());
                          // Get.put(CashingMethodsController());
                          // Get.put(WarehouseController());
                          // Get.put(ExchangeRatesController());
                          // Get.put(UsersController());
                          // Get.put(ClientController());
                          // Get.put(RolesAndPermissionsController());
                          // Get.put(GroupsController());
                          // Get.put(SessionController());
                          // Get.put(InventoryController());
                          // Get.put(SalesOrderController());
                          // Get.put(ComboController());

                        },
                        value: item.title.tr,
                        padding: const EdgeInsets.fromLTRB(20, 5, 90, 5),
                        child: Text(
                          item.title.tr,
                        ),
                      ))
                  .toList(),
            );
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GetBuilder<HomeController>(
                builder: (cont) {
                  return Text(
                    cont.companyName,
                    style:
                        TextStyle(fontSize: 15, color: TypographyColor.titleTable),
                  );
                }
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: TypographyColor.titleTable,
                size: 20,
              )
            ],
          ),
        ),
        gapW16,
      ],
    );
  }
}

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find();
    var maxWidth = MediaQuery.of(context).size.width * 0.21;
    var minWidth = MediaQuery.of(context).size.width * 0.045;
    return Obx(() {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        height: MediaQuery.of(context).size.height * 0.06,
        width: homeController.isOpened.value
            ? MediaQuery.of(context).size.width - maxWidth
            : MediaQuery.of(context).size.width - minWidth,
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            HomeAppBarMenus(isDesktop: true),
            AdminSectionInHomeAppBar()
          ],
        ),
      );
    });
  }
}
