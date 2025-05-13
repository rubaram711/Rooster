import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../Backend/ClientsBackend/get_clients.dart';
import '../Backend/ClientsBackend/get_transactions.dart';


class ClientController extends GetxController {
  List accounts = [];
  bool isClientsFetched = false;
  List transactionsOrders = [];
  List transactionsQuotations = [];
  bool isTransactionsFetched = false;
  TextEditingController searchController = TextEditingController();
  String selectedClientId='';
  Map selectedClient={};
  String hoveredClientId='';
  setSelectedClientId(String value) {
    selectedClientId = value;
    update();
  }
  setSelectedClient(Map value) {
    selectedClient = value;
    update();
  }
  setHoveredClientId(String value) {
    hoveredClientId = value;
    update();
  }


  setIsClientsFetched(bool value) {
    isClientsFetched = value;
    update();
  }

  setAccounts(List value) {
    accounts = value;
    update();
  }
  setIsTransactionsFetched(bool value) {
    isTransactionsFetched = value;
    update();
  }

  setTransactionsOrders(List value) {
    transactionsOrders = value;
    update();
  }
  setTransactionsQuotations(List value) {
    transactionsQuotations = value;
    update();
  }

  removeFromAccounts(int index) {
    accounts.removeAt(index);
    update();
  }

  getAllClientsFromBack() async {
    accounts = [];
    isClientsFetched = false;
    var p = await getAllClients(searchController.text);

    accounts = p;
    // accounts = accounts.reversed.toList();
    isClientsFetched = true;
    update();
  }

  getTransactionsFromBack() async {
    transactionsOrders = [];
    transactionsQuotations = [];
    isTransactionsFetched = false;
    var p = await getClientsTransactions(searchController.text,selectedClientId);
    transactionsOrders= p['orders'];
    transactionsQuotations = p['quotations'];
    isTransactionsFetched = true;
    update();
  }
}
