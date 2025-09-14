enum CredentialType { apiKey }

sealed class Credential {
  factory Credential.fromJson(Map<String, Object?> json) {
    return switch (CredentialType.values.byName(json['type'] as String)) {
      CredentialType.apiKey => ApiKeyCredential.fromJson(json),
    };
  }

  factory Credential.apiKey(String apiKey) => ApiKeyCredential(apiKey: apiKey);

  CredentialType get type;
  Map<String, Object?> toJson();
}

final class ApiKeyCredential implements Credential {
  ApiKeyCredential({required this.apiKey});

  final String apiKey;

  factory ApiKeyCredential.fromJson(Map<String, Object?> json) {
    return ApiKeyCredential(apiKey: json['apiKey'] as String);
  }

  @override
  CredentialType get type => CredentialType.apiKey;

  @override
  Map<String, Object?> toJson() => {'type': type.name, 'apiKey': apiKey};
}
