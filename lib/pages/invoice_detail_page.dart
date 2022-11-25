import 'package:flutter/material.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:invoices/widgets/add_invoice_form_widget.dart';

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
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : AddInvoiceFormWidget(
                invoice: invoice,
                actions: [deleteButton()],
              ),
      );

  Widget deleteButton() => IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () async {
          await InvoiceDatabase.instance.delete(widget.invoice.id!);

          Navigator.of(context).pop();
        },
      );
}
