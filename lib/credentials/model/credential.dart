import 'package:freezed_annotation/freezed_annotation.dart';

part 'credential.freezed.dart';
part 'credential.g.dart';

enum CredentialType { apiKey }

@freezed
sealed class Credential with _$Credential {
  const factory Credential.apiKey(String apiKey) = ApiKeyCredential;

  const Credential._();

  CredentialType get type => map(apiKey: (_) => CredentialType.apiKey);

  factory Credential.fromJson(Map<String, Object?> json) =>
      _$CredentialFromJson(json);
}
