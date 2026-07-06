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
    final modelPascal = DartNameUtils.pascal(input.modelName);
    final modelSnake = DartNameUtils.snake(input.modelName);
    final operationCamel = DartNameUtils.camel(input.operationName);
    final operationSnake = DartNameUtils.snake(input.operationName);
    final featurePascal = DartNameUtils.pascal(input.featureName);

    final responseSchema = _parser.parseResponse(
      modelName: modelPascal,
      jsonSource: input.responseJson,
    );
    final requestSchema = _parser.parseRequest(
      modelName: modelPascal,
      jsonSource: input.requestJson,
    );
    final hasRequest = requestSchema.fields.isNotEmpty;
    final returnsList = responseSchema.isListResponse;

    final basePath = 'lib/features/$featureSnake';
    final files = <GeneratedFile>[
      GeneratedFile(
        path: '$basePath/domain/entities/$modelSnake.dart',
        content: _entity(responseSchema),
      ),
      GeneratedFile(
        path: '$basePath/data/models/${modelSnake}_model.dart',
        content: _model(responseSchema),
      ),
      GeneratedFile(
        path: '$basePath/data/datasources/${featureSnake}_remote_data_source.dart',
        content: _remoteDataSource(
          input: input,
          featurePascal: featurePascal,
          modelPascal: modelPascal,
          modelSnake: modelSnake,
          operationCamel: operationCamel,
          requestSchema: requestSchema,
          hasRequest: hasRequest,
          returnsList: returnsList,
        ),
      ),
      GeneratedFile(
        path: '$basePath/domain/repositories/${featureSnake}_repository.dart',
        content: _repository(
          featurePascal: featurePascal,
          modelPascal: modelPascal,
          operationCamel: operationCamel,
          requestSchema: requestSchema,
          hasRequest: hasRequest,
          returnsList: returnsList,
        ),
      ),
      GeneratedFile(
        path: '$basePath/data/repositories/${featureSnake}_repository_impl.dart',
        content: _repositoryImpl(
          featurePascal: featurePascal,
          featureSnake: featureSnake,
          modelPascal: modelPascal,
          operationCamel: operationCamel,
          requestSchema: requestSchema,
          hasRequest: hasRequest,
          returnsList: returnsList,
        ),
      ),
      GeneratedFile(
        path: '$basePath/domain/usecases/${operationSnake}_usecase.dart',
        content: _usecase(
          featurePascal: featurePascal,
          featureSnake: featureSnake,
          modelPascal: modelPascal,
          operationCamel: operationCamel,
          requestSchema: requestSchema,
          hasRequest: hasRequest,
          returnsList: returnsList,
        ),
      ),
      GeneratedFile(
        path: '$basePath/presentation/cubit/${featureSnake}_state.dart',
        content: _state(
          featurePascal: featurePascal,
          modelPascal: modelPascal,
          returnsList: returnsList,
        ),
      ),
      GeneratedFile(
        path: '$basePath/presentation/cubit/${featureSnake}_cubit.dart',
        content: _cubit(
          featurePascal: featurePascal,
          operationSnake: operationSnake,
          operationCamel: operationCamel,
          requestSchema: requestSchema,
          hasRequest: hasRequest,
        ),
      ),
      GeneratedFile(
        path: '$basePath/presentation/screens/${featureSnake}_screen.dart',
        content: _screen(
          input: input,
          featurePascal: featurePascal,
          featureSnake: featureSnake,
          modelPascal: modelPascal,
          operationCamel: operationCamel,
          operationSnake: operationSnake,
          hasRequest: hasRequest,
          returnsList: returnsList,
        ),
      ),
    ];

    if (hasRequest) {
      files.insert(
        2,
        GeneratedFile(
          path: '$basePath/data/models/${modelSnake}_request.dart',
          content: _requestModel(requestSchema, modelSnake),
        ),
      );
    }

    return files;
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

  String _requestModel(SchemaModel schema, String modelSnake) {
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
    required ApiGenerationInput input,
    required String featurePascal,
    required String modelPascal,
    required String modelSnake,
    required String operationCamel,
    required SchemaModel requestSchema,
    required bool hasRequest,
    required bool returnsList,
  }) {
    final method = input.method.toUpperCase();
    final returnType = returnsList ? 'List<${modelPascal}Model>' : '${modelPascal}Model';
    final requestType = requestSchema.name;
    final requestImport = hasRequest ? "import '../models/${modelSnake}_request.dart';\n" : '';
    final requestParam = hasRequest ? '$requestType request' : '';
    final requestBody = hasRequest
        ? ",\n      body: jsonEncode(request.toJson()),"
        : '';
    final headers = input.requiresAuth
        ? "{...headers, 'Content-Type': 'application/json'}"
        : "{'Content-Type': 'application/json', ...headers}";

    return '''
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/${modelSnake}_model.dart';
${requestImport}class ${featurePascal}RemoteDataSource {
  ${featurePascal}RemoteDataSource({
    required this.client,
    required this.baseUrl,
    this.headers = const {},
  });

  final http.Client client;
  final String baseUrl;
  final Map<String, String> headers;

  Future<$returnType> $operationCamel($requestParam) async {
    final uri = Uri.parse('\$baseUrl${input.endpoint}');
    final response = await client.${method.toLowerCase()}(
      uri,
      headers: $headers$requestBody,
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed: \${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final payload = _extractPayload(body);
${returnsList ? _listPayload(modelPascal) : _objectPayload(modelPascal)}
  }

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

  String _repository({
    required String featurePascal,
    required String modelPascal,
    required String operationCamel,
    required SchemaModel requestSchema,
    required bool hasRequest,
    required bool returnsList,
  }) {
    final returnType = returnsList ? 'List<$modelPascal>' : modelPascal;
    final requestImport = hasRequest ? "\nimport '../../data/models/${DartNameUtils.snake(modelPascal)}_request.dart';" : '';
    final requestParam = hasRequest ? '${requestSchema.name} request' : '';

    return '''
import '../entities/${DartNameUtils.snake(modelPascal)}.dart';$requestImport

abstract class ${featurePascal}Repository {
  Future<$returnType> $operationCamel($requestParam);
}
''';
  }

  String _repositoryImpl({
    required String featurePascal,
    required String featureSnake,
    required String modelPascal,
    required String operationCamel,
    required SchemaModel requestSchema,
    required bool hasRequest,
    required bool returnsList,
  }) {
    final returnType = returnsList ? 'List<$modelPascal>' : modelPascal;
    final requestImport = hasRequest ? "\nimport '../models/${DartNameUtils.snake(modelPascal)}_request.dart';" : '';
    final requestParam = hasRequest ? '${requestSchema.name} request' : '';
    final requestArg = hasRequest ? 'request' : '';

    return '''
import '../../domain/entities/${DartNameUtils.snake(modelPascal)}.dart';
import '../../domain/repositories/${featureSnake}_repository.dart';
import '../datasources/${featureSnake}_remote_data_source.dart';$requestImport

class ${featurePascal}RepositoryImpl implements ${featurePascal}Repository {
  const ${featurePascal}RepositoryImpl(this.remoteDataSource);

  final ${featurePascal}RemoteDataSource remoteDataSource;

  @override
  Future<$returnType> $operationCamel($requestParam) {
    return remoteDataSource.$operationCamel($requestArg);
  }
}
''';
  }

  String _usecase({
    required String featurePascal,
    required String featureSnake,
    required String modelPascal,
    required String operationCamel,
    required SchemaModel requestSchema,
    required bool hasRequest,
    required bool returnsList,
  }) {
    final usecaseName = '${DartNameUtils.pascal(operationCamel)}UseCase';
    final returnType = returnsList ? 'List<$modelPascal>' : modelPascal;
    final requestImport = hasRequest ? "\nimport '../../data/models/${DartNameUtils.snake(modelPascal)}_request.dart';" : '';
    final requestParam = hasRequest ? '${requestSchema.name} request' : '';
    final requestArg = hasRequest ? 'request' : '';

    return '''
import '../entities/${DartNameUtils.snake(modelPascal)}.dart';
import '../repositories/${featureSnake}_repository.dart';$requestImport

class $usecaseName {
  const $usecaseName(this.repository);

  final ${featurePascal}Repository repository;

  Future<$returnType> call($requestParam) {
    return repository.$operationCamel($requestArg);
  }
}
''';
  }

  String _state({
    required String featurePascal,
    required String modelPascal,
    required bool returnsList,
  }) {
    final dataType = returnsList ? 'List<$modelPascal>' : modelPascal;

    return '''
import '../../domain/entities/${DartNameUtils.snake(modelPascal)}.dart';

abstract class ${featurePascal}State {
  const ${featurePascal}State();
}

class ${featurePascal}Initial extends ${featurePascal}State {
  const ${featurePascal}Initial();
}

class ${featurePascal}Loading extends ${featurePascal}State {
  const ${featurePascal}Loading();
}

class ${featurePascal}Success extends ${featurePascal}State {
  const ${featurePascal}Success(this.data);

  final $dataType data;
}

class ${featurePascal}Failure extends ${featurePascal}State {
  const ${featurePascal}Failure(this.message);

  final String message;
}
''';
  }

  String _cubit({
    required String featurePascal,
    required String operationSnake,
    required String operationCamel,
    required SchemaModel requestSchema,
    required bool hasRequest,
  }) {
    final usecaseName = '${DartNameUtils.pascal(operationCamel)}UseCase';
    final requestImport = hasRequest ? "\nimport '../../data/models/${DartNameUtils.snake(requestSchema.name.replaceAll('Request', ''))}_request.dart';" : '';
    final requestParam = hasRequest ? '${requestSchema.name} request' : '';
    final requestArg = hasRequest ? 'request' : '';

    return '''
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/${operationSnake}_usecase.dart';$requestImport
import '${DartNameUtils.snake(featurePascal)}_state.dart';

class ${featurePascal}Cubit extends Cubit<${featurePascal}State> {
  ${featurePascal}Cubit(this._${operationCamel}UseCase)
      : super(const ${featurePascal}Initial());

  final $usecaseName _${operationCamel}UseCase;

  Future<void> $operationCamel($requestParam) async {
    emit(const ${featurePascal}Loading());

    try {
      final result = await _${operationCamel}UseCase($requestArg);
      emit(${featurePascal}Success(result));
    } catch (error) {
      emit(${featurePascal}Failure(error.toString()));
    }
  }
}
''';
  }

  String _screen({
    required ApiGenerationInput input,
    required String featurePascal,
    required String featureSnake,
    required String modelPascal,
    required String operationCamel,
    required String operationSnake,
    required bool hasRequest,
    required bool returnsList,
  }) {
    final usecaseName = '${DartNameUtils.pascal(operationCamel)}UseCase';
    final title = DartNameUtils.pascal(input.featureName).replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/${featureSnake}_remote_data_source.dart';
import '../../data/repositories/${featureSnake}_repository_impl.dart';
import '../../domain/usecases/${operationSnake}_usecase.dart';
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
        return ${featurePascal}Cubit($usecaseName(repository))
          ${hasRequest ? '' : '..$operationCamel()'};
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
${returnsList ? _listUi(modelPascal) : _detailsUi(modelPascal)}
            }

            return Center(
              child: ${hasRequest ? "ElevatedButton(onPressed: () {}, child: const Text('Call API'))" : "const Text('No data yet')"},
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

  String _listUi(String modelPascal) {
    return '''
              final items = state.data;
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

  String _detailsUi(String modelPascal) {
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
