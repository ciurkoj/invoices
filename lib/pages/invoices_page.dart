import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:invoices/pages/add_invoice_form_page.dart';
import 'package:invoices/pages/invoice_detail_page.dart';
import 'package:invoices/widgets/invoice_card_widget.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  InvoicesPageState createState() => InvoicesPageState();
}

class InvoicesPageState extends State<InvoicesPage> {
  List<Invoice> invoices = [];
  List<Invoice> invoices1 = [];
  bool isLoading = false;
  String? searchByValue;

  TextEditingController editingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshInvoices();
  }

  @override
  void dispose() {
    InvoiceDatabase.instance.close();
    super.dispose();
  }

  Future refreshInvoices() async {
    setState(() => isLoading = true);
    invoices = await InvoiceDatabase.instance.readAllInvoices();
    invoices1 = await InvoiceDatabase.instance.readAllInvoices();
    setState(() => isLoading = false);
  }

  void filterSearchResults(String query) {
    List<Invoice> dummySearchList = <Invoice>[];
    dummySearchList.addAll(invoices);
    if (query.isNotEmpty) {
      List<Invoice> dummyListData = <Invoice>[];
      dummySearchList.forEach((item) {
        if (searchByValue == InvoiceFields.invoiceId) {
          if (item.invoiceId.contains(query)) {
            dummyListData.add(item);
          }
        } else if (searchByValue == InvoiceFields.businessPartner) {
          if (item.businessPartner.contains(query)) {
            dummyListData.add(item);
          }
        } else if (searchByValue == InvoiceFields.grossAmount) {
          if (item.grossAmount.contains(query)) {
            dummyListData.add(item);
          }
        } else {
          if (item.invoiceId.contains(query) || item.businessPartner.contains(query) || item.grossAmount.contains(query)) {
            dummyListData.add(item);
          }
        }
      });
      setState(() {
        invoices.clear();
        invoices.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        invoices.clear();
        invoices.addAll(invoices1);
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3B5570),
          title: const Text(
            'Invoices',
            style: TextStyle(fontSize: 24),
          ),
        ),
        body: Column(
          children: [
            buildSearchBar(),
            Expanded(
              child: Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : invoices.isEmpty
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
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddInvoiceFormPage()),
            );
            refreshInvoices();
          },
        ),
      );

  FutureOr onGoBack(dynamic value) {
    refreshInvoices();
    setState(() {});
  }

  Widget buildInvoices() => ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (BuildContext context, int index) {
          return OutlinedButton(
            onPressed: () async {
              await Navigator.of(context)
                  .push(
                    MaterialPageRoute(builder: (context) => InvoiceDetailPage(invoice: invoices[index])),
                  )
                  .then(onGoBack);
            },
            child: InvoiceCardWidget(
                highlighted: searchByValue,
                invoiceId: invoices[index].invoiceId,
                businessPartner: invoices[index].businessPartner,
                netAmount: invoices[index].netAmount.toString(),
                grossAmount: invoices[index].grossAmount,
                vat: invoices[index].vat.toString(),
                svgPath: "assets/pdf-svgrepo-com.svg"),
          );
        },
      );

  Widget buildSearchBar() {
    TextStyle style = TextStyle(overflow: TextOverflow.ellipsis);
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
