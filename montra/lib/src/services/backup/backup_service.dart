import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' hide Category;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../../data/database/database.dart';

class BackupFileMetadata {
  final String path;
  final String fileName;
  final int fileSize;
  final DateTime createdAt;
  final int transactionCount;
  final double totalExpense;
  final bool isAutoBackup;

  BackupFileMetadata({
    required this.path,
    required this.fileName,
    required this.fileSize,
    required this.createdAt,
    required this.transactionCount,
    required this.totalExpense,
    required this.isAutoBackup,
  });

  File get file => File(path);
}

class RestoreResult {
  final bool success;
  final String message;
  final int restoredTransactions;
  final int restoredAccounts;
  final int restoredCategories;
  final int restoredBudgets;

  RestoreResult({
    required this.success,
    required this.message,
    this.restoredTransactions = 0,
    this.restoredAccounts = 0,
    this.restoredCategories = 0,
    this.restoredBudgets = 0,
  });
}

class BackupService {
  final AppDatabase _db;
  final Directory? _baseDirectory;

  BackupService(this._db, [this._baseDirectory]);

  static const String _autoBackupPrefKey = 'montra_auto_backup_enabled';
  static const String _lastBackupDateKey = 'montra_last_backup_date';

  // ─────────────────────────────────────────────────────────────────────────
  // DIRECTORY HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Internal app storage for backups: `<appDocs>/backups/`
  Future<Directory> getInternalBackupDirectory() async {
    if (_baseDirectory != null) {
      final backupDir = Directory(p.join(_baseDirectory.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      return backupDir;
    }
    final appDocs = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDocs.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Persistent external storage for backups: `/storage/emulated/0/Download/Montra_Backups`
  /// or Downloads folder so backups SURVIVE app uninstalls & rebuilds.
  Future<Directory?> getExternalBackupDirectory() async {
    if (_baseDirectory != null) return null;
    try {
      if (Platform.isAndroid) {
        // Public Downloads folder on Android is never deleted on app rebuild
        final publicDownload = Directory('/storage/emulated/0/Download/Montra_Backups');
        if (!await publicDownload.exists()) {
          try {
            await publicDownload.create(recursive: true);
          } catch (_) {}
        }
        if (await publicDownload.exists()) {
          return publicDownload;
        }
      }

      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        final montraFolder = Directory(p.join(downloads.path, 'Montra_Backups'));
        if (!await montraFolder.exists()) {
          await montraFolder.create(recursive: true);
        }
        return montraFolder;
      }
    } catch (e) {
      debugPrint('Error getting external backup directory: $e');
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CREATE BACKUP
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a complete JSON backup containing all 11 tables and metadata.
  /// Saves to internal backups folder AND copies to persistent external Downloads.
  Future<File> createBackup({bool isAuto = false}) async {
    final accounts = await _db.select(_db.accounts).get();
    final categories = await _db.select(_db.categories).get();
    final transactions = await _db.select(_db.transactions).get();
    final budgets = await _db.select(_db.budgets).get();
    final notifications = await _db.select(_db.notifications).get();
    final settings = await _db.select(_db.settings).get();
    final tags = await _db.select(_db.tags).get();
    final transactionTags = await _db.select(_db.transactionTags).get();
    final unrecognizedSms = await _db.select(_db.unrecognizedSms).get();
    final savedSummaries = await _db.select(_db.savedSummaries).get();
    final notificationSettings = await _db.select(_db.notificationSettingsDb).get();

    final now = DateTime.now();
    double totalExpense = 0;
    for (final tx in transactions) {
      if (tx.type.toLowerCase() == 'expense') {
        totalExpense += tx.amount;
      }
    }

    final backupMap = {
      'version': 1,
      'appName': 'Montra',
      'createdAt': now.toIso8601String(),
      'summary': {
        'totalTransactions': transactions.length,
        'totalAccounts': accounts.length,
        'totalCategories': categories.length,
        'totalBudgets': budgets.length,
        'totalExpense': totalExpense,
      },
      'tables': {
        'accounts': accounts.map((e) => e.toJson()).toList(),
        'categories': categories.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'budgets': budgets.map((e) => e.toJson()).toList(),
        'notifications': notifications.map((e) => e.toJson()).toList(),
        'settings': settings.map((e) => e.toJson()).toList(),
        'tags': tags.map((e) => e.toJson()).toList(),
        'transactionTags': transactionTags.map((e) => e.toJson()).toList(),
        'unrecognizedSms': unrecognizedSms.map((e) => e.toJson()).toList(),
        'savedSummaries': savedSummaries.map((e) => e.toJson()).toList(),
        'notificationSettings': notificationSettings.map((e) => e.toJson()).toList(),
      },
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupMap);

    final internalDir = await getInternalBackupDirectory();
    final fileName = isAuto
        ? 'montra_auto_backup.json'
        : 'montra_backup_${DateFormat('yyyyMMdd_HHmmss').format(now)}.json';

    final internalFile = File(p.join(internalDir.path, fileName));
    await internalFile.writeAsString(jsonString, flush: true);

    // Also persist to external Downloads directory so rebuilds don't lose it
    try {
      final extDir = await getExternalBackupDirectory();
      if (extDir != null) {
        final extFile = File(p.join(extDir.path, fileName));
        await extFile.writeAsString(jsonString, flush: true);
      }
    } catch (e) {
      debugPrint('Could not copy backup to external storage: $e');
    }

    // Update last backup date in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBackupDateKey, now.toIso8601String());

    return internalFile;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESTORE BACKUP
  // ─────────────────────────────────────────────────────────────────────────

  /// Restores database state from a backup JSON file.
  Future<RestoreResult> restoreFromFile(File file, {bool clearExisting = true}) async {
    try {
      if (!await file.exists()) {
        return RestoreResult(success: false, message: 'Backup file does not exist.');
      }

      final content = await file.readAsString();
      final dynamic decoded = jsonDecode(content);

      if (decoded is! Map<String, dynamic>) {
        return RestoreResult(success: false, message: 'Invalid backup file format.');
      }

      final tables = decoded['tables'];
      if (tables == null || tables is! Map<String, dynamic>) {
        return RestoreResult(success: false, message: 'Backup file missing tables data.');
      }

      int restoredAccounts = 0;
      int restoredCategories = 0;
      int restoredTransactions = 0;
      int restoredBudgets = 0;

      await _db.transaction(() async {
        if (clearExisting) {
          // Clear dependent tables first to respect FK constraints
          await _db.delete(_db.transactionTags).go();
          await _db.delete(_db.transactions).go();
          await _db.delete(_db.budgets).go();
          await _db.delete(_db.categories).go();
          await _db.delete(_db.accounts).go();
          await _db.delete(_db.tags).go();
          await _db.delete(_db.unrecognizedSms).go();
          await _db.delete(_db.savedSummaries).go();
          await _db.delete(_db.notifications).go();
          await _db.delete(_db.settings).go();
          await _db.delete(_db.notificationSettingsDb).go();
        }

        // 1. Accounts
        if (tables['accounts'] is List) {
          for (final item in tables['accounts']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Account.fromJson(item);
                await _db.into(_db.accounts).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
                restoredAccounts++;
              } catch (_) {}
            }
          }
        }

        // 2. Categories
        if (tables['categories'] is List) {
          for (final item in tables['categories']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Category.fromJson(item);
                await _db.into(_db.categories).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
                restoredCategories++;
              } catch (_) {}
            }
          }
        }

        // 3. Transactions
        if (tables['transactions'] is List) {
          for (final item in tables['transactions']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Transaction.fromJson(item);
                await _db.into(_db.transactions).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
                restoredTransactions++;
              } catch (_) {}
            }
          }
        }

        // 4. Budgets
        if (tables['budgets'] is List) {
          for (final item in tables['budgets']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Budget.fromJson(item);
                await _db.into(_db.budgets).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
                restoredBudgets++;
              } catch (_) {}
            }
          }
        }

        // 5. Tags
        if (tables['tags'] is List) {
          for (final item in tables['tags']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Tag.fromJson(item);
                await _db.into(_db.tags).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }

        // 6. Transaction Tags
        if (tables['transactionTags'] is List) {
          for (final item in tables['transactionTags']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = TransactionTag.fromJson(item);
                await _db.into(_db.transactionTags).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }

        // 7. Unrecognized SMS
        if (tables['unrecognizedSms'] is List) {
          for (final item in tables['unrecognizedSms']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = UnrecognizedSm.fromJson(item);
                await _db.into(_db.unrecognizedSms).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }

        // 8. Notifications
        if (tables['notifications'] is List) {
          for (final item in tables['notifications']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Notification.fromJson(item);
                await _db.into(_db.notifications).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }

        // 9. Settings
        if (tables['settings'] is List) {
          for (final item in tables['settings']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = Setting.fromJson(item);
                await _db.into(_db.settings).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }

        // 10. Saved Summaries
        if (tables['savedSummaries'] is List) {
          for (final item in tables['savedSummaries']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = SavedSummary.fromJson(item);
                await _db.into(_db.savedSummaries).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }

        // 11. Notification Settings
        if (tables['notificationSettings'] is List) {
          for (final item in tables['notificationSettings']) {
            if (item is Map<String, dynamic>) {
              try {
                final row = NotificationSettingsDbData.fromJson(item);
                await _db.into(_db.notificationSettingsDb).insert(
                  row.toCompanion(false),
                  mode: drift.InsertMode.insertOrReplace,
                );
              } catch (_) {}
            }
          }
        }
      });

      // Notify Drift tables so UI listeners re-fetch immediately
      _db.notifyUpdates({
        drift.TableUpdate.onTable(_db.transactions),
        drift.TableUpdate.onTable(_db.accounts),
        drift.TableUpdate.onTable(_db.categories),
        drift.TableUpdate.onTable(_db.budgets),
        drift.TableUpdate.onTable(_db.notifications),
        drift.TableUpdate.onTable(_db.settings),
        drift.TableUpdate.onTable(_db.tags),
        drift.TableUpdate.onTable(_db.unrecognizedSms),
      });

      return RestoreResult(
        success: true,
        message: 'Successfully restored $restoredTransactions transactions, $restoredAccounts accounts, and $restoredBudgets budgets.',
        restoredTransactions: restoredTransactions,
        restoredAccounts: restoredAccounts,
        restoredCategories: restoredCategories,
        restoredBudgets: restoredBudgets,
      );
    } catch (e, st) {
      debugPrint('Restore failed: $e\n$st');
      return RestoreResult(success: false, message: 'Restore failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BACKUP DISCOVERY & MANAGEMENT
  // ─────────────────────────────────────────────────────────────────────────

  /// Lists all discovered backups from both internal storage and external Downloads folder.
  Future<List<BackupFileMetadata>> getAvailableBackups() async {
    final Map<String, BackupFileMetadata> discovered = {};

    // Search internal directory
    try {
      final internalDir = await getInternalBackupDirectory();
      if (await internalDir.exists()) {
        final files = internalDir.listSync().whereType<File>();
        for (final file in files) {
          if (file.path.endsWith('.json')) {
            final meta = await _parseMetadata(file);
            if (meta != null) {
              discovered[file.path] = meta;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning internal backups: $e');
    }

    // Search external Downloads directory
    try {
      final extDir = await getExternalBackupDirectory();
      if (extDir != null && await extDir.exists()) {
        final files = extDir.listSync().whereType<File>();
        for (final file in files) {
          if (file.path.endsWith('.json') && !discovered.containsKey(file.path)) {
            final meta = await _parseMetadata(file);
            if (meta != null) {
              discovered[file.path] = meta;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error scanning external backups: $e');
    }

    final list = discovered.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Finds the latest available backup file (e.g. for automatic rebuild recovery).
  Future<BackupFileMetadata?> getLatestAvailableBackup() async {
    final backups = await getAvailableBackups();
    if (backups.isEmpty) return null;
    return backups.first;
  }

  /// Parses header metadata without loading full array data into memory
  Future<BackupFileMetadata?> _parseMetadata(File file) async {
    try {
      final stat = await file.stat();
      final content = await file.readAsString();
      final dynamic decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic> && decoded['appName'] == 'Montra') {
        final summary = decoded['summary'] as Map<String, dynamic>?;
        final createdAtStr = decoded['createdAt'] as String?;
        final createdAt = createdAtStr != null
            ? DateTime.tryParse(createdAtStr) ?? stat.modified
            : stat.modified;

        final isAuto = file.path.contains('auto_backup');

        return BackupFileMetadata(
          path: file.path,
          fileName: p.basename(file.path),
          fileSize: stat.size,
          createdAt: createdAt,
          transactionCount: summary?['totalTransactions'] ?? 0,
          totalExpense: (summary?['totalExpense'] as num?)?.toDouble() ?? 0.0,
          isAutoBackup: isAuto,
        );
      }
    } catch (_) {}
    return null;
  }

  /// Shares backup file via standard system share sheet (Drive, Gmail, WhatsApp, Files)
  Future<void> shareBackup(File file) async {
    final xfile = XFile(file.path);
    await SharePlus.instance.share(
      ShareParams(
        files: [xfile],
        text: 'Montra Backup - ${p.basename(file.path)}',
      ),
    );
  }

  /// Deletes a backup file
  Future<bool> deleteBackup(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting backup: $e');
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AUTO-BACKUP SETTINGS & TRIGGER
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> isAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoBackupPrefKey) ?? true; // Enabled by default
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupPrefKey, enabled);
  }

  Future<DateTime?> getLastBackupDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(_lastBackupDateKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  DateTime? _lastAutoBackupTime;

  /// Throttled auto-backup (max once every 60 seconds) triggered when transactions are modified
  Future<void> triggerAutoBackupIfEnabled() async {
    try {
      final enabled = await isAutoBackupEnabled();
      if (!enabled) return;

      final now = DateTime.now();
      if (_lastAutoBackupTime != null &&
          now.difference(_lastAutoBackupTime!).inSeconds < 60) {
        return; // throttled
      }
      _lastAutoBackupTime = now;
      await createBackup(isAuto: true);
    } catch (e) {
      debugPrint('Auto-backup check failed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CSV EXPORT & IMPORT
  // ─────────────────────────────────────────────────────────────────────────

  /// Exports all transactions into CSV format
  Future<File> exportCsv() async {
    final transactions = await _db.select(_db.transactions).get();
    final categories = await _db.select(_db.categories).get();
    final categoryMap = {for (var c in categories) c.id: c.name};

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('Date,Type,Amount,Merchant,Category,PaymentMethod,Notes,OriginalSms,BankTransactionId');

    for (final tx in transactions) {
      final dateStr = tx.transactionDate.toIso8601String();
      final type = tx.type;
      final amount = tx.amount.toStringAsFixed(2);
      final merchant = _escapeCsv(tx.merchant ?? '');
      final category = _escapeCsv(categoryMap[tx.categoryId] ?? '');
      final method = _escapeCsv(tx.paymentMethod ?? 'Cash');
      final notes = _escapeCsv(tx.notes ?? '');
      final originalSms = _escapeCsv(tx.originalSms ?? '');
      final ref = _escapeCsv(tx.bankTransactionId ?? '');

      buffer.writeln('$dateStr,$type,$amount,$merchant,$category,$method,$notes,$originalSms,$ref');
    }

    final dir = await getInternalBackupDirectory();
    final fileName = 'montra_transactions_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File(p.join(dir.path, fileName));
    await file.writeAsString(buffer.toString(), flush: true);

    try {
      final extDir = await getExternalBackupDirectory();
      if (extDir != null) {
        final extFile = File(p.join(extDir.path, fileName));
        await extFile.writeAsString(buffer.toString(), flush: true);
      }
    } catch (_) {}

    return file;
  }

  /// Imports transactions from a CSV file
  Future<RestoreResult> importFromCsv(File file, {bool clearExisting = false}) async {
    try {
      final content = await file.readAsString();
      final lines = const LineSplitter().convert(content);
      if (lines.isEmpty) {
        return RestoreResult(success: false, message: 'CSV file is empty.');
      }

      final header = _parseCsvLine(lines.first);
      final headerLower = header.map((h) => h.trim().toLowerCase()).toList();

      int dateIdx = headerLower.indexOf('date');
      int typeIdx = headerLower.indexOf('type');
      int amountIdx = headerLower.indexOf('amount');
      int merchantIdx = headerLower.indexOf('merchant');
      int categoryIdx = headerLower.indexOf('category');
      int methodIdx = headerLower.indexOf('paymentmethod');
      if (methodIdx == -1) methodIdx = headerLower.indexOf('payment method');
      if (methodIdx == -1) methodIdx = headerLower.indexOf('payment_method');
      int notesIdx = headerLower.indexOf('notes');
      int smsIdx = headerLower.indexOf('originalsms');
      if (smsIdx == -1) smsIdx = headerLower.indexOf('original sms');
      int refIdx = headerLower.indexOf('banktransactionid');
      if (refIdx == -1) refIdx = headerLower.indexOf('rrn');
      if (refIdx == -1) refIdx = headerLower.indexOf('ref');

      if (amountIdx == -1) {
        return RestoreResult(success: false, message: 'Invalid CSV: "Amount" column not found.');
      }

      if (clearExisting) {
        await _db.delete(_db.transactionTags).go();
        await _db.delete(_db.transactions).go();
      }

      final existingAccounts = await _db.select(_db.accounts).get();
      int defaultAccountId;
      if (existingAccounts.isEmpty) {
        defaultAccountId = await _db.into(_db.accounts).insert(
          AccountsCompanion.insert(bankName: 'Primary Account'),
        );
      } else {
        defaultAccountId = existingAccounts.first.id;
      }

      final existingCategories = await _db.select(_db.categories).get();
      final Map<String, int> catMap = {
        for (var c in existingCategories) c.name.toLowerCase(): c.id,
      };

      int importedCount = 0;

      await _db.transaction(() async {
        for (int i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;

          final cols = _parseCsvLine(line);
          if (cols.length <= amountIdx) continue;

          final amountStr = cols[amountIdx].replaceAll(',', '').replaceAll('Rs', '').replaceAll('INR', '').replaceAll('₹', '').trim();
          final amount = double.tryParse(amountStr);
          if (amount == null || amount <= 0) continue;

          final type = (typeIdx != -1 && typeIdx < cols.length && cols[typeIdx].trim().isNotEmpty)
              ? (cols[typeIdx].trim().toLowerCase() == 'income' ? 'Income' : 'Expense')
              : 'Expense';

          final merchant = (merchantIdx != -1 && merchantIdx < cols.length)
              ? cols[merchantIdx].trim()
              : '';

          final categoryName = (categoryIdx != -1 && categoryIdx < cols.length)
              ? cols[categoryIdx].trim()
              : '';

          int? categoryId;
          if (categoryName.isNotEmpty) {
            final catLower = categoryName.toLowerCase();
            if (catMap.containsKey(catLower)) {
              categoryId = catMap[catLower];
            } else {
              final newCatId = await _db.into(_db.categories).insert(
                CategoriesCompanion.insert(
                  name: categoryName,
                  type: type,
                ),
              );
              catMap[catLower] = newCatId;
              categoryId = newCatId;
            }
          }

          DateTime date = DateTime.now();
          if (dateIdx != -1 && dateIdx < cols.length) {
            final dStr = cols[dateIdx].trim();
            final parsedDate = DateTime.tryParse(dStr);
            if (parsedDate != null) date = parsedDate;
          }

          final method = (methodIdx != -1 && methodIdx < cols.length && cols[methodIdx].trim().isNotEmpty)
              ? cols[methodIdx].trim()
              : 'Cash';

          final notes = (notesIdx != -1 && notesIdx < cols.length) ? cols[notesIdx].trim() : null;
          final sms = (smsIdx != -1 && smsIdx < cols.length) ? cols[smsIdx].trim() : null;
          final bankTxnId = (refIdx != -1 && refIdx < cols.length) ? cols[refIdx].trim() : null;

          await _db.into(_db.transactions).insert(
            TransactionsCompanion.insert(
              amount: amount,
              type: type,
              merchant: drift.Value(merchant.isNotEmpty ? merchant : null),
              categoryId: drift.Value(categoryId),
              accountId: defaultAccountId,
              paymentMethod: drift.Value(method),
              transactionDate: date,
              notes: drift.Value(notes?.isNotEmpty == true ? notes : null),
              originalSms: drift.Value(sms?.isNotEmpty == true ? sms : null),
              bankTransactionId: drift.Value(bankTxnId?.isNotEmpty == true ? bankTxnId : null),
            ),
          );
          importedCount++;
        }
      });

      _db.notifyUpdates({
        drift.TableUpdate.onTable(_db.transactions),
        drift.TableUpdate.onTable(_db.categories),
      });

      return RestoreResult(
        success: true,
        message: 'Successfully imported $importedCount transactions from CSV file.',
        restoredTransactions: importedCount,
      );
    } catch (e) {
      return RestoreResult(success: false, message: 'CSV import error: $e');
    }
  }

  /// Universal import dispatcher that handles ANY file format (JSON, CSV, or custom)
  Future<RestoreResult> importAnyFile(File file, {bool clearExisting = false}) async {
    final ext = p.extension(file.path).toLowerCase();

    if (ext == '.csv') {
      return importFromCsv(file, clearExisting: clearExisting);
    }

    // Try parsing as JSON first (covers .json, .montra, .txt)
    try {
      final content = await file.readAsString();
      final dynamic decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic> && decoded.containsKey('tables')) {
        return restoreFromFile(file, clearExisting: clearExisting);
      }
    } catch (_) {}

    // Fallback: check if content is structured as CSV
    try {
      final content = await file.readAsString();
      if (content.contains(',') && content.contains('\n')) {
        return importFromCsv(file, clearExisting: clearExisting);
      }
    } catch (_) {}

    return RestoreResult(
      success: false,
      message: 'Could not recognize the format of "${p.basename(file.path)}". Please choose a valid Montra JSON backup or CSV file.',
    );
  }

  String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++; // skip escaped quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}

