import 'package:flutter/material.dart';
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
  }

  @override
  void dispose() {
    super.dispose();
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
                            style: TextStyle(fontSize: 24),
                          )
                        : buildNotes(),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddInvoiceFormPage()),
            );
          },
        ),
      );

  Widget buildNotes() => ListView.builder(
        itemCount: invoices.length,
        itemBuilder: (BuildContext context, int index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Invoice Id:\t\t\t\t${invoices[index].invoiceId!}",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              Text("Business Partner:\t\t\t\t${invoices[index].businessPartner}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
              Text("Net Amount:\t\t\t\t${invoices[index].netAmount.toString()}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
              Text("Gross Amount:\t\t\t\t${invoices[index].grossAmount}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
              Text("VAT:\t\t\t\t${invoices[index].vat.toString()}", style: const TextStyle(color: Colors.white70, fontSize: 20)),
            ],
          );
        },
      );
}
