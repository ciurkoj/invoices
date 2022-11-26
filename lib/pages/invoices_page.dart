import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:invoices/change_notifiers/invoice_cn.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:invoices/widgets/add_invoice_form_widget.dart';
import 'package:invoices/pages/invoice_detail_page.dart';
import 'package:invoices/widgets/invoice_card_widget.dart';
import 'package:provider/provider.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  InvoicesPageState createState() => InvoicesPageState();
}

class InvoicesPageState extends State<InvoicesPage> {
  bool isLoading = false;
  String? searchByValue;

  TextEditingController editingController = TextEditingController();
  // InvoiceCN? invoiceCn;
  ValueNotifier<InvoiceCN> invoiceCn = ValueNotifier(InvoiceCN());

  @override
  void initState() {
    super.initState();
    InvoiceDatabase.init(reopen: true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // invoiceCn = Provider.of<InvoiceCN>(context);
      // invoiceCn.refreshInvoices();
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    InvoiceDatabase.instance.close();
    super.dispose();
  }

  // Future refreshInvoices() async {
  //   setState(() => isLoading = true);
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   //not the best, but fast to implement offline mode support
  //   if (connectivityResult == ConnectivityResult.mobile || connectivityResult == ConnectivityResult.wifi) {
  //     invoices = await getInvoicesFromFirebase();
  //     invoices1 = await getInvoicesFromFirebase();
  //   } else {
  //     invoices = await InvoiceDatabase.instance.readAllInvoices();
  //     invoices1 = await InvoiceDatabase.instance.readAllInvoices();
  //   }
  //   setState(() => isLoading = false);
  // }

  void filterSearchResults(String query) {
    List<Invoice> dummySearchList = <Invoice>[];
    if(invoiceCn!=null){
    dummySearchList.addAll(invoiceCn!.value.invoices);
    if (query.isNotEmpty) {
      List<Invoice> dummyListData = <Invoice>[];
      dummySearchList.forEach((item) {
        if (searchByValue == InvoiceFields.invoiceId) {
          if (item.invoiceId!.contains(query)) {
            dummyListData.add(item);
          }
        } else if (searchByValue == InvoiceFields.businessPartner) {
          if (item.businessPartner!.contains(query)) {
            dummyListData.add(item);
          }
        } else if (searchByValue == InvoiceFields.grossAmount) {
          if (item.grossAmount!.contains(query)) {
            dummyListData.add(item);
          }
        } else {
          if (item.invoiceId!.contains(query) ||
              item.businessPartner!.contains(query) ||
              item.grossAmount!.contains(query)) {
            dummyListData.add(item);
          }
        }
      });
      setState(() {
        invoiceCn!.value.invoices.clear();
        invoiceCn!.value.invoices.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        invoiceCn!.value.invoices.clear();
        invoiceCn!.value.invoices.addAll(invoiceCn!.value.invoices1);
      });
    }}
  }

  @override
  Widget build(BuildContext context) {
    invoiceCn?.value.refreshInvoices();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.exit_to_app))
        ],
        title: const Text(
          'Invoices',
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          ValueListenableBuilder(
              valueListenable: invoiceCn,
              builder: (context, value, widget) {
              return buildSearchBar();
            }
          ),
          Expanded(
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : invoiceCn != null && invoiceCn!.value.invoices.isEmpty
                  ? const Text(
                'No Invoices',
                style: TextStyle(color: Colors.white, fontSize: 24),
              )
                  : buildInvoices(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B5570),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context)
              .push(
            MaterialPageRoute(builder: (context) => AddInvoiceFormWidget()),
          )
              .then((value) {
            invoiceCn?.value.refreshInvoices();
            setState(() {});
          });
        },
      ),
    );
  }
  FutureOr onGoBack(dynamic value) {
    invoiceCn?.value.refreshInvoices();
    setState(() {});
  }

  Widget buildInvoices() => ListView.builder(
        itemCount: invoiceCn!.value.invoices.length,
        itemBuilder: (BuildContext context, int index) {
          return OutlinedButton(
            onPressed: () async {
              await Navigator.of(context)
                  .push(
                    MaterialPageRoute(builder: (context) => InvoiceDetailPage(invoice: invoiceCn!.value.invoices[index])),
                  )
                  .then(onGoBack);
            },
            child: invoiceCn != null ? InvoiceCardWidget(
                highlighted: searchByValue,
                invoiceId: invoiceCn!.value.invoices[index].invoiceId!,
                businessPartner: invoiceCn!.value.invoices[index].businessPartner!,
                netAmount: invoiceCn!.value.invoices[index].netAmount.toString(),
                grossAmount: invoiceCn!.value.invoices[index].grossAmount!,
                vat: invoiceCn!.value.invoices[index].vat.toString(),
                svgPath: "assets/pdf-svgrepo-com.svg") : const Center(child: CircularProgressIndicator(),),
          );
        },
      );

  Widget buildSearchBar() {
    TextStyle style = const TextStyle(overflow: TextOverflow.ellipsis);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: const BorderRadius.all(Radius.circular(25.0)),
        ),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Flexible(
              flex: 2,
              child: TextField(
                onTapOutside: (PointerDownEvent? event) {
                  FocusScope.of(context).unfocus();
                },
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                    ),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      style: BorderStyle.solid,
                    ),
                  ),
                  labelText: "Search",
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  // border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))
                ),
              ),
            ),
            Flexible(
              child: DropdownButtonHideUnderline(
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: searchByValue,
                  alignment: AlignmentDirectional.topCenter,
                  decoration: const InputDecoration.collapsed(
                    //   border: OutlineInputBorder(),
                    hintText: 'Search by',
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: "any",
                      child: Text("Any".replaceAll("", "\u{200B}"), style: style),
                    ),
                    DropdownMenuItem<String>(
                      value: InvoiceFields.invoiceId,
                      child: Text("Invoice Id".replaceAll("", "\u{200B}"), style: style),
                    ),
                    DropdownMenuItem<String>(
                      value: InvoiceFields.businessPartner,
                      child: Text("Business Partner".replaceAll("", "\u{200B}"), style: style),
                    ),
                    DropdownMenuItem<String>(
                      value: InvoiceFields.grossAmount,
                      child: Text("Gross Amount".replaceAll("", "\u{200B}"), style: style),
                    )
                  ],
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        searchByValue = value;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
