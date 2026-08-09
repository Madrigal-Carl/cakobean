import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Thrown when an upload to Supabase Storage fails.
class StorageUploadException implements Exception {
  final String message;

  const StorageUploadException(this.message);

  @override
  String toString() => message;
}

/// Uploads article media to the public `media` bucket in Supabase Storage.
/// Objects are stored under `{uid}/{timestamp}_{safeName}` so each user owns
/// a folder (RLS on `storage.objects` checks the first path segment). The
/// Supabase client attaches the signed-in session, so no credentials ever
/// touch the app.
class StorageService {
  StorageService({sb.SupabaseClient? client})
      : _client = client ?? sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  /// Uploads the local [file] and returns its permanent public URL. [uid] is
  /// the signed-in user's id, used as the storage folder for RLS ownership.
  Future<String> uploadMedia({
    required String filename,
    required File file,
    required String uid,
  }) async {
    final key = '$uid/${DateTime.now().millisecondsSinceEpoch}_${_safeName(filename)}';
    try {
      await _client.storage.from('media').upload(key, file);
    } on sb.StorageException catch (e) {
      throw StorageUploadException('Upload failed: ${e.message}');
    }
    return _client.storage.from('media').getPublicUrl(key);
  }

  static String _safeName(String filename) {
    final name = filename.trim().replaceAll(RegExp(r'[^\w.\-]'), '_');
    return name.isEmpty ? 'media' : name;
  }
}
