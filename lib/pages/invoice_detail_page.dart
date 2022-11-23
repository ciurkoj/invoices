import 'package:flutter/material.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:invoices/pages/add_invoice_form_page.dart';

class InvoiceDetailPage extends StatefulWidget {
  final Invoice invoice;

  const InvoiceDetailPage({
    Key? key,
    required this.invoice,
  }) : super(key: key);

  @override
  InvoiceDetailPageState createState() => InvoiceDetailPageState();
}

class InvoiceDetailPageState extends State<InvoiceDetailPage> {
  late Invoice invoice;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshInvoice();
  }

  Future refreshInvoice() async {
    setState(() => isLoading = true);

    invoice = await InvoiceDatabase.instance.readInvoice(widget.invoice.id!);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF3B5570),
          actions: [editButton(), deleteButton()],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(invoice.invoiceId),
                    Text(invoice.businessPartner),
                    Text(invoice.netAmount.toString()),
                    Text(invoice.grossAmount),
                    Text(invoice.vat.toString()),
                    Text(invoice.filePath.toString()),
                  ],
                )),
      );

  Widget editButton() => IconButton(
      icon: const Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;
        await Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (context) => AddInvoiceFormPage(
                invoice: invoice,
              ),
            ))
            .then((value) => refreshInvoice());
      });

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await InvoiceDatabase.instance.delete(widget.invoice.id!);

          Navigator.of(context).pop();
        },
      );
}
