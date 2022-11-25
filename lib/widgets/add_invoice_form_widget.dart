import 'dart:async';
import 'package:invoices/widgets/pdf_view_widget.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';
import 'package:pdfx/pdfx.dart';

class AddInvoiceFormWidget extends StatefulWidget {
  final Invoice? invoice;
  final List<Widget>? actions;

  AddInvoiceFormWidget({
    Key? key,
    this.invoice,
    this.actions,
  }) : super(key: key);

  @override
  AddInvoiceFormWidgetState createState() {
    return AddInvoiceFormWidgetState();
  }
}

class AddInvoiceFormWidgetState extends State<AddInvoiceFormWidget> {
  final _formKey = GlobalKey<FormState>();

  List<PlatformFile>? _paths = [];
  late final TextEditingController _grossAmountController;
  late final TextEditingController _netAmountController1;
  late final TextEditingController _businessPartnerController;
  late final TextEditingController _invoiceIdController;
  PdfController? pdfController;
  AutovalidateMode mode = AutovalidateMode.onUserInteraction;
  Color color = Colors.grey;
  int? vat;
  String? _filePath;
  Invoice? invoice;


  @override
  void initState() {
    super.initState();
    _grossAmountController = TextEditingController(text: widget.invoice?.grossAmount);
    _netAmountController1 = TextEditingController(
        text: widget.invoice?.netAmount
            .toString()); // widget.invoice?.netAmount != null ? widget.invoice?.netAmount.toString() : null);
    _businessPartnerController = TextEditingController(text: widget.invoice?.businessPartner);
    _invoiceIdController = TextEditingController(text: widget.invoice?.invoiceId);
    if (widget.invoice != null) {
      setState(() {
        vat = widget.invoice?.vat;
        _filePath = widget.invoice?.file!['path'];
        if (_filePath != null) {
          pdfController = PdfController(document: PdfDocument.openFile(_filePath!));
        }
      });
      invoice = Invoice(
          id: widget.invoice?.id,
          invoiceId: widget.invoice?.invoiceId,
          businessPartner: widget.invoice?.businessPartner,
          netAmount: widget.invoice?.netAmount,
          vat: widget.invoice?.vat,
          grossAmount: widget.invoice?.grossAmount,
          file: widget.invoice?.file);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _paths = null;
      _filePath = null;
    });
  }

  void _pickFiles() async {
    _resetState();
    _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']))?.files;
    setState(() {
      if (_formKey.currentState?.validate() == true) {
        setState(() {
          color = Colors.greenAccent;
        });
      }
      _filePath = _paths?.first.path;
      if (_filePath != null) {
        pdfController = PdfController(document: PdfDocument.openFile(_filePath!));
      }
    });
    if (!mounted) return;
  }

  String calculateVAT(String value) {
    double x = double.parse(value);
    double p = ((vat ?? 0) / 100);
    return (x + (x * p)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          actions: [
            if(widget.actions?.isNotEmpty == true) widget.actions!.reduce((value, element) => element),
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: buildSaveButton(context),
            )
          ],
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: mode,
          onChanged: () {
            if (_formKey.currentState?.validate() == true) {
              setState(() {
                color = Colors.greenAccent;
              });
            } else {
              setState(() {
                color = Colors.grey;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: ListView(children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _invoiceIdController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Invoice Id',
                  ),
                  validator: (value) {
                    if (!RegExp(r'^[a-zA-Z0-9_\-=@,.\s]+$').hasMatch(value!)) {
                      return 'Please enter invoice id';
                    } else if (double.tryParse(value) != null) {
                      return 'Value must not be a number';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _businessPartnerController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Business Partner',
                  ),
                  validator: (value) {
                    if (!RegExp(r'^[a-zA-Z0-9_\-=@,.\s]+$').hasMatch(value!) || value.isEmpty) {
                      return 'Please enter a business partner';
                    } else if (double.tryParse(value) != null) {
                      return 'Value must not be a number';
                    }
                    return null;
                  },
                ),
              ),
              IntrinsicHeight(
                child: Flex(
                  direction: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _netAmountController1,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Net amount',
                            errorStyle: TextStyle(height: 0.0),
                            contentPadding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 8),
                          ),
                          validator: (value) {
                            if (!RegExp(r'^[0-9.]+$').hasMatch(value!)) {
                              return 'Please enter net amount';
                            } else if (value == "0") {
                              return 'Net amount must be greater than 0';
                            }
                            return null;
                          },
                          onChanged: (String? value) {
                            if (value != null) {
                              setState(() {
                                _grossAmountController.text = calculateVAT(value);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField<int>(
                          alignment: AlignmentDirectional.topStart,
                          isExpanded: true,
                          value: vat,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Select VAT',
                          ),
                          validator: (value) {
                            if (value == null) {
                              return 'Please select VAT';
                            }
                            return null;
                          },
                          items: const [
                            DropdownMenuItem<int>(
                              value: 0,
                              child: Text("0%"),
                            ),
                            DropdownMenuItem<int>(
                              value: 7,
                              child: Text("7%"),
                            ),
                            DropdownMenuItem<int>(
                              value: 23,
                              child: Text("23%"),
                            )
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                vat = value;
                                _grossAmountController.text = calculateVAT(_netAmountController1.text);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _grossAmountController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Gross amount',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
              ),
              buildAttachFile(context)
            ]),
          ),
        ));
  }

  Widget buildSaveButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          minimumSize: MaterialStateProperty.all<Size>(const Size(100, 50)),
        ),
        onPressed: () async {
          if (color != Colors.grey) {
            if (_formKey.currentState!.validate() && _filePath != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
              setState(() {
                addOrUpdateInvoice(context);
                _paths = null;
                _formKey.currentState!.reset();
                _netAmountController1.text = '';
                _grossAmountController.text = '';
                _businessPartnerController.text = '';
                _invoiceIdController.text = '';
                mode = AutovalidateMode.disabled;
              });
            } else {
              setState(() {
                mode = AutovalidateMode.always;
              });
            }
          }
        },
        child: Row(
          children: const [
            Icon(Icons.save),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void addOrUpdateInvoice(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Your invoice has been saved"),
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.invoice != null;

      if (isUpdating) {
        await updateInvoice();
      } else {
        await addInvoice();
      }
    }
  }

  Future updateInvoice() async {
    final invoice = widget.invoice?.copy(
        id: widget.invoice!.id,
        invoiceId: _invoiceIdController.text,
        businessPartner: _businessPartnerController.text,
        vat: vat,
        netAmount: double.parse(_netAmountController1.text),
        grossAmount: _grossAmountController.text,
        file: widget.invoice?.file);
    invoice != null ? await InvoiceDatabase.instance.update(invoice) : null;
  }

  Future addInvoice() async {
    await InvoiceDatabase.instance.create(Invoice(
      invoiceId: _invoiceIdController.text,
      businessPartner: _businessPartnerController.text,
      vat: vat,
      netAmount: double.parse(_netAmountController1.text),
      grossAmount: _grossAmountController.text,
      file: _paths != null ? const PlatformFileSerializer().toJson(_paths!.first) : null,
    ));
  }

  Widget buildAttachFile(BuildContext context) => Column(
        children: [
          Flex(
            direction: Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Flexible(
                      child: IconButton(
                        iconSize: 40,
                        onPressed: () => _pickFiles(),
                        icon: const Icon(
                          Icons.add_box_outlined,
                        ),
                        // child: Text(_multiPick ? 'Pick files' : 'Pick file'),
                      ),
                    ),
                    Flexible(
                        flex: 2,
                        child: Text("Attach an invoice".replaceAll("", "\u{200B}"),
                            style: const TextStyle(overflow: TextOverflow.ellipsis)))
                  ],
                ),
              ),
              (widget.invoice != null && _filePath != null)
                  ? Flexible(
                      child: Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            child: SvgPicture.asset(
                              "assets/pdf-svgrepo-com.svg",
                              height: 40,
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Text(
                              widget.invoice?.file!['name']!.replaceAll("", "\u{200B}"),
                              style: const TextStyle(overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(),
            ],
          ),
          if (_filePath == null)
            Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: Row(
                children: [
                  Text(
                    "Please attach a file",
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ),
            ),
          if (_filePath != null)
            SizedBox(
              height: 600,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PdfViewPage(path: _filePath),
                  ),
                ),
                child: PdfView(
                  controller: pdfController!,
                ),
              ),
            ),
        ],
      );
}
