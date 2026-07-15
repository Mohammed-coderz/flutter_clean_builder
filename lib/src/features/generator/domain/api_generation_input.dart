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

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'featureName': featureName,
      'modelName': modelName,
      'operationName': operationName,
      'method': method,
      'endpoint': endpoint,
      'requestJson': requestJson,
      'responseJson': responseJson,
      'requiresAuth': requiresAuth,
      'endpoints': endpoints.map((endpoint) => endpoint.toJson()).toList(),
    };
  }

  factory ApiGenerationInput.fromJson(Map<String, dynamic> json) {
    final endpointsJson = json['endpoints'];
    final endpoints = endpointsJson is List
        ? endpointsJson
            .whereType<Map>()
            .map((endpoint) => ApiEndpointInput.fromJson(Map<String, dynamic>.from(endpoint)))
            .toList()
        : <ApiEndpointInput>[];

    return ApiGenerationInput(
      featureName: _readString(json, 'featureName'),
      modelName: _readString(json, 'modelName'),
      operationName: _readString(json, 'operationName'),
      method: _readString(json, 'method', fallback: 'GET').toUpperCase(),
      endpoint: _readString(json, 'endpoint'),
      requestJson: _readString(json, 'requestJson'),
      responseJson: _readString(json, 'responseJson'),
      requiresAuth: json['requiresAuth'] is bool ? json['requiresAuth'] as bool : true,
      endpoints: endpoints,
    );
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

  Map<String, dynamic> toJson() {
    return {
      'modelName': modelName,
      'operationName': operationName,
      'method': method,
      'endpoint': endpoint,
      'requestJson': requestJson,
      'responseJson': responseJson,
      'requiresAuth': requiresAuth,
    };
  }

  factory ApiEndpointInput.fromJson(Map<String, dynamic> json) {
    return ApiEndpointInput(
      modelName: _readString(json, 'modelName'),
      operationName: _readString(json, 'operationName'),
      method: _readString(json, 'method', fallback: 'GET').toUpperCase(),
      endpoint: _readString(json, 'endpoint'),
      requestJson: _readString(json, 'requestJson'),
      responseJson: _readString(json, 'responseJson'),
      requiresAuth: json['requiresAuth'] is bool ? json['requiresAuth'] as bool : true,
    );
  }
}

String _readString(Map<String, dynamic> json, String key, {String fallback = ''}) {
  final value = json[key];
  if (value == null) return fallback;
  return value.toString();
}
