import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets, Notifications, Settings, Tags, TransactionTags, UnrecognizedSms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(transactions, transactions.receiptAttachment);
        }
        if (from < 3) {
          // Add new columns using raw statements to avoid compile errors before generation
          await customStatement('CREATE TABLE IF NOT EXISTS goals (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, target_amount REAL NOT NULL, saved_amount REAL NOT NULL DEFAULT 0.0, target_date INTEGER, color TEXT, icon TEXT, created_at INTEGER NOT NULL);');
        }
        if (from < 4) {
          // Add new columns using raw statements to avoid compile errors before generation
          await customStatement('ALTER TABLE transactions ADD COLUMN bank_name TEXT NOT NULL DEFAULT "Manual";');
          await customStatement('ALTER TABLE transactions ADD COLUMN available_balance REAL;');
          // Drop accounts table raw query to avoid drift knowing about it
          await customStatement('DROP TABLE IF EXISTS accounts;');
        }
        if (from < 5) {
          // Create new Accounts table
          try {
            await m.createTable(accounts);
          } catch (_) {}
          // Restore accountId in transactions, drop bankName if we could. Since sqlite doesn't easily drop, we just add accountId.
          try {
            await customStatement('ALTER TABLE transactions ADD COLUMN account_id INTEGER NOT NULL DEFAULT 1;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE transactions ADD COLUMN target_account_id INTEGER;');
          } catch (_) {}
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'montra.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
