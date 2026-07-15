import 'dart:convert';
import 'dart:html' as html;

import '../domain/api_generation_input.dart';

class BuilderSchemaIo {
  const BuilderSchemaIo();

  void downloadSchema(ApiGenerationInput input) {
    final bytes = utf8.encode(const JsonEncoder.withIndent('  ').convert(input.toJson()));
    final blob = html.Blob([bytes], 'application/json');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final fileName = '${_safeFileName(input.featureName)}.builder.json';

    html.AnchorElement(href: url)
      ..download = fileName
      ..style.display = 'none'
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  Future<ApiGenerationInput?> pickSchema() async {
    final uploadInput = html.FileUploadInputElement()..accept = '.json,application/json';
    uploadInput.click();

    await uploadInput.onChange.first;
    final file = uploadInput.files?.isNotEmpty == true ? uploadInput.files!.first : null;
    if (file == null) return null;

    final reader = html.FileReader()..readAsText(file);
    await reader.onLoad.first;

    final rawContent = reader.result?.toString();
    if (rawContent == null || rawContent.trim().isEmpty) return null;

    final decoded = jsonDecode(rawContent);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Schema file must contain a JSON object.');
    }

    return ApiGenerationInput.fromJson(decoded);
  }

  String _safeFileName(String value) {
    final cleaned = value.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9_\-]+'), '_');
    return cleaned.isEmpty ? 'builder_schema' : cleaned;
  }
}
