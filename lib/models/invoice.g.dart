// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      id: json['_id'] as int?,
      invoiceId: json['invoiceId'] as String,
      businessPartner: json['businessPartner'] as String,
      netAmount: (json['netAmount'] as num).toDouble(),
      vat: json['VAT'] as int,
      grossAmount: json['grossAmount'] as String,
      filePath: json['filePath'] as String,
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      '_id': instance.id,
      'invoiceId': instance.invoiceId,
      'businessPartner': instance.businessPartner,
      'netAmount': instance.netAmount,
      'VAT': instance.vat,
      'grossAmount': instance.grossAmount,
      'filePath': instance.filePath,
    };
