import 'package:get/get.dart';

import '../Backend/get_currencies.dart';


class ExchangeRatesController extends GetxController {
  List exchangeRatesList = [];
  List currenciesList = [];
  bool isExchangeRatesFetched = false;
  List<String> currenciesNamesList = [];
  List<String> currenciesSymbolsList = [];
  List currenciesIdsList = [];
  getExchangeRatesListAndCurrenciesFromBack({bool withUsd=true}) async {
    exchangeRatesList = [];
    currenciesNamesList = [];
    currenciesSymbolsList = [];
    currenciesIdsList = [];
      isExchangeRatesFetched = false;
      // update();
      var p = await getCurrencies();
      if('$p' != '[]'){
        currenciesList=p['currencies'];
        currenciesList=currenciesList.reversed.toList();
        for (var c in p['currencies'] ) {
          if(withUsd){
            currenciesNamesList.add('${c['name']}');
            currenciesSymbolsList.add('${c['symbol']??'${c['name']}'}');
            currenciesIdsList.add('${c['id']}');
        }else{
            if (c['name'] != 'USD') {
              currenciesNamesList.add('${c['name']}');
              currenciesIdsList.add('${c['id']}');
            }
          }
      }
        exchangeRatesList=p['exchangeRates'];
        exchangeRatesList=exchangeRatesList.reversed.toList();
      }
      isExchangeRatesFetched = true;
      update();
  }


}
