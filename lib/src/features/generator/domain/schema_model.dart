class SchemaModel {
  const SchemaModel({
    required this.name,
    required this.fields,
    this.isListResponse = false,
  });

  final String name;
  final List<SchemaField> fields;
  final bool isListResponse;
}

class SchemaField {
  const SchemaField({
    required this.name,
    required this.dartType,
    required this.jsonKey,
    required this.nullable,
  });

  final String name;
  final String dartType;
  final String jsonKey;
  final bool nullable;
}
