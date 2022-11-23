import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:invoices/pages/add_invoice_form_page.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  InvoicesPageState createState() => InvoicesPageState();
}

class InvoicesPageState extends State<InvoicesPage> {
  List<Invoice> invoices = [];
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
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            'Invoices',
            style: TextStyle(fontSize: 24),
          ),
        ),
        body: Column(
          children: [
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
          backgroundColor: Colors.black,
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
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent), borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(
                        "assets/pdf-svgrepo-com.svg",
                        height: 40,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Invoice Id:\t\t\t\t${invoices[index].invoiceId!}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        Text("Business Partner:\t\t\t\t${invoices[index].businessPartner}", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                        Text("Net Amount:\t\t\t\t${invoices[index].netAmount.toString()}", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                        Text("Gross Amount:\t\t\t\t${invoices[index].grossAmount}", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                        Text("VAT:\t\t\t\t${invoices[index].vat.toString()}", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}
