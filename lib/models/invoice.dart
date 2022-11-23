import 'package:json_annotation/json_annotation.dart';

part "invoice.g.dart";


@JsonSerializable()
class Invoice {
  final int? id;
  final String? invoiceId;
  final String businessPartner;
  final double? netAmount;
  final int vat;
  final String grossAmount;

  // final File attachment;

  Invoice({
    this.id,
    this.invoiceId,
    required this.businessPartner,
    required this.netAmount,
    required this.vat,
    required this.grossAmount,
    // this.attachment,
  });

  Invoice copy({
    int? id,
    String? invoiceId,
    String? businessPartner,
    double? netAmount,
    int? vat,
    String? grossAmount,
  }) =>
      Invoice(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        businessPartner: businessPartner ?? this.businessPartner,
        netAmount: netAmount ?? this.netAmount,
        vat: vat ?? this.vat,
        grossAmount: grossAmount ?? this.grossAmount,
      );

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}
