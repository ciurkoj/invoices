import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:invoices/db/invoice_database.dart';
import 'package:invoices/models/invoice.dart';

class AddInvoiceFormPage extends StatefulWidget {
  final Invoice? invoice;

  const AddInvoiceFormPage({
    Key? key,
    this.invoice,
  }) : super(key: key);

  @override
  AddInvoiceFormPageState createState() {
    return AddInvoiceFormPageState();
  }
}

class AddInvoiceFormPageState extends State<AddInvoiceFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  List<PlatformFile>? _paths = [];
  late final TextEditingController _grossAmountController;
  late final TextEditingController _netAmountController1;
  late final TextEditingController _businessPartnerController;
  late final TextEditingController _invoiceIdController;
  int vat = 0;
  AutovalidateMode mode = AutovalidateMode.onUserInteraction;
  File? file;

  Color color = Colors.grey;

  bool isLoading = false;
  Invoice? invoice;

  @override
  void initState() {
    super.initState();
    _grossAmountController = TextEditingController(text: widget.invoice?.grossAmount);
    _netAmountController1 = TextEditingController(text: widget.invoice?.netAmount != null ? widget.invoice?.netAmount.toString() : "");
    _businessPartnerController = TextEditingController(text: widget.invoice?.businessPartner);
    _invoiceIdController = TextEditingController(text: widget.invoice?.invoiceId);
    vat = widget.invoice?.vat ?? 0;
    if (widget.invoice != null) {
      file = File(widget.invoice!.filePath);
      _paths?.add(PlatformFile(name: basename(file!.path), size: file!.lengthSync(), path: widget.invoice!.filePath));
      invoice = Invoice(
          id: widget.invoice!.id,
          invoiceId: widget.invoice!.invoiceId,
          businessPartner: widget.invoice!.businessPartner,
          netAmount: widget.invoice!.netAmount,
          vat: widget.invoice!.vat,
          grossAmount: widget.invoice!.grossAmount,
          filePath: widget.invoice!.filePath);
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
    });
  }

  void _logException(String message) {
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _pickFiles() async {
    _resetState();
    try {
      _paths = (await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']))?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation$e');
    } catch (e) {
      _logException(e.toString());
    }
    if (!mounted) return;
    setState(() {
      file = File(_paths!.first.path!);
    });
  }

  Future<File?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return null;
    return File(result.paths.first ?? '');
  }

  String calculateVAT(String value) {
    double x = double.parse(value);
    double p = (vat / 100);
    return (x + (x * p)).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          actions: [
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
            child: ListView(
              children: <Widget>[
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButtonFormField<int>(
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
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Row(
                            children: [
                              IconButton(
                                iconSize: 40,
                                onPressed: () => _pickFiles(),
                                icon: const Icon(
                                  Icons.add_box_outlined,
                                ),
                                // child: Text(_multiPick ? 'Pick files' : 'Pick file'),
                              ),
                              const Text("Attach an invoice")
                            ],
                          ),
                        ),
                        _paths?.isNotEmpty == true
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/pdf-svgrepo-com.svg",
                                      height: 40,
                                    ),
                                    Text(
                                      _paths!.first.name,
                                      style: const TextStyle(overflow: TextOverflow.ellipsis),
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  ],
                                ))
                            : Container(),
                      ],
                    ),
                    if (_paths?.isEmpty ?? mode == AutovalidateMode.always)
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
                      )
                  ],
                ),
              ],
            ),
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
            if (_formKey.currentState!.validate() && _paths != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
              setState(() {
                addOrUpdateInvoice(context);
                vat = 0;
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
      final isUpdating = invoice != null;

      if (isUpdating) {
        await updateInvoice();
      } else {
        await addInvoice();
      }
    }
  }

  Future updateInvoice() async {
    final minvoice = invoice!.copy(
      id: invoice!.id,
      invoiceId: _invoiceIdController.text,
      businessPartner: _businessPartnerController.text,
      vat: vat,
      netAmount: double.parse(_netAmountController1.text),
      grossAmount: _grossAmountController.text,
      filePath: file!.path,
    );
    await InvoiceDatabase.instance.update(minvoice);
  }

  Future addInvoice() async {
    await InvoiceDatabase.instance.create(Invoice(
      invoiceId: _invoiceIdController.text,
      businessPartner: _businessPartnerController.text,
      vat: vat,
      netAmount: double.parse(_netAmountController1.text),
      grossAmount: _grossAmountController.text,
      filePath: file!.path,
    ));
  }
}
