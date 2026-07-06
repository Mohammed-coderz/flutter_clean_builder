class ApiGenerationInput {
  const ApiGenerationInput({
    required this.featureName,
    required this.modelName,
    required this.operationName,
    required this.method,
    required this.endpoint,
    required this.requestJson,
    required this.responseJson,
    required this.requiresAuth,
  });

  final String featureName;
  final String modelName;
  final String operationName;
  final String method;
  final String endpoint;
  final String requestJson;
  final String responseJson;
  final bool requiresAuth;
}
