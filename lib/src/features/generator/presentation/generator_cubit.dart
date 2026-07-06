import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/clean_architecture_generator.dart';
import '../data/dart_name_utils.dart';
import '../data/generated_zip_exporter.dart';
import '../domain/api_generation_input.dart';
import 'generator_state.dart';

class GeneratorCubit extends Cubit<GeneratorState> {
  GeneratorCubit({
    CleanArchitectureGenerator? generator,
    GeneratedZipExporter? zipExporter,
  })  : _generator = generator ?? CleanArchitectureGenerator(),
        _zipExporter = zipExporter ?? const GeneratedZipExporter(),
        super(const GeneratorState());

  final CleanArchitectureGenerator _generator;
  final GeneratedZipExporter _zipExporter;
  String _lastFeatureName = 'generated_feature';

  void generate(ApiGenerationInput input) {
    final validationMessage = _validate(input);
    if (validationMessage != null) {
      emit(state.copyWith(errorMessage: validationMessage));
      return;
    }

    try {
      final files = _generator.generate(input);
      _lastFeatureName = DartNameUtils.snake(input.featureName);
      emit(GeneratorState(files: files));
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  void selectFile(int index) {
    emit(state.copyWith(selectedIndex: index, clearError: true));
  }

  String buildCopyPayload() {
    final buffer = StringBuffer();

    for (final file in state.files) {
      buffer
        ..writeln('// FILE: ${file.path}')
        ..writeln(file.content.trimRight())
        ..writeln()
        ..writeln();
    }

    return buffer.toString();
  }

  void downloadZip() {
    if (state.files.isEmpty) {
      emit(state.copyWith(errorMessage: 'Generate files before exporting zip.'));
      return;
    }

    try {
      _zipExporter.download(
        fileName: '${_lastFeatureName}_feature.zip',
        files: state.files,
      );
    } catch (error) {
      emit(state.copyWith(errorMessage: error.toString()));
    }
  }

  String? _validate(ApiGenerationInput input) {
    if (input.featureName.trim().isEmpty) return 'Feature name is required.';
    if (input.modelName.trim().isEmpty) return 'Model name is required.';
    if (input.operationName.trim().isEmpty) return 'Operation name is required.';
    if (input.endpoint.trim().isEmpty) return 'Endpoint is required.';
    if (input.responseJson.trim().isEmpty) return 'Response JSON is required.';
    return null;
  }
}
