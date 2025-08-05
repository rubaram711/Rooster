// const String baseUrl='https://theravenstyle.com/api';
const String baseUrl='https://theravenstyle.com/rooster-backend/public/api';
// const String baseUrl='https://demo.theravenstyle.com/rooster-backend-local/public/api';//test version
const String baseImage='https://theravenstyle.com/rooster-backend/public/';


const kLoginUrl='$baseUrl/login';
const kOrdersUrl='$baseUrl/orders';
const kClientsTransactionsUrl='$baseUrl/clients/transactions';
const kClientUrl='$baseUrl/clients';
const kUpdateClientUrl='$baseUrl/clients/update';
const kGetFieldsForCreateClientUrl='$baseUrl/clients/create';
const kGetAllQuotationsUrl='$baseUrl/quotations';
const kStoreQuotationUrl='$baseUrl/quotations';
const kSendQuotationByEmailUrl='$baseUrl/quotations/email';
const kDeleteQuotationUrl='$baseUrl/quotations';
const kUpdateQuotation='$baseUrl/quotations/update';
const kGetFieldsForCreateQuotationUrl='$baseUrl/quotations/create';
const kGetAllProductsUrl='$baseUrl/items';
const kAddProductUrl='$baseUrl/items';
const kDeleteProductUrl='$baseUrl/items';
const kGetFieldsForCreateProductUrl='$baseUrl/items/create';
const kGetCategoriesUrl='$baseUrl/categories';
const kStoreCategoryUrl='$baseUrl/categories';
const kEditCategoryUrl='$baseUrl/categories';//id
const kDeleteCategoryUrl='$baseUrl/categories';//id
const kUploadProductImageUrl='$baseUrl/imgs';
const kUpdateProductImageUrl='$baseUrl/imgs/update';
const kDeleteProductImageUrl='$baseUrl/imgs/delete';
const kExchangeRateUrl='$baseUrl/config/exchange_rate';
const kGetCurrenciesUrl='$baseUrl/config/currencies';
const kAddCurrenciesUrl='$baseUrl/config/currencies';
const kUpdateCurrenciesUrl='$baseUrl/config/currencies';//id
const kDeleteCurrenciesUrl='$baseUrl/config/currencies';//id
const kAddDiscountsUrl='$baseUrl/config/discounts';
const kGetDiscountsUrl='$baseUrl/config/discounts';
const kDeleteDiscountsUrl='$baseUrl/config/discounts';
const kUpdateDiscountsUrl='$baseUrl/config/discounts';
const kAddTaxationGroupUrl='$baseUrl/config/tax-groups';
const kUpdateTaxationGroupUrl='$baseUrl/config/tax-groups';//id
const kDeleteTaxationGroupUrl='$baseUrl/config/tax-groups';//id
const kAddRateUrl='$baseUrl/config/tax-groups/rates';//id
const kEditQuantityUrl='$baseUrl/items/quantities';
const kGetQuantitiesUrl='$baseUrl/items/warehouseQty';
const kEditPriceUrl='$baseUrl/items/prices';
const kAddCashedMethodUrl='$baseUrl/config/cashing-methods';
const kDeleteCashedMethodUrl='$baseUrl/config/cashing-methods';
const kUpdateItemUrl='$baseUrl/items/update';
const kUpdateCashingMethodUrl='$baseUrl/config/cashing-methods/update'; //id
const kCreateWarehouseUrl='$baseUrl/warehouses';
const kGetWarehouseUrl='$baseUrl/warehouses';
const kDeleteWarehouseUrl='$baseUrl/warehouses';
const kUpdateWarehouseUrl='$baseUrl/warehouses'; //id
const kGetReplenishmentsDataForCreateUrl='$baseUrl/replenishments/create';
const kGetQTyOfItemInWarehouseUrl='$baseUrl/items/warehouseQty';
const kAddReplenishmentsUrl='$baseUrl/replenishments';
const kUpdateReplenishmentsUrl='$baseUrl/replenishments/update';
const kGetReplenishmentsUrl='$baseUrl/replenishments';
const kCreateTransferOutUrl='$baseUrl/transfers/create';
const kAddTransferOutUrl='$baseUrl/transfers';
const kGetTransfersUrl='$baseUrl/transfers';
const kTransferInUrl='$baseUrl/transfers/transfer-in';
const kCreatePosUrl='$baseUrl/pos/create';
const kGetPosUrl='$baseUrl/pos';
const kAddPosUrl='$baseUrl/pos';
const kDeletePosUrl='$baseUrl/pos';
const kUpdatePosUrl='$baseUrl/pos';
const kUsersUrl='$baseUrl/users';
const kCreateUsersUrl='$baseUrl/users/create';
const kGetGroupsUrl='$baseUrl/itemGroups';
const kStoreGroupUrl='$baseUrl/itemGroups';
const kUpdateGroupUrl='$baseUrl/itemGroups/update';
const kDeleteGroupUrl='$baseUrl/itemGroups/delete';
const kRoleUrl='$baseUrl/roles';
const kUpdateRoleUrl='$baseUrl/roles/update';//id
const kDeleteRoleUrl='$baseUrl/roles/delete';//id
const kGetAllRolesAndPermissionsUrl='$baseUrl/roles';
const kUpdateRolesAndPermissionsUrl='$baseUrl/roles/update-roles-permissions';
const kSessionsUrl='$baseUrl/sessions';
const kSessionsReportUrl='$baseUrl/sessions/report';
const kWasteReportUrl='$baseUrl/items/report';
const kOpenSessionIdUrl='$baseUrl/sessions/current-session';
const kGetInventoryDataUrl='$baseUrl/inventory/get-inventory-data';
const kInventoryUrl='$baseUrl/inventory';
const kSettingsUrl='$baseUrl/settings';
const kTasksUrl='$baseUrl/tasks';
const kPriceListUrl='$baseUrl/pricelists';
const kGetPriceListItemsUrl='$baseUrl/pricelists/items';
const kCreatePriceListUrl='$baseUrl/pricelists/create';
const kUpdatePriceListUrl='$baseUrl/pricelists/update';
const kCashTrayUrl='$baseUrl/trays';
const kGetCurrentCashTrayUrl='$baseUrl/current-tray';
const kCloseCashTrayUrl='$baseUrl/trays/close';//id
const kReportCashTrayUrl='$baseUrl/tray-report';//id
const kCreateCashTrayUrl='$baseUrl/trays/create';
const kSelectRoleUrl='$baseUrl/users/selectRole';

const kTermsAndConditionsUrl='$baseUrl/settings/terms/history';
const kAddTermsAndConditionsUrl='$baseUrl/settings/terms/add';




const kGetCountriesUrl='https://countriesnow.space/api/v0.1/countries/population';
const kGetCitiesOfASpecifiedCountryUrl='https://countriesnow.space/api/v0.1/countries/cities';


const kGetAllSalesOrderUrl = '$baseUrl/sales-orders';
const kGetFieldsForCreateSalesOrderUrl = '$baseUrl/sales-orders/create';
const kStoreSalesOrderUrl = '$baseUrl/sales-orders';
const kUpdateSalesOrder = '$baseUrl/sales-orders/update';


const testLoginUrl = '$baseUrl/login';
const testCombosUrl = '$baseUrl/combos';
const testGetFieldsForCreateComboUrl = '$baseUrl/combos/create';
const kStoreComboUrl = '$baseUrl/combos';
const kUpdateCombo = '$baseUrl/combos/update';

const kGetDocsReview = '$baseUrl/quotations/docs-review/get';


const kGetFieldsForCreateSalesInvoiceUrl = '$baseUrl/sales-invoices/create';
const kGetAllSalesInvoiceUrl = '$baseUrl/sales-invoices';
const kStoreSalesInvoiceUrl = '$baseUrl/sales-invoices';
const kUpdateSalesInvoiceUrl = '$baseUrl/sales-invoices/update';

// -------------------------------------------------------------------------------------
const kGetFieldsForCreateDeliveryUrl = '$baseUrl/deliveries/create';
const kStoreDeliveryUrl = '$baseUrl/deliveries';
const kGetAllDeliveriesUrl = '$baseUrl/deliveries';
const kUpdateDeliveryUrl = '$baseUrl/deliveries/update';
