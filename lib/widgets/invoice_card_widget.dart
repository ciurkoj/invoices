import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InvoiceCardWidget extends StatelessWidget {
  final String invoiceId;
  final String businessPartner;
  final String netAmount;
  final String grossAmount;
  final String vat;
  final String svgPath;

  const InvoiceCardWidget({Key? key,
  required this.invoiceId,
  required this.businessPartner,
  required this.netAmount,
  required this.grossAmount,
  required this.vat,
  required this.svgPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  svgPath,
                  height: 40,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Invoice Id:\t\t\t\t $invoiceId", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text("Business Partner:\t\t\t\t$businessPartner", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                  Text("Net Amount:\t\t\t\t$netAmount", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                  Text("Gross Amount:\t\t\t\t$grossAmount", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                  Text("VAT:\t\t\t\t$vat", style: const TextStyle(color: Colors.black54, fontSize: 20)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
