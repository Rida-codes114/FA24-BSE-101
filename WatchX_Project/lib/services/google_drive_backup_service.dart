import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'watchx_database_service.dart';

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
  }
}

class GoogleDriveBackupService {
  static const String _backupFileName = 'watchx_sql_backup.db';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveAppdataScope],
  );

  // ---------------- GOOGLE DRIVE CONNECTION ----------------

  static Future<drive.DriveApi?> _getDriveApi() async {
    if (kIsWeb) {
      throw Exception(
        'Google Drive backup is available in the mobile/desktop build.',
      );
    }

    GoogleSignInAccount? account = _googleSignIn.currentUser;

    account ??= await _googleSignIn.signInSilently();

    account ??= await _googleSignIn.signIn();

    if (account == null) {
      return null;
    }

    final authHeaders = await account.authHeaders;
    final client = _GoogleAuthClient(authHeaders);

    return drive.DriveApi(client);
  }

  // ---------------- FIND EXISTING BACKUP ----------------

  static Future<String?> _findBackupFileId(drive.DriveApi driveApi) async {
    final result = await driveApi.files.list(
      spaces: 'appDataFolder',
      q: "name = '$_backupFileName' and trashed = false",
      $fields: 'files(id, name)',
    );

    if (result.files == null || result.files!.isEmpty) {
      return null;
    }

    return result.files!.first.id;
  }

  // ---------------- DATABASE BACKUP ----------------

  static Future<String> backupDatabaseToDrive() async {
    try {
      if (kIsWeb) {
        return 'Drive backup is available after building the mobile app.';
      }

      final driveApi = await _getDriveApi();

      if (driveApi == null) {
        return 'Google sign-in cancelled.';
      }

      // Save pending SQLite changes and safely close database.
      await WatchXDatabaseService.prepareDatabaseForBackup();

      final dbPath = await WatchXDatabaseService.getDatabaseFilePath();

      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        return 'Local database file not found.';
      }

      final fileLength = await dbFile.length();

      if (fileLength == 0) {
        return 'Database file is empty. Backup could not be created.';
      }

      final existingFileId = await _findBackupFileId(driveApi);

      final media = drive.Media(dbFile.openRead(), fileLength);

      if (existingFileId != null) {
        // Update the existing backup instead of creating duplicates.
        await driveApi.files.update(
          drive.File(name: _backupFileName),
          existingFileId,
          uploadMedia: media,
        );
      } else {
        // Create the first backup in the private appDataFolder.
        final metadata = drive.File()
          ..name = _backupFileName
          ..parents = ['appDataFolder'];

        await driveApi.files.create(metadata, uploadMedia: media);
      }

      return 'Database backup completed successfully (${_timeNow()}).';
    } catch (e) {
      return 'Drive Backup Error: $e';
    }
  }

  // ---------------- DATABASE RESTORE ----------------

  static Future<String> restoreDatabaseFromDrive() async {
    bool databaseClosed = false;

    File? temporaryFile;
    File? originalBackupFile;

    try {
      if (kIsWeb) {
        return 'Drive restore is available after building the mobile app.';
      }

      final driveApi = await _getDriveApi();

      if (driveApi == null) {
        return 'Google sign-in cancelled.';
      }

      final fileId = await _findBackupFileId(driveApi);

      if (fileId == null) {
        return 'No WATCHX database backup found in Google Drive.';
      }

      // Download the backup first.
      final media = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];

      await for (final chunk in media.stream) {
        bytes.addAll(chunk);
      }

      if (bytes.length < 16) {
        return 'Backup file is empty or incomplete.';
      }

      // Check that the downloaded file is a SQLite database.
      const sqliteHeader = [
        83,
        81,
        76,
        105,
        116,
        101,
        32,
        102,
        111,
        114,
        109,
        97,
        116,
        32,
        51,
        0,
      ];

      for (int i = 0; i < sqliteHeader.length; i++) {
        if (bytes[i] != sqliteHeader[i]) {
          return 'Invalid backup file. It is not a valid SQLite database.';
        }
      }

      final dbPath = await WatchXDatabaseService.getDatabaseFilePath();

      final dbFile = File(dbPath);

      temporaryFile = File('$dbPath.restore.tmp');
      originalBackupFile = File('$dbPath.restore.bak');

      // Write downloaded data to a temporary file first.
      if (await temporaryFile.exists()) {
        await temporaryFile.delete();
      }

      await temporaryFile.writeAsBytes(bytes, flush: true);

      // Close SQLite before replacing its database file.
      await WatchXDatabaseService.closeDatabaseForRestore();
      databaseClosed = true;

      // Remove SQLite sidecar files after closing the database.
      final walFile = File('$dbPath-wal');
      final shmFile = File('$dbPath-shm');

      if (await walFile.exists()) {
        await walFile.delete();
      }

      if (await shmFile.exists()) {
        await shmFile.delete();
      }

      // Keep the current database temporarily as a safety copy.
      if (await originalBackupFile.exists()) {
        await originalBackupFile.delete();
      }

      if (await dbFile.exists()) {
        await dbFile.rename(originalBackupFile.path);
      }

      try {
        await temporaryFile.rename(dbPath);
      } catch (_) {
        // Restore the previous database if replacement fails.
        if (await originalBackupFile.exists()) {
          await originalBackupFile.rename(dbPath);
        }

        rethrow;
      }

      // Reopen the restored database.
      await WatchXDatabaseService.reopenDatabaseAfterRestore();
      databaseClosed = false;

      if (await originalBackupFile.exists()) {
        await originalBackupFile.delete();
      }

      return 'Database restored successfully from Google Drive.';
    } catch (e) {
      // Reopen the database if an error occurred after closing it.
      if (databaseClosed) {
        try {
          await WatchXDatabaseService.reopenDatabaseAfterRestore();
        } catch (_) {
          // Preserve the original error message.
        }
      }

      return 'Drive Restore Error: $e';
    } finally {
      if (temporaryFile != null && await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
    }
  }

  // ---------------- TIME ----------------

  static String _timeNow() {
    final now = DateTime.now();

    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '${now.day}/${now.month}/${now.year} $hour:$minute';
  }
}
