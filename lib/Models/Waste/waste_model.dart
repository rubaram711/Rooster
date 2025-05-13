class WasteModel {
  String? itemCode;
  String? itemDescription;
  String? sales;
  String? waste;
  String? qtyOnHand;
  String? replenishedQty;
  String? beginQuantity;

  WasteModel(
      {this.itemCode,
        this.itemDescription,
        this.sales,
        this.waste,
        this.qtyOnHand,
        this.replenishedQty,
        this.beginQuantity});

  WasteModel.fromJson(Map<String, dynamic> json) {
    itemCode = json['itemCode'];
    itemDescription = json['itemDescription'];
    sales = json['sales'];
    waste = json['waste'];
    qtyOnHand = json['qtyOnHand'];
    replenishedQty = json['replenishedQty'];
    beginQuantity = json['BeginQuantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['itemCode'] = itemCode;
    data['itemDescription'] = itemDescription;
    data['sales'] = sales;
    data['waste'] = waste;
    data['qtyOnHand'] = qtyOnHand;
    data['replenishedQty'] = replenishedQty;
    data['BeginQuantity'] = beginQuantity;
    return data;
  }
}