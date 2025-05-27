

class SessionOrder {
  String? orderNumber;
  num? primaryCurrencyTotal;
  num? primaryCurrencyTaxValue;
  num? posCurrencyTotal;
  num? posCurrencyTaxValue;
  num? primaryCurrencyDiscountValue;
  num? posCurrencyDiscountValue;
  num? received;
  List<PaymentDetails>? paymentDetails;
  String? openedAt;
  String? closedAt;
  num? selectedCurrTotal;
  num? selectedCurrTaxTotal;
  num? selectedCurrDiscountTotal;
  num? receivedOtherCurrency;

  SessionOrder(
      {this.orderNumber,
        this.primaryCurrencyTotal,
        this.primaryCurrencyTaxValue,
        this.posCurrencyTotal,
        this.posCurrencyTaxValue,
        this.primaryCurrencyDiscountValue,
        this.posCurrencyDiscountValue,
        this.received,
        this.paymentDetails,
        this.openedAt,
        this.closedAt,
        this.selectedCurrTotal,
        this.selectedCurrTaxTotal,
        this.selectedCurrDiscountTotal,
        this.receivedOtherCurrency});

  SessionOrder.fromJson(Map<String, dynamic> json) {
    orderNumber = json['order_number'];
    primaryCurrencyTotal = json['primary_currency_total'];
    posCurrencyTotal = json['pos_currency_total'];
    primaryCurrencyTaxValue = json['primary_currency_tax_value'];
    posCurrencyTaxValue = json['pos_currency_tax_value'];
    primaryCurrencyDiscountValue = json['primary_currency_discount_value'];
    posCurrencyDiscountValue = json['pos_currency_discount_value'];
    received = json['received'];
    receivedOtherCurrency = json['receivedOtherCurrency'];
    openedAt = json['opened_at'];
    closedAt = json['closed_at'];
    selectedCurrTotal = json['selectedCurrTotal'];
    selectedCurrTaxTotal = json['selectedCurrTaxTotal'];
    selectedCurrDiscountTotal = json['selectedCurrDiscountTotal'];
    if (json['payment_details'] != null) {
      paymentDetails = <PaymentDetails>[];
      json['payment_details'].forEach((v) {
        paymentDetails!.add( PaymentDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_number'] = orderNumber;
    data['primary_currency_total'] = primaryCurrencyTotal;
    data['pos_currency_total'] = posCurrencyTotal;
    data['primary_currency_tax_value'] = primaryCurrencyTaxValue;
    data['pos_currency_tax_value'] = posCurrencyTaxValue;
    data['primary_currency_discount_value'] = primaryCurrencyDiscountValue;
    data['pos_currency_discount_value'] = posCurrencyDiscountValue;
    data['received'] = received;
    data['receivedOtherCurrency'] = receivedOtherCurrency;
    data['opened_at'] = openedAt;
    data['closed_at'] = closedAt;
    data['selectedCurrTotal'] = selectedCurrTotal;
    data['selectedCurrTaxTotal'] = selectedCurrTaxTotal;
    data['selectedCurrDiscountTotal'] = selectedCurrDiscountTotal;
    if (paymentDetails != null) {
      data['payment_details'] =
          paymentDetails!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class PaymentDetails {
  String? cashingMethod;
  num? primaryCurrencyAmount;
  num? posCurrencyAmount;

  PaymentDetails(
      {this.cashingMethod, this.primaryCurrencyAmount, this.posCurrencyAmount});

  PaymentDetails.fromJson(Map<String, dynamic> json) {
    cashingMethod = json['cashing_method'];
    primaryCurrencyAmount = json['primary_currency_amount'];
    posCurrencyAmount = json['pos_currency_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cashing_method'] = cashingMethod;
    data['primary_currency_amount'] = primaryCurrencyAmount;
    data['pos_currency_amount'] = posCurrencyAmount;
    return data;
  }
}