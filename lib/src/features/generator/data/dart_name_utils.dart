class DartNameUtils {
  const DartNameUtils._();

  static String snake(String value) {
    final words = _words(value);
    if (words.isEmpty) return 'generated';
    return words.map((word) => word.toLowerCase()).join('_');
  }

  static String pascal(String value) {
    final words = _words(value);
    if (words.isEmpty) return 'Generated';
    return words.map(_capitalize).join();
  }

  static String camel(String value) {
    final pascalName = pascal(value);
    return pascalName[0].toLowerCase() + pascalName.substring(1);
  }

  static List<String> _words(String value) {
    final spaced = value
        .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (match) {
          return '${match.group(1)} ${match.group(2)}';
        })
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim();

    if (spaced.isEmpty) return const [];
    return spaced.split(RegExp(r'\s+'));
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
