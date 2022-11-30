import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';

class InvoiceCN extends ChangeNotifier {
  InvoiceCN() {
    refreshInvoices();
  }

  List<Invoice> invoices = [];
  List<Invoice>? invoices1;
  var collection =
      FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).collection("invoices");

  Future<List<Invoice>> getInvoicesFromFirebase() async {
    QuerySnapshot querySnapshot = await collection.get();

    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();

    return allData.map((e) => Invoice.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future refreshInvoices() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    //not the best, but fast to implement offline mode support
    if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
      invoices = await getInvoicesFromFirebase();
      invoices1 = await getInvoicesFromFirebase();
    } else {
      invoices = await InvoiceDatabase.instance.readAllInvoices();
      invoices1 = await InvoiceDatabase.instance.readAllInvoices();
    }
    notifyListeners();
  }
}
