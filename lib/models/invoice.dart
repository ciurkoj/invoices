import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:json_annotation/json_annotation.dart';

const String tableInvoice = 'invoices';

class InvoiceFields {
  static final List<String> values = [
    /// Add all fields
    id, invoiceId, businessPartner, netAmount, vat, grossAmount, file
  ];

  static const String id = '_id';
  static const String invoiceId = 'invoiceId';
  static const String businessPartner = 'businessPartner';
  static const String netAmount = 'netAmount';
  static const String vat = 'VAT';
  static const String grossAmount = 'grossAmount';
  static const String file = 'file';
}

@JsonSerializable()
class Invoice {
  @JsonKey(name: '_id')
  final int? id;
  final String? invoiceId;
  final String? businessPartner;
  final double? netAmount;
  @JsonKey(name: 'VAT')
  final double? vat;
  final String? grossAmount;
  final Map<String, dynamic>? file;

  Invoice({this.id, this.invoiceId, this.businessPartner, this.netAmount, this.vat = 0, this.grossAmount, this.file});

  Invoice copy({
    int? id,
    String? invoiceId,
    String? businessPartner,
    double? netAmount,
    double? vat,
    String? grossAmount,
    Map<String, dynamic>? file,
  }) =>
      Invoice(
          id: id ?? this.id,
          invoiceId: invoiceId ?? this.invoiceId,
          businessPartner: businessPartner ?? this.businessPartner,
          netAmount: netAmount ?? this.netAmount,
          vat: vat ?? this.vat,
          grossAmount: grossAmount ?? this.grossAmount,
          file: file ?? this.file);

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['_id'] as int?,
        invoiceId: json['invoiceId'] as String?,
        businessPartner: json['businessPartner'] as String?,
        netAmount: (json['netAmount'] as num?)?.toDouble(),
        vat: json['VAT'] as double? ?? 0 ,
        grossAmount: json['grossAmount'] as String?,
        file: jsonDecode(json['file']) as Map<String, dynamic>?,
      );

  Map<String, dynamic> toJson(Invoice instance) => <String, dynamic>{
        '_id': instance.id,
        'invoiceId': instance.invoiceId,
        'businessPartner': instance.businessPartner,
        'netAmount': instance.netAmount,
        'VAT': instance.vat,
        'grossAmount': instance.grossAmount,
        'file': jsonEncode(instance.file),
      };
}

