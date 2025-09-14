import 'dart:convert';

import 'package:logging/logging.dart';

import '../../database/database.dart';
import '../model/credential.dart';

final class CredentialService {
  CredentialService(this._db);

  final DatabaseHandle _db;

  final CredentialStore memory = InMemoryCredentialStore();
  late final CredentialStore persistent = DatabaseCredentialStore(_db);
}

sealed class CredentialStore {
  Future<Credential?> getCredential(String modelProviderId);
  Future<void> setCredential(String modelProviderId, Credential? credential);
  Future<void> deleteCredential(String modelProviderId);
}

final class InMemoryCredentialStore implements CredentialStore {
  InMemoryCredentialStore() : _credentials = {};

  final Map<String, Credential> _credentials;

  @override
  Future<Credential?> getCredential(String modelProviderId) async {
    return _credentials[modelProviderId];
  }

  @override
  Future<void> setCredential(
    String modelProviderId,
    Credential? credential,
  ) async {
    if (credential == null) {
      return deleteCredential(modelProviderId);
    }
    _credentials[modelProviderId] = credential;
  }

  @override
  Future<void> deleteCredential(String modelProviderId) async {
    _credentials.remove(modelProviderId);
  }
}

final class DatabaseCredentialStore implements CredentialStore {
  DatabaseCredentialStore(this._db);

  final DatabaseHandle _db;

  static final Logger _logger = Logger('DatabaseCredentialStore');

  @override
  Future<Credential?> getCredential(String modelProviderId) async {
    final result = await _db.select(
      'SELECT credential FROM model_provider_credentials WHERE model_provider_id = ?',
      [modelProviderId],
    );

    if (result.isEmpty) return null;

    final credentialJson = result.first['credential'] as String;
    try {
      final credentialMap = jsonDecode(credentialJson) as Map<String, Object?>;
      return Credential.fromJson(credentialMap);
    } catch (e) {
      _logger.warning(
        'Failed to parse credential for provider $modelProviderId: $e',
      );
      return null;
    }
  }

  @override
  Future<void> setCredential(
    String modelProviderId,
    Credential? credential,
  ) async {
    if (credential == null) {
      return deleteCredential(modelProviderId);
    }

    await _db.execute(
      '''
      INSERT OR REPLACE INTO model_provider_credentials 
      (model_provider_id, credential)
      VALUES (?, ?)
    ''',
      [
        modelProviderId, // Use provider ID as credential ID for 1:1 relationship
        jsonEncode(credential.toJson()),
      ],
    );

    _logger.fine('Saved credentials for model provider: $modelProviderId');
  }

  @override
  Future<void> deleteCredential(String modelProviderId) async {
    await _db.execute(
      'DELETE FROM model_provider_credentials WHERE model_provider_id = ?',
      [modelProviderId],
    );
    _logger.fine('Deleted credentials for model provider: $modelProviderId');
  }
}
