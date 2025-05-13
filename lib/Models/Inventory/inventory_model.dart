

class InventoryItem {
  int? id;
  // Company? company;
  Warehouses? warehouse;
  ItemType? itemType;
  String? mainCode;
  String? itemName;
  int? showOnPos;
  Category? category;
  int? printMainCode;
  num? taxation;
  TaxationGroup? taxationGroup;
  List<ItemGroups>? itemGroups;
  // Null? lastCurrency;
  ItemType? subrefId;
  int? canBeSold;
  int? canBePurchased;
  int? warranty;
  // Null? lastAllowedPurchaseDate;
  String? shortDescription;
  String? mainDescription;
  // Null? secondLanguageDescription;
  List<SupplierCodes>? supplierCodes;
  // List<AlternativeCodes>? alternativeCodes;
  List<Barcode>? barcode;
  num? unitCost;
  num? decimalCost;
  Currency? currency;
  Currency? priceCurrency;
  Currency? posCurrency;
  num? quantity; // i updated this value
  String? totalQuantities;
  List<Warehouses>? warehouses;
  String? currentQuantity;
  // String? soldQuantity;
  num? unitPrice;
  num? decimalPrice;
  num? lineDiscountLimit;
  int? packageType;
  String? packageName;
  int? defaultTransactionPackageType;
  String? packageUnitName;
  // Null? packageUnitQuantity;
  String? packageSetName;
  String? packageSetQuantity;
  String? packageSupersetName;
  String? packageSupersetQuantity;
  String? packagePaletteName;
  String? packagePaletteQuantity;
  String? packageContainerName;
  String? packageContainerQuantity;
  num? decimalQuantity;
  int? active;
  List<String>? images;

  InventoryItem(
      {this.id,
        // this.company,
        this.warehouse,
        this.itemType,
        this.mainCode,
        this.itemName,
        this.showOnPos,
        this.category,
        this.printMainCode,
        this.taxation,
        this.taxationGroup,
        this.itemGroups,
        // this.lastCurrency,
        this.subrefId,
        this.canBeSold,
        this.canBePurchased,
        this.warranty,
        // this.lastAllowedPurchaseDate,
        this.shortDescription,
        this.mainDescription,
        // this.secondLanguageDescription,
        this.supplierCodes,
        // this.alternativeCodes,
        this.barcode,
        this.unitCost,
        this.decimalCost,
        this.currency,
        this.priceCurrency,
        this.posCurrency,
        this.quantity,
        this.totalQuantities,
        this.warehouses,
        this.currentQuantity,
        // this.soldQuantity,
        this.unitPrice,
        this.decimalPrice,
        this.lineDiscountLimit,
        this.packageType,
        this.packageName,
        this.defaultTransactionPackageType,
        this.packageUnitName,
        // this.packageUnitQuantity,
        this.packageSetName,
        this.packageSetQuantity,
        this.packageSupersetName,
        this.packageSupersetQuantity,
        this.packagePaletteName,
        this.packagePaletteQuantity,
        this.packageContainerName,
        this.packageContainerQuantity,
        this.decimalQuantity,
        this.active,
        this.images});

  InventoryItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    // company =
    // json['company'] != null ? new Company.fromJson(json['company']) : null;
    warehouse = json['warehouse'];
    itemType = json['itemType'] != null
        ? ItemType.fromJson(json['itemType'])
        : null;
    mainCode = json['mainCode'];
    itemName = json['item_name'];
    showOnPos = json['showOnPos'];
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    printMainCode = json['printMainCode'];
    taxation = json['taxation'];
    taxationGroup = json['taxationGroup'] != null
        ? TaxationGroup.fromJson(json['taxationGroup'])
        : null;
    if (json['itemGroups'] != null) {
      itemGroups = <ItemGroups>[];
      json['itemGroups'].forEach((v) {
        itemGroups!.add(ItemGroups.fromJson(v));
      });
    }
    // lastCurrency = json['lastCurrency'];
    subrefId = json['subref_id'] != null
        ? ItemType.fromJson(json['subref_id'])
        : null;
    canBeSold = json['canBeSold'];
    canBePurchased = json['canBePurchased'];
    warranty = json['warranty'];
    // lastAllowedPurchaseDate = json['lastAllowedPurchaseDate'];
    shortDescription = json['shortDescription'];
    mainDescription = json['mainDescription'];
    // secondLanguageDescription = json['secondLanguageDescription'];
    if (json['supplierCodes'] != null) {
      supplierCodes = <SupplierCodes>[];
      json['supplierCodes'].forEach((v) {
        supplierCodes!.add(SupplierCodes.fromJson(v));
      });
    }
    // if (json['alternativeCodes'] != null) {
    //   alternativeCodes = <AlternativeCodes>[];
    //   json['alternativeCodes'].forEach((v) {
    //     alternativeCodes!.add(new AlternativeCodes.fromJson(v));
    //   });
    // }
    if (json['barcode'] != null) {
      barcode = <Barcode>[];
      json['barcode'].forEach((v) {
        barcode!.add(Barcode.fromJson(v));
      });
    }
    unitCost = json['unitCost'];
    decimalCost = json['decimalCost'];
    currency = json['currency'] != null
        ? Currency.fromJson(json['currency'])
        : null;
    priceCurrency = json['priceCurrency'] != null
        ? Currency.fromJson(json['priceCurrency'])
        : null;
    posCurrency = json['posCurrency'] != null
        ? Currency.fromJson(json['posCurrency'])
        : null;
    quantity = json['quantity'];
    totalQuantities = json['totalQuantities'];
    if (json['warehouses'] != null) {
      warehouses = <Warehouses>[];
      json['warehouses'].forEach((v) {
        warehouses!.add(Warehouses.fromJson(v));
      });
    }
    currentQuantity = json['current_quantity'];
    // soldQuantity = json['sold_quantity'];
    unitPrice = json['unitPrice'];
    decimalPrice = json['decimalPrice'];
    lineDiscountLimit = json['lineDiscountLimit'];
    packageType = json['packageType'];
    packageName = json['packageName'];
    defaultTransactionPackageType = json['defaultTransactionPackageType'];
    packageUnitName = json['packageUnitName'];
    // packageUnitQuantity = json['packageUnitQuantity'];
    packageSetName = json['packageSetName'];
    packageSetQuantity = json['packageSetQuantity'];
    // packageSupersetName = json['packageSupersetName'];
    // packageSupersetQuantity = json['packageSupersetQuantity'];
    // packagePaletteName = json['packagePaletteName'];
    // packagePaletteQuantity = json['packagePaletteQuantity'];
    // packageContainerName = json['packageContainerName'];
    // packageContainerQuantity = json['packageContainerQuantity'];
    decimalQuantity = json['decimalQuantity'];
    active = json['active'];
    images = json['images'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    // if (company != null) {
    //   data['company'] = company!.toJson();
    // }
    data['warehouse'] = warehouse;
    if (itemType != null) {
      data['itemType'] = itemType!.toJson();
    }
    data['mainCode'] = mainCode;
    data['item_name'] = itemName;
    data['showOnPos'] = showOnPos;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['printMainCode'] = printMainCode;
    data['taxation'] = taxation;
    if (taxationGroup != null) {
      data['taxationGroup'] = taxationGroup!.toJson();
    }
    if (itemGroups != null) {
      data['itemGroups'] = itemGroups!.map((v) => v.toJson()).toList();
    }
    // data['lastCurrency'] = this.lastCurrency;
    if (subrefId != null) {
      data['subref_id'] = subrefId!.toJson();
    }
    data['canBeSold'] = canBeSold;
    data['canBePurchased'] = canBePurchased;
    data['warranty'] = warranty;
    // data['lastAllowedPurchaseDate'] = this.lastAllowedPurchaseDate;
    data['shortDescription'] = shortDescription;
    data['mainDescription'] = mainDescription;
    // data['secondLanguageDescription'] = this.secondLanguageDescription;
    if (supplierCodes != null) {
      data['supplierCodes'] =
          supplierCodes!.map((v) => v.toJson()).toList();
    }
    // if (this.alternativeCodes != null) {
    //   data['alternativeCodes'] =
    //       this.alternativeCodes!.map((v) => v.toJson()).toList();
    // }
    if (barcode != null) {
      data['barcode'] = barcode!.map((v) => v.toJson()).toList();
    }
    data['unitCost'] = unitCost;
    data['decimalCost'] = decimalCost;
    if (currency != null) {
      data['currency'] = currency!.toJson();
    }
    if (priceCurrency != null) {
      data['priceCurrency'] = priceCurrency!.toJson();
    }
    if (posCurrency != null) {
      data['posCurrency'] = posCurrency!.toJson();
    }
    data['quantity'] = quantity;
    data['totalQuantities'] = totalQuantities;
    if (warehouses != null) {
      data['warehouses'] = warehouses!.map((v) => v.toJson()).toList();
    }
    data['current_quantity'] = currentQuantity;
    // data['sold_quantity'] = soldQuantity;
    data['unitPrice'] = unitPrice;
    data['decimalPrice'] = decimalPrice;
    data['lineDiscountLimit'] = lineDiscountLimit;
    data['packageType'] = packageType;
    data['packageName'] = packageName;
    data['defaultTransactionPackageType'] = defaultTransactionPackageType;
    data['packageUnitName'] = packageUnitName;
    // data['packageUnitQuantity'] = this.packageUnitQuantity;
    data['packageSetName'] = packageSetName;
    data['packageSetQuantity'] = packageSetQuantity;
    // data['packageSupersetName'] = this.packageSupersetName;
    // data['packageSupersetQuantity'] = this.packageSupersetQuantity;
    // data['packagePaletteName'] = this.packagePaletteName;
    // data['packagePaletteQuantity'] = this.packagePaletteQuantity;
    // data['packageContainerName'] = this.packageContainerName;
    // data['packageContainerQuantity'] = this.packageContainerQuantity;
    data['decimalQuantity'] = decimalQuantity;
    data['active'] = active;
    data['images'] = images;
    return data;
  }
}


class ItemType {
  int? id;
  String? name;
  String? createdAt;
  String? updatedAt;

  ItemType({this.id, this.name, this.createdAt, this.updatedAt});

  ItemType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Category {
  int? id;
  int? companyId;
  String? categoryName;
  int? iLft;
  int? iRgt;
  // Null? parentId;
  // Null? deletedAt;
  String? createdAt;
  String? updatedAt;

  Category(
      {this.id,
        this.companyId,
        this.categoryName,
        this.iLft,
        this.iRgt,
        // this.parentId,
        // this.deletedAt,
        this.createdAt,
        this.updatedAt});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    categoryName = json['category_name'];
    iLft = json['_lft'];
    iRgt = json['_rgt'];
    // parentId = json['parent_id'];
    // deletedAt = json['deleted_at'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['company_id'] = companyId;
    data['category_name'] = categoryName;
    data['_lft'] = iLft;
    data['_rgt'] = iRgt;
    // data['parent_id'] = parentId;
    // data['deleted_at'] = deletedAt;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class TaxationGroup {
  int? id;
  int? companyId;
  String? code;
  String? name;
  int? active;
  String? createdAt;
  String? updatedAt;
  // Null? deletedAt;

  TaxationGroup(
      {this.id,
        this.companyId,
        this.code,
        this.name,
        this.active,
        this.createdAt,
        this.updatedAt,
        // this.deletedAt
      });

  TaxationGroup.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    code = json['code'];
    name = json['name'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['company_id'] = companyId;
    data['code'] = code;
    data['name'] = name;
    data['active'] = active;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    // data['deleted_at'] = deletedAt;
    return data;
  }
}

class ItemGroups {
  int? id;
  int? companyId;
  String? code;
  String? name;
  int? active;
  int? iLft;
  int? iRgt;
  int? parentId;
  String? createdAt;
  String? updatedAt;
  // Null? deletedAt;
  String? showName;
  Pivot? pivot;

  ItemGroups(
      {this.id,
        this.companyId,
        this.code,
        this.name,
        this.active,
        this.iLft,
        this.iRgt,
        this.parentId,
        this.createdAt,
        this.updatedAt,
        // this.deletedAt,
        this.showName,
        this.pivot});

  ItemGroups.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    code = json['code'];
    name = json['name'];
    active = json['active'];
    iLft = json['_lft'];
    iRgt = json['_rgt'];
    parentId = json['parent_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // deletedAt = json['deleted_at'];
    showName = json['show_name'];
    pivot = json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['company_id'] = companyId;
    data['code'] = code;
    data['name'] = name;
    data['active'] = active;
    data['_lft'] = iLft;
    data['_rgt'] = iRgt;
    data['parent_id'] = parentId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    // data['deleted_at'] = deletedAt;
    data['show_name'] = showName;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}

class Pivot {
  int? itemId;
  int? itemGroupId;

  Pivot({this.itemId, this.itemGroupId});

  Pivot.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    itemGroupId = json['item_group_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['item_group_id'] = itemGroupId;
    return data;
  }
}

class SupplierCodes {
  int? id;
  String? code;
  // Null? printCode;
  int? companyId;
  int? itemId;
  String? createdAt;
  String? updatedAt;
  // Null? deletedAt;

  SupplierCodes(
      {this.id,
        this.code,
        // this.printCode,
        this.companyId,
        this.itemId,
        this.createdAt,
        this.updatedAt,
        // this.deletedAt
      });

  SupplierCodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    // printCode = json['print_code'];
    companyId = json['company_id'];
    itemId = json['item_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    // data['print_code'] = printCode;
    data['company_id'] = companyId;
    data['item_id'] = itemId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    // data['deleted_at'] = deletedAt;
    return data;
  }
}

class Barcode {
  int? id;
  String? code;
  int? printCode;
  int? companyId;
  int? itemId;
  String? createdAt;
  String? updatedAt;
  // Null? deletedAt;

  Barcode(
      {this.id,
        this.code,
        this.printCode,
        this.companyId,
        this.itemId,
        this.createdAt,
        this.updatedAt,
        // this.deletedAt
      });

  Barcode.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    printCode = json['print_code'];
    companyId = json['company_id'];
    itemId = json['item_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // deletedAt = json['deleted_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['code'] = code;
    data['print_code'] = printCode;
    data['company_id'] = companyId;
    data['item_id'] = itemId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    // data['deleted_at'] = deletedAt;
    return data;
  }
}

class Currency {
  int? id;
  int? companyId;
  String? name;
  String? symbol;
  int? active;
  String? createdAt;
  // Null? updatedAt;
  // Null? deletedAt;
  String? latestRate;

  Currency(
      {this.id,
        this.companyId,
        this.name,
        this.symbol,
        this.active,
        this.createdAt,
        // this.updatedAt,
        // this.deletedAt,
        this.latestRate});

  Currency.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    companyId = json['company_id'];
    name = json['name'];
    symbol = json['symbol'];
    active = json['active'];
    createdAt = json['created_at'];
    // updatedAt = json['updated_at'];
    // deletedAt = json['deleted_at'];
    latestRate = json['latest_rate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['company_id'] = companyId;
    data['name'] = name;
    data['symbol'] = symbol;
    data['active'] = active;
    data['created_at'] = createdAt;
    // data['updated_at'] = updatedAt;
    // data['deleted_at'] = deletedAt;
    data['latest_rate'] = latestRate;
    return data;
  }
}

class Warehouses {
  String? warehouseNumber;
  String? name;
  String? qtyOnHand;
  String? type;
  QtyInDefaultPackaging? qtyInDefaultPackaging;
  Pivot2? pivot;

  Warehouses(
      {this.warehouseNumber, this.name, this.qtyOnHand, this.type, this.pivot});

  Warehouses.fromJson(Map<String, dynamic> json) {
    warehouseNumber = json['warehouse_number'];
    name = json['name'];
    qtyOnHand = json['qty_on_hand'];
    qtyInDefaultPackaging = json['qty_in_default_packaging'] != null
        ? QtyInDefaultPackaging.fromJson(json['qty_in_default_packaging'])
        : null;
    type = json['type'];
    pivot = json['pivot'] != null ? Pivot2.fromJson(json['pivot']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['warehouse_number'] = warehouseNumber;
    data['name'] = name;
    data['qty_on_hand'] = qtyOnHand;
    if (qtyInDefaultPackaging != null) {
      data['qty_in_default_packaging'] = qtyInDefaultPackaging!.toJson();
    }
    data['type'] = type;
    if (pivot != null) {
      data['pivot'] = pivot!.toJson();
    }
    return data;
  }
}


class QtyInDefaultPackaging {
  String? containerName;
  num? containerQty;
  String? paletteName;
  num? paletteQty;
  String? supersetName;
  num? supersetQty;
  String? setName;
  num? setQty;
  String? unitName;
  String? unitQty;

  QtyInDefaultPackaging(
      {this.containerName,
        this.containerQty,
        this.paletteName,
        this.paletteQty,
        this.supersetName,
        this.supersetQty,
        this.setName,
        this.setQty,
        this.unitName,
        this.unitQty});

  QtyInDefaultPackaging.fromJson(Map<String, dynamic> json) {
    containerName = json['containerName'];
    containerQty = json['containerQty'];
    paletteName = json['paletteName'];
    paletteQty = json['paletteQty'];
    supersetName = json['supersetName'];
    supersetQty = json['supersetQty'];
    setName = json['setName'];
    setQty = json['setQty'];
    unitName = json['unitName'];
    unitQty = json['unitQty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['containerName'] = containerName;
    data['containerQty'] = containerQty;
    data['paletteName'] = paletteName;
    data['paletteQty'] = paletteQty;
    data['supersetName'] = supersetName;
    data['supersetQty'] = supersetQty;
    data['setName'] = setName;
    data['setQty'] = setQty;
    data['unitName'] = unitName;
    data['unitQty'] = unitQty;
    return data;
  }
}



class Pivot2 {
  int? itemId;
  int? warehouseId;
  String? qtyOnHand;

  Pivot2({this.itemId, this.warehouseId, this.qtyOnHand});

  Pivot2.fromJson(Map<String, dynamic> json) {
    itemId = json['item_id'];
    warehouseId = json['warehouse_id'];
    qtyOnHand = json['qty_on_hand'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['item_id'] = itemId;
    data['warehouse_id'] = warehouseId;
    data['qty_on_hand'] = qtyOnHand;
    return data;
  }
}