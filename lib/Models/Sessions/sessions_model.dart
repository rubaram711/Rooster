

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
    primaryCurrencyTotal = json['primaryCurrencyTotal'];
    posCurrencyTotal = json['posCurrencyTotal'];
    primaryCurrencyTaxValue = json['primaryCurrencyTaxValue'];
    posCurrencyTaxValue = json['posCurrencyTaxValue'];
    primaryCurrencyDiscountValue = json['primaryCurrencyDiscountValue'];
    posCurrencyDiscountValue = json['posCurrencyDiscountValue'];
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
    data['primaryCurrencyTotal'] = primaryCurrencyTotal;
    data['posCurrencyTotal'] = posCurrencyTotal;
    data['primaryCurrencyTaxValue'] = primaryCurrencyTaxValue;
    data['posCurrencyTaxValue'] = posCurrencyTaxValue;
    data['primaryCurrencyDiscountValue'] = primaryCurrencyDiscountValue;
    data['posCurrencyDiscountValue'] = posCurrencyDiscountValue;
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
  num? usdAmount;
  num? otherCurrencyAmount;

  PaymentDetails(
      {this.cashingMethod, this.usdAmount, this.otherCurrencyAmount});

  PaymentDetails.fromJson(Map<String, dynamic> json) {
    cashingMethod = json['cashing_method'];
    usdAmount = json['usd_amount'];
    otherCurrencyAmount = json['other_currency_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cashing_method'] = cashingMethod;
    data['usd_amount'] = usdAmount;
    data['other_currency_amount'] = otherCurrencyAmount;
    return data;
  }
}