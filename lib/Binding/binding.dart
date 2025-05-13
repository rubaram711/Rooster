import 'package:get/get.dart';
import 'package:rooster_app/Controllers/company_settings_controller.dart';
import 'package:rooster_app/Controllers/discounts_controller.dart';
import 'package:rooster_app/Controllers/products_controller.dart';
import 'package:rooster_app/Controllers/task_controller.dart';
import 'package:rooster_app/Controllers/users_controller.dart';
import 'package:rooster_app/Controllers/warehouse_controller.dart';
import 'package:rooster_app/Controllers/cashing_methods_controller.dart';
import 'package:rooster_app/Controllers/categories_controller.dart';
import 'package:rooster_app/Controllers/client_controller.dart';
import 'package:rooster_app/Controllers/exchange_rates_controller.dart';
import 'package:rooster_app/Controllers/groups_controller.dart';
import 'package:rooster_app/Controllers/inventory_controller.dart';
import 'package:rooster_app/Controllers/pos_controller.dart';
import 'package:rooster_app/Controllers/price_list_controller.dart';
import 'package:rooster_app/Controllers/quotation_controller.dart';
import 'package:rooster_app/Controllers/quotations_controller.dart';
import 'package:rooster_app/Controllers/roles_and_permissions_controller.dart';
import 'package:rooster_app/Controllers/session_controller.dart';
import 'package:rooster_app/Controllers/settings_controller.dart';
import 'package:rooster_app/Controllers/transfer_controller.dart';
import 'package:rooster_app/Controllers/waste_reports_controller.dart';
import 'package:rooster_app/Controllers/LanguagesController.dart';

import '../Controllers/combo_controller.dart';
import '../Controllers/payment_terms_controller.dart';
import '../Controllers/salesOrder_Controller.dart';
import '../Controllers/taxation_controller.dart';


class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguagesController>(() => LanguagesController());
    Get.lazyPut<DiscountsController>(() => DiscountsController());
    Get.lazyPut<TaxationGroupsController>(() => TaxationGroupsController());
    Get.lazyPut<ProductController>(() => ProductController());
    Get.lazyPut<CategoriesController>(() => CategoriesController());
    Get.lazyPut<QuotationsController>(() => QuotationsController());
    Get.lazyPut<TransferController>(() => TransferController());
    Get.lazyPut<PosController>(() => PosController());
    Get.lazyPut<CashingMethodsController>(() => CashingMethodsController());
    Get.lazyPut<WarehouseController>(() => WarehouseController());
    Get.lazyPut<ExchangeRatesController>(() => ExchangeRatesController());
    Get.lazyPut<UsersController>(() => UsersController());
    Get.lazyPut<ClientController>(() => ClientController());
    Get.lazyPut<RolesAndPermissionsController>(() => RolesAndPermissionsController());
    Get.lazyPut<GroupsController>(() => GroupsController());
    Get.lazyPut<SessionController>(() => SessionController());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<InventoryController>(() => InventoryController());
    Get.lazyPut<CompanySettingsController>(() => CompanySettingsController());
    Get.lazyPut<TaskController>(() => TaskController());
    Get.lazyPut<QuotationController>(() => QuotationController());
    Get.lazyPut<PriceListController>(() => PriceListController());
    Get.lazyPut<WasteReportsController>(() => WasteReportsController());
    Get.lazyPut<PaymentTermsController>(() => PaymentTermsController());
    Get.lazyPut<SalesOrderController>(() => SalesOrderController());
    Get.lazyPut<ComboController>(() => ComboController());


    // LanguagesController languagesController=Get.put(LanguagesController());
    // ProductController productController=Get.put(ProductController());
    // CategoriesController categoriesController=Get.put(CategoriesController());
    // QuotationsController quotationsController=Get.put(QuotationsController());
    // TransferController transferController=Get.put(TransferController());
    // PosController posController=Get.put(PosController());
    // CashingMethodsController cashingMethodsController=Get.put(CashingMethodsController());
    // WarehouseController warehouseController=Get.put(WarehouseController());
    // ExchangeRatesController exchangeRatesController=Get.put(ExchangeRatesController());
    // UsersController usersController=Get.put(UsersController());
    // ClientController clientController=Get.put(ClientController());
    // RolesAndPermissionsController rolesController=Get.put(RolesAndPermissionsController());
    // GroupsController groupsController=Get.put(GroupsController());
    // SessionController sessionController=Get.put(SessionController());
    // InventoryController inventoryController=Get.put(InventoryController());
    // SettingsController settingsController=Get.put(SettingsController());
    // CompanySettingsController companySettingsController=Get.put(CompanySettingsController());
    // TaskController taskController=Get.put(TaskController());
    // QuotationController quotationController=Get.put(QuotationController());
    // PriceListController priceListController=Get.put(PriceListController());
    // WasteReportsController wasteReportsController=Get.put(WasteReportsController());
    // PaymentTermsController paymentTermsController=Get.put(PaymentTermsController());
  }
}