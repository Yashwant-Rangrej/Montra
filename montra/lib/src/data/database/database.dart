import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets, Notifications, Settings, Tags, TransactionTags, UnrecognizedSms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 6;

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
          await customStatement('CREATE TABLE IF NOT EXISTS goals (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, target_amount REAL NOT NULL, saved_amount REAL NOT NULL DEFAULT 0.0, target_date INTEGER, color TEXT, icon TEXT, created_at INTEGER NOT NULL);');
        }
        if (from < 4) {
          await customStatement('ALTER TABLE transactions ADD COLUMN bank_name TEXT NOT NULL DEFAULT "Manual";');
          await customStatement('ALTER TABLE transactions ADD COLUMN available_balance REAL;');
          await customStatement('DROP TABLE IF EXISTS accounts;');
        }
        if (from < 5) {
          try {
            await m.createTable(accounts);
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE transactions ADD COLUMN account_id INTEGER NOT NULL DEFAULT 1;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE transactions ADD COLUMN target_account_id INTEGER;');
          } catch (_) {}
        }
        if (from < 6) {
          await m.addColumn(budgets, budgets.startDate);
          await m.addColumn(budgets, budgets.endDate);
        }
      },
    );
  }
}

