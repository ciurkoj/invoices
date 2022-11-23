import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:invoices/pages/add_invoice_form_page.dart';
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
        if (item.invoiceId!.contains(query)) {
          dummyListData.add(item);
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: const InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
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

  Widget buildInvoices() => ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (BuildContext context, int index) {
          return InvoiceCardWidget(
              invoiceId: invoices[index].invoiceId!,
              businessPartner: invoices[index].businessPartner,
              netAmount: invoices[index].netAmount.toString(),
              grossAmount: invoices[index].grossAmount,
              vat: invoices[index].vat.toString(),
              svgPath: "assets/pdf-svgrepo-com.svg");
        },
      );
}
