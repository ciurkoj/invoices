import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:json_annotation/json_annotation.dart';

class PlatformFileSerializer implements JsonConverter<PlatformFile, Map<String, dynamic>> {
  const PlatformFileSerializer();

  @override
  PlatformFile fromJson(Map<String, dynamic> json) => PlatformFile(
    path: json['path'] as String,
    name: json['name'] as String,
    size: int.parse(json['size']),
    bytes: json["bytes"] != null ? Uint8List.fromList(json['bytes']) : null,
    readStream: json['readStream'] as Stream<List<int>>?,
    identifier: json['identifier'] as String?,
  );

  @override
  Map<String, dynamic> toJson(PlatformFile instance) => <String, dynamic>{
    "path": instance.path != null ? "${instance.path}" : null,
    "name": instance.name != null ? "${instance.name}" : null,
    "size": instance.size != null ? "${instance.size}" : null,
    "bytes": instance.bytes != null ? "${instance.bytes}" : null,
    "readStream": instance.readStream != null ? "${instance.readStream}" : null,
    "identifier": instance.identifier != null ? "${instance.identifier}" : null,
  };
}
