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
  Future<Credential?> getCredential(String providerId);
  Future<void> setCredential(String providerId, Credential? credential);
  Future<void> deleteCredential(String providerId);
}

final class InMemoryCredentialStore implements CredentialStore {
  InMemoryCredentialStore() : _credentials = {};

  final Map<String, Credential> _credentials;

  @override
  Future<Credential?> getCredential(String providerId) async {
    return _credentials[providerId];
  }

  @override
  Future<void> setCredential(String providerId, Credential? credential) async {
    if (credential == null) {
      return deleteCredential(providerId);
    }
    _credentials[providerId] = credential;
  }

  @override
  Future<void> deleteCredential(String providerId) async {
    _credentials.remove(providerId);
  }
}

final class DatabaseCredentialStore implements CredentialStore {
  DatabaseCredentialStore(this._db);

  final DatabaseHandle _db;

  static final Logger _logger = Logger('DatabaseCredentialStore');

  @override
  Future<Credential?> getCredential(String providerId) async {
    final result = await _db.select(
      'SELECT credential FROM provider_credentials WHERE provider_id = ?',
      [providerId],
    );

    if (result.isEmpty) return null;

    final credentialJson = result.first['credential'] as String;
    try {
      final credentialMap = jsonDecode(credentialJson) as Map<String, Object?>;
      return Credential.fromJson(credentialMap);
    } catch (e) {
      _logger.warning(
        'Failed to parse credential for provider $providerId: $e',
      );
      return null;
    }
  }

  @override
  Future<void> setCredential(String providerId, Credential? credential) async {
    if (credential == null) {
      return deleteCredential(providerId);
    }

    await _db.execute(
      '''
      INSERT OR REPLACE INTO provider_credentials 
      (provider_id, credential)
      VALUES (?, ?)
    ''',
      [
        providerId, // Use provider ID as credential ID for 1:1 relationship
        jsonEncode(credential.toJson()),
      ],
    );

    _logger.fine('Saved credentials for provider: $providerId');
  }

  @override
  Future<void> deleteCredential(String providerId) async {
    await _db.execute(
      'DELETE FROM provider_credentials WHERE provider_id = ?',
      [providerId],
    );
    _logger.fine('Deleted credentials for provider: $providerId');
  }
}
