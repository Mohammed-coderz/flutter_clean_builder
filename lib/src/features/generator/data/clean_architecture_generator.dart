import '../domain/api_generation_input.dart';
import '../domain/generated_file.dart';
import '../domain/schema_model.dart';
import 'dart_name_utils.dart';
import 'json_schema_parser.dart';

class CleanArchitectureGenerator {
  CleanArchitectureGenerator({
    JsonSchemaParser? parser,
  }) : _parser = parser ?? const JsonSchemaParser();

  final JsonSchemaParser _parser;

  List<GeneratedFile> generate(ApiGenerationInput input) {
    final featureSnake = DartNameUtils.snake(input.featureName);
    final featurePascal = DartNameUtils.pascal(input.featureName);
    final operations = input.resolvedEndpoints.map(_buildOperation).toList();
    final firstOperation = operations.first;
    final basePath = 'lib/features/$featureSnake';

    final files = <GeneratedFile>[];
    final addedPaths = <String>{};

    void addFile(String path, String content) {
      if (addedPaths.add(path)) {
        files.add(GeneratedFile(path: path, content: content));
      }
    }

    for (final operation in operations) {
      addFile(
        '$basePath/domain/entities/${operation.modelSnake}.dart',
        _entity(operation.responseSchema),
      );
      addFile(
        '$basePath/data/models/${operation.modelSnake}_model.dart',
        _model(operation.responseSchema),
      );

      if (operation.hasRequest) {
        addFile(
          '$basePath/data/models/${operation.requestSnake}.dart',
          _requestModel(operation.requestSchema),
        );
      }
    }

    addFile(
      '$basePath/data/datasources/${featureSnake}_remote_data_source.dart',
      _remoteDataSource(
        featurePascal: featurePascal,
        operations: operations,
      ),
    );
    addFile(
      '$basePath/domain/repositories/${featureSnake}_repository.dart',
      _repository(
        featurePascal: featurePascal,
        operations: operations,
      ),
    );
    addFile(
      '$basePath/data/repositories/${featureSnake}_repository_impl.dart',
      _repositoryImpl(
        featurePascal: featurePascal,
        featureSnake: featureSnake,
        operations: operations,
      ),
    );

    for (final operation in operations) {
      addFile(
        '$basePath/domain/usecases/${operation.operationSnake}_usecase.dart',
        _usecase(
          featurePascal: featurePascal,
          featureSnake: featureSnake,
          operation: operation,
        ),
      );
    }

    addFile(
      '$basePath/presentation/cubit/${featureSnake}_state.dart',
      _state(featurePascal),
    );
    addFile(
      '$basePath/presentation/cubit/${featureSnake}_cubit.dart',
      _cubit(
        featurePascal: featurePascal,
        featureSnake: featureSnake,
        operations: operations,
      ),
    );
    addFile(
      '$basePath/presentation/screens/${featureSnake}_screen.dart',
      _screen(
        input: input,
        featurePascal: featurePascal,
        featureSnake: featureSnake,
        operation: firstOperation,
        operations: operations,
      ),
    );

    return files;
  }

  _GeneratedOperation _buildOperation(ApiEndpointInput endpoint) {
    final modelPascal = DartNameUtils.pascal(endpoint.modelName);
    final operationPascal = DartNameUtils.pascal(endpoint.operationName);
    final responseSchema = _parser.parseResponse(
      modelName: modelPascal,
      jsonSource: endpoint.responseJson,
    );
    final requestSchema = _parser.parseRequest(
      modelName: operationPascal,
      jsonSource: endpoint.requestJson,
    );

    return _GeneratedOperation(
      endpoint: endpoint,
      responseSchema: responseSchema,
      requestSchema: requestSchema,
      modelPascal: modelPascal,
      modelSnake: DartNameUtils.snake(endpoint.modelName),
      operationCamel: DartNameUtils.camel(endpoint.operationName),
      operationPascal: operationPascal,
      operationSnake: DartNameUtils.snake(endpoint.operationName),
      requestSnake: '${DartNameUtils.snake(endpoint.operationName)}_request',
      hasRequest: requestSchema.fields.isNotEmpty,
      returnsList: responseSchema.isListResponse,
    );
  }

  String _entity(SchemaModel schema) {
    final buffer = StringBuffer()
      ..writeln('class ${schema.name} {')
      ..writeln('  const ${schema.name}({');

    for (final field in schema.fields) {
      buffer.writeln('    required this.${field.name},');
    }

    buffer
      ..writeln('  });')
      ..writeln();

    for (final field in schema.fields) {
      buffer.writeln('  final ${_fieldType(field)} ${field.name};');
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  String _model(SchemaModel schema) {
    final modelName = '${schema.name}Model';
    final modelSnake = DartNameUtils.snake(schema.name);
    final buffer = StringBuffer()
      ..writeln("import '../../domain/entities/$modelSnake.dart';")
      ..writeln()
      ..writeln('class $modelName extends ${schema.name} {')
      ..writeln('  const $modelName({');

    for (final field in schema.fields) {
      buffer.writeln('    required super.${field.name},');
    }

    buffer
      ..writeln('  });')
      ..writeln()
      ..writeln('  factory $modelName.fromJson(Map<String, dynamic> json) {')
      ..writeln('    return $modelName(');

    for (final field in schema.fields) {
      buffer.writeln("      ${field.name}: ${_fromJsonValue(field)},");
    }

    buffer
      ..writeln('    );')
      ..writeln('  }')
      ..writeln()
      ..writeln('  Map<String, dynamic> toJson() {')
      ..writeln('    return {');

    for (final field in schema.fields) {
      buffer.writeln("      '${field.jsonKey}': ${field.name},");
    }

    buffer
      ..writeln('    };')
      ..writeln('  }')
      ..writeln('}');

    return buffer.toString();
  }

  String _requestModel(SchemaModel schema) {
    final buffer = StringBuffer()
      ..writeln('class ${schema.name} {')
      ..writeln('  const ${schema.name}({');

    for (final field in schema.fields) {
      buffer.writeln('    required this.${field.name},');
    }

    buffer
      ..writeln('  });')
      ..writeln();

    for (final field in schema.fields) {
      buffer.writeln('  final ${_fieldType(field)} ${field.name};');
    }

    buffer
      ..writeln()
      ..writeln('  Map<String, dynamic> toJson() {')
      ..writeln('    return {');

    for (final field in schema.fields) {
      buffer.writeln("      '${field.jsonKey}': ${field.name},");
    }

    buffer
      ..writeln('    };')
      ..writeln('  }')
      ..writeln('}');

    return buffer.toString();
  }

  String _remoteDataSource({
    required String featurePascal,
    required List<_GeneratedOperation> operations,
  }) {
    final modelImports = operations
        .map((operation) => "import '../models/${operation.modelSnake}_model.dart';")
        .toSet()
        .join('\n');
    final requestImports = operations
        .where((operation) => operation.hasRequest)
        .map((operation) => "import '../models/${operation.requestSnake}.dart';")
        .toSet()
        .join('\n');
    final methodBlocks = operations.map(_remoteMethod).join('\n');

    return '''
import 'dart:convert';

import 'package:http/http.dart' as http;

$modelImports
${requestImports.isEmpty ? '' : '$requestImports\n'}class ${featurePascal}RemoteDataSource {
  ${featurePascal}RemoteDataSource({
    required this.client,
    required this.baseUrl,
    this.headers = const {},
  });

  final http.Client client;
  final String baseUrl;
  final Map<String, String> headers;

$methodBlocks

  Object? _extractPayload(Map<String, dynamic> body) {
    for (final key in const ['data', 'result', 'items', 'records']) {
      final value = body[key];
      if (value is Map<String, dynamic> || value is List) return value;
    }

    final data = body['data'];
    if (data is Map<String, dynamic>) {
      for (final key in const ['result', 'items', 'records']) {
        final value = data[key];
        if (value is Map<String, dynamic> || value is List) return value;
      }
    }

    return body;
  }
}
''';
  }

  String _remoteMethod(_GeneratedOperation operation) {
    final method = operation.endpoint.method.toUpperCase();
    final returnType = operation.modelReturnType(useModel: true);
    final requestParam = operation.hasRequest ? '${operation.requestSchema.name} request' : '';
    final requestBody = operation.hasRequest
        ? ",\n      body: jsonEncode(request.toJson()),"
        : '';
    final headers = operation.endpoint.requiresAuth
        ? "{...headers, 'Content-Type': 'application/json'}"
        : "{'Content-Type': 'application/json', ...headers}";

    return '''
  Future<$returnType> ${operation.operationCamel}($requestParam) async {
    final uri = Uri.parse('\$baseUrl${operation.endpoint.endpoint}');
    final response = await client.${method.toLowerCase()}(
      uri,
      headers: $headers$requestBody,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: \${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final payload = _extractPayload(body);
${operation.returnsList ? _listPayload(operation.modelPascal) : _objectPayload(operation.modelPascal)}
  }
''';
  }

  String _repository({
    required String featurePascal,
    required List<_GeneratedOperation> operations,
  }) {
    final entityImports = operations
        .map((operation) => "import '../entities/${operation.modelSnake}.dart';")
        .toSet()
        .join('\n');
    final requestImports = operations
        .where((operation) => operation.hasRequest)
        .map((operation) => "import '../../data/models/${operation.requestSnake}.dart';")
        .toSet()
        .join('\n');
    final methods = operations.map((operation) {
      return '  Future<${operation.modelReturnType()}> ${operation.operationCamel}(${operation.requestParameter()});';
    }).join('\n');

    return '''
$entityImports
${requestImports.isEmpty ? '' : '$requestImports\n'}abstract class ${featurePascal}Repository {
$methods
}
''';
  }

  String _repositoryImpl({
    required String featurePascal,
    required String featureSnake,
    required List<_GeneratedOperation> operations,
  }) {
    final entityImports = operations
        .map((operation) => "import '../../domain/entities/${operation.modelSnake}.dart';")
        .toSet()
        .join('\n');
    final requestImports = operations
        .where((operation) => operation.hasRequest)
        .map((operation) => "import '../models/${operation.requestSnake}.dart';")
        .toSet()
        .join('\n');
    final methods = operations.map((operation) {
      return '''
  @override
  Future<${operation.modelReturnType()}> ${operation.operationCamel}(${operation.requestParameter()}) {
    return remoteDataSource.${operation.operationCamel}(${operation.requestArgument()});
  }
''';
    }).join('\n');

    return '''
$entityImports
import '../../domain/repositories/${featureSnake}_repository.dart';
import '../datasources/${featureSnake}_remote_data_source.dart';
${requestImports.isEmpty ? '' : '$requestImports\n'}class ${featurePascal}RepositoryImpl implements ${featurePascal}Repository {
  const ${featurePascal}RepositoryImpl(this.remoteDataSource);

  final ${featurePascal}RemoteDataSource remoteDataSource;

$methods
}
''';
  }

  String _usecase({
    required String featurePascal,
    required String featureSnake,
    required _GeneratedOperation operation,
  }) {
    final requestImport = operation.hasRequest
        ? "\nimport '../../data/models/${operation.requestSnake}.dart';"
        : '';

    return '''
import '../entities/${operation.modelSnake}.dart';
import '../repositories/${featureSnake}_repository.dart';$requestImport

class ${operation.operationPascal}UseCase {
  const ${operation.operationPascal}UseCase(this.repository);

  final ${featurePascal}Repository repository;

  Future<${operation.modelReturnType()}> call(${operation.requestParameter()}) {
    return repository.${operation.operationCamel}(${operation.requestArgument()});
  }
}
''';
  }

  String _state(String featurePascal) {
    return '''
abstract class ${featurePascal}State {
  const ${featurePascal}State();
}

class ${featurePascal}Initial extends ${featurePascal}State {
  const ${featurePascal}Initial();
}

class ${featurePascal}Loading extends ${featurePascal}State {
  const ${featurePascal}Loading(this.operation);

  final String operation;
}

class ${featurePascal}Success extends ${featurePascal}State {
  const ${featurePascal}Success({
    required this.operation,
    required this.data,
  });

  final String operation;
  final Object? data;
}

class ${featurePascal}Failure extends ${featurePascal}State {
  const ${featurePascal}Failure({
    required this.operation,
    required this.message,
  });

  final String operation;
  final String message;
}
''';
  }

  String _cubit({
    required String featurePascal,
    required String featureSnake,
    required List<_GeneratedOperation> operations,
  }) {
    final usecaseImports = operations
        .map((operation) => "import '../../domain/usecases/${operation.operationSnake}_usecase.dart';")
        .join('\n');
    final requestImports = operations
        .where((operation) => operation.hasRequest)
        .map((operation) => "import '../../data/models/${operation.requestSnake}.dart';")
        .toSet()
        .join('\n');
    final constructorParams = operations
        .map((operation) => '    required ${operation.operationPascal}UseCase ${operation.operationCamel}UseCase,')
        .join('\n');
    final assignments = operations
        .map((operation) => '        _${operation.operationCamel}UseCase = ${operation.operationCamel}UseCase,')
        .join('\n');
    final fields = operations
        .map((operation) => '  final ${operation.operationPascal}UseCase _${operation.operationCamel}UseCase;')
        .join('\n');
    final methods = operations.map((operation) {
      return '''
  Future<void> ${operation.operationCamel}(${operation.requestParameter()}) async {
    emit(const ${featurePascal}Loading('${operation.operationCamel}'));

    try {
      final result = await _${operation.operationCamel}UseCase(${operation.requestArgument()});
      emit(${featurePascal}Success(
        operation: '${operation.operationCamel}',
        data: result,
      ));
    } catch (error) {
      emit(${featurePascal}Failure(
        operation: '${operation.operationCamel}',
        message: error.toString(),
      ));
    }
  }
''';
    }).join('\n');

    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

$usecaseImports
${requestImports.isEmpty ? '' : '$requestImports\n'}import '${featureSnake}_state.dart';

class ${featurePascal}Cubit extends Cubit<${featurePascal}State> {
  ${featurePascal}Cubit({
$constructorParams
  })  : $assignments
        super(const ${featurePascal}Initial());

$fields

$methods
}
''';
  }

  String _screen({
    required ApiGenerationInput input,
    required String featurePascal,
    required String featureSnake,
    required _GeneratedOperation operation,
    required List<_GeneratedOperation> operations,
  }) {
    final title = DartNameUtils.pascal(input.featureName).replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
    final usecaseImports = operations
        .map((item) => "import '../../domain/usecases/${item.operationSnake}_usecase.dart';")
        .join('\n');
    final cubitArgs = operations
        .map((item) => '          ${item.operationCamel}UseCase: ${item.operationPascal}UseCase(repository),')
        .join('\n');
    final initialCall = operation.hasRequest ? '' : '..${operation.operationCamel}()';

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/${featureSnake}_remote_data_source.dart';
import '../../data/repositories/${featureSnake}_repository_impl.dart';
$usecaseImports
import '../cubit/${featureSnake}_cubit.dart';
import '../cubit/${featureSnake}_state.dart';

class ${featurePascal}Screen extends StatelessWidget {
  const ${featurePascal}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final dataSource = ${featurePascal}RemoteDataSource(
          client: http.Client(),
          baseUrl: 'https://your-api-base-url.com',
          headers: const {},
        );
        final repository = ${featurePascal}RepositoryImpl(dataSource);
        return ${featurePascal}Cubit(
$cubitArgs
        )$initialCall;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('$title')),
        body: BlocBuilder<${featurePascal}Cubit, ${featurePascal}State>(
          builder: (context, state) {
            if (state is ${featurePascal}Loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ${featurePascal}Failure) {
              return Center(child: Text(state.message));
            }

            if (state is ${featurePascal}Success) {
${operation.returnsList ? _listUi() : _detailsUi()}
            }

            return Center(
              child: ${operation.hasRequest ? "ElevatedButton(onPressed: () {}, child: const Text('Call API'))" : "const Text('No data yet')"},
            );
          },
        ),
      ),
    );
  }
}
''';
  }

  String _listPayload(String modelPascal) {
    return '''
    if (payload is List) {
      return payload
          .whereType<Map<String, dynamic>>()
          .map(${modelPascal}Model.fromJson)
          .toList();
    }

    return const [];
''';
  }

  String _objectPayload(String modelPascal) {
    return '''
    if (payload is Map<String, dynamic>) {
      return ${modelPascal}Model.fromJson(payload);
    }

    return ${modelPascal}Model.fromJson(body);
''';
  }

  String _listUi() {
    return '''
              final items = state.data is List ? state.data as List : const [];
              if (items.isEmpty) {
                return const Center(child: Text('No records found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.toString()),
                    ),
                  );
                },
              );
''';
  }

  String _detailsUi() {
    return '''
              final item = state.data;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: ListTile(
                    title: Text(item.toString()),
                  ),
                ),
              );
''';
  }

  String _fieldType(SchemaField field) {
    return field.nullable ? '${field.dartType}?' : field.dartType;
  }

  String _fromJsonValue(SchemaField field) {
    final key = "json['${field.jsonKey}']";
    if (field.nullable) {
      if (field.dartType == 'double') return '($key as num?)?.toDouble()';
      if (field.dartType == 'String') return "$key?.toString()";
      return '$key as ${field.dartType}?';
    }

    return switch (field.dartType) {
      'int' => '$key as int? ?? 0',
      'double' => '($key as num?)?.toDouble() ?? 0',
      'bool' => '$key as bool? ?? false',
      'String' => "$key?.toString() ?? ''",
      'List<dynamic>' => '$key as List<dynamic>? ?? const []',
      'Map<String, dynamic>' => '$key as Map<String, dynamic>? ?? const {}',
      _ => "$key?.toString() ?? ''",
    };
  }
}

class _GeneratedOperation {
  const _GeneratedOperation({
    required this.endpoint,
    required this.responseSchema,
    required this.requestSchema,
    required this.modelPascal,
    required this.modelSnake,
    required this.operationCamel,
    required this.operationPascal,
    required this.operationSnake,
    required this.requestSnake,
    required this.hasRequest,
    required this.returnsList,
  });

  final ApiEndpointInput endpoint;
  final SchemaModel responseSchema;
  final SchemaModel requestSchema;
  final String modelPascal;
  final String modelSnake;
  final String operationCamel;
  final String operationPascal;
  final String operationSnake;
  final String requestSnake;
  final bool hasRequest;
  final bool returnsList;

  String modelReturnType({bool useModel = false}) {
    final type = useModel ? '${modelPascal}Model' : modelPascal;
    return returnsList ? 'List<$type>' : type;
  }

  String requestParameter() {
    return hasRequest ? '${requestSchema.name} request' : '';
  }

  String requestArgument() {
    return hasRequest ? 'request' : '';
  }
}
