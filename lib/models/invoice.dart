import 'package:json_annotation/json_annotation.dart';

part "invoice.g.dart";

const String tableInvoice = 'invoices';

class InvoiceFields {
  static final List<String> values = [
    /// Add all fields
    id, invoiceId, businessPartner, netAmount, vat, grossAmount ,filePath
  ];

  static const String id = '_id';
  static const String invoiceId = 'invoiceId';
  static const String businessPartner = 'businessPartner';
  static const String netAmount = 'netAmount';
  static const String vat = 'VAT';
  static const String grossAmount = 'grossAmount';
  static const String filePath = 'filePath';
}

@JsonSerializable()
class Invoice {
  @JsonKey(name: '_id')
  final int? id;
  final String invoiceId;
  final String businessPartner;
  final double netAmount;
  @JsonKey(name: 'VAT')
  final int vat;
  final String grossAmount;
  final String filePath;

  Invoice({
    this.id,
    required this.invoiceId,
    required this.businessPartner,
    required this.netAmount,
    required this.vat,
    required this.grossAmount,
    required this.filePath,
  });

  Invoice copy({
    int? id,
    String? invoiceId,
    String? businessPartner,
    double? netAmount,
    int? vat,
    String? grossAmount,
    String? filePath,
  }) =>
      Invoice(
        id: id ?? this.id,
        invoiceId: invoiceId ?? this.invoiceId,
        businessPartner: businessPartner ?? this.businessPartner,
        netAmount: netAmount ?? this.netAmount,
        vat: vat ?? this.vat,
        grossAmount: grossAmount ?? this.grossAmount,
        filePath: filePath ?? this.filePath,
      );

  factory Invoice.fromJson(Map<String, dynamic> json) => _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);
}
