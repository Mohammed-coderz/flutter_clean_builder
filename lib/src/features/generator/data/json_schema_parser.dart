import 'dart:convert';

import '../domain/schema_model.dart';
import 'dart_name_utils.dart';

class JsonSchemaParser {
  const JsonSchemaParser();

  SchemaModel parseResponse({
    required String modelName,
    required String jsonSource,
  }) {
    final decoded = _decodeMap(jsonSource);
    final payload = _extractPayload(decoded);
    final isList = payload is List;
    final source = isList ? _firstMap(payload) : payload;

    if (source is! Map<String, dynamic>) {
      return SchemaModel(name: modelName, fields: const []);
    }

    return SchemaModel(
      name: modelName,
      fields: _fieldsFromMap(source),
      isListResponse: isList,
    );
  }

  SchemaModel parseRequest({
    required String modelName,
    required String jsonSource,
  }) {
    final trimmed = jsonSource.trim();
    if (trimmed.isEmpty) {
      return SchemaModel(name: '${modelName}Request', fields: const []);
    }

    final decoded = _decodeMap(trimmed);
    return SchemaModel(
      name: '${modelName}Request',
      fields: _fieldsFromMap(decoded),
    );
  }

  Map<String, dynamic> _decodeMap(String jsonSource) {
    final decoded = jsonDecode(jsonSource.trim());
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException('JSON root must be an object.');
  }

  Object? _extractPayload(Map<String, dynamic> decoded) {
    for (final key in const ['data', 'result', 'items', 'records']) {
      final value = decoded[key];
      if (value is Map<String, dynamic> || value is List) return value;
    }

    final nestedData = decoded['data'];
    if (nestedData is Map<String, dynamic>) {
      for (final key in const ['result', 'items', 'records']) {
        final value = nestedData[key];
        if (value is Map<String, dynamic> || value is List) return value;
      }
    }

    return decoded;
  }

  Map<String, dynamic>? _firstMap(List<dynamic> values) {
    for (final value in values) {
      if (value is Map<String, dynamic>) return value;
    }
    return null;
  }

  List<SchemaField> _fieldsFromMap(Map<String, dynamic> source) {
    return source.entries.map((entry) {
      return SchemaField(
        name: DartNameUtils.camel(entry.key),
        jsonKey: entry.key,
        dartType: _inferType(entry.value),
        nullable: entry.value == null,
      );
    }).toList();
  }

  String _inferType(Object? value) {
    if (value == null) return 'String';
    if (value is int) return 'int';
    if (value is double) return 'double';
    if (value is num) return 'double';
    if (value is bool) return 'bool';
    if (value is List) return 'List<dynamic>';
    if (value is Map) return 'Map<String, dynamic>';
    return 'String';
  }
}
