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
    this.endpoints = const [],
  });

  final String featureName;
  final String modelName;
  final String operationName;
  final String method;
  final String endpoint;
  final String requestJson;
  final String responseJson;
  final bool requiresAuth;
  final List<ApiEndpointInput> endpoints;

  List<ApiEndpointInput> get resolvedEndpoints {
    if (endpoints.isNotEmpty) return endpoints;

    return [
      ApiEndpointInput(
        modelName: modelName,
        operationName: operationName,
        method: method,
        endpoint: endpoint,
        requestJson: requestJson,
        responseJson: responseJson,
        requiresAuth: requiresAuth,
      ),
    ];
  }
}

class ApiEndpointInput {
  const ApiEndpointInput({
    required this.modelName,
    required this.operationName,
    required this.method,
    required this.endpoint,
    required this.requestJson,
    required this.responseJson,
    required this.requiresAuth,
  });

  final String modelName;
  final String operationName;
  final String method;
  final String endpoint;
  final String requestJson;
  final String responseJson;
  final bool requiresAuth;
}
