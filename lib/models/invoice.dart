import 'package:json_annotation/json_annotation.dart';

part "invoice.g.dart";

const String tableInvoice = 'invoices';

class InvoiceFields {
  static final List<String> values = [
    /// Add all fields
    id, invoiceId, businessPartner, netAmount, vat, grossAmount
  ];

  static const String id = '_id';
  static const String invoiceId = 'invoiceId';
  static const String businessPartner = 'businessPartner';
  static const String netAmount = 'netAmount';
  static const String vat = 'VAT';
  static const String grossAmount = 'grossAmount';
}

@JsonSerializable()
class Invoice {
  @JsonKey(name: '_id')
  final int? id;
  final String? invoiceId;
  final String businessPartner;
  final double? netAmount;
  @JsonKey(name: 'VAT')
  final int? vat;
  final String grossAmount;

  Invoice({
    this.id,
    this.invoiceId,
    required this.businessPartner,
    required this.netAmount,
    required this.vat,
    required this.grossAmount,
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
