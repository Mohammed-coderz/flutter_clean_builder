import '../domain/generated_file.dart';

class GeneratorState {
  const GeneratorState({
    this.files = const [],
    this.selectedIndex = 0,
    this.errorMessage,
  });

  final List<GeneratedFile> files;
  final int selectedIndex;
  final String? errorMessage;

  bool get hasFiles => files.isNotEmpty;

  GeneratedFile? get selectedFile {
    if (files.isEmpty) return null;
    if (selectedIndex < 0 || selectedIndex >= files.length) return files.first;
    return files[selectedIndex];
  }

  GeneratorState copyWith({
    List<GeneratedFile>? files,
    int? selectedIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GeneratorState(
      files: files ?? this.files,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
