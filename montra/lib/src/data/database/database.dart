import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets, Notifications, Settings, Tags, TransactionTags, UnrecognizedSms, SavedSummaries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.openConnection());

  @override
  int get schemaVersion => 7;

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
          try {
            await customStatement('ALTER TABLE "budgets" ADD COLUMN "start_date" INTEGER NULL;');
          } catch (_) {}
          try {
            await customStatement('ALTER TABLE "budgets" ADD COLUMN "end_date" INTEGER NULL;');
          } catch (_) {}
        }
        if (from < 7) {
          try {
            await m.createTable(savedSummaries);
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        // WAL mode: better crash-safety and concurrent read performance
        await customStatement('PRAGMA journal_mode=WAL;');
        // Enforce foreign key constraints
        await customStatement('PRAGMA foreign_keys=ON;');
      },
    );
  }

  /// Clear every table — full app reset.
  Future<void> clearAllData() async {
    await transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
    await runMaintenance();
  }

  /// Delete all transactions (keeps budgets, categories, settings).
  Future<void> clearTransactions() async {
    await transaction(() async {
      await delete(transactions).go();
    });
    await runMaintenance();
  }

  /// Delete transactions older than the current month.
  Future<void> clearMonthlyHistory() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    await transaction(() async {
      await (delete(transactions)
        ..where((t) => t.transactionDate.isSmallerThanValue(startOfMonth))
      ).go();
    });
    await runMaintenance();
  }

  /// VACUUM reclaims freed pages; ANALYZE updates query-planner statistics.
  Future<void> runMaintenance() async {
    await customStatement('PRAGMA optimize;');
    await customStatement('VACUUM;');
    await customStatement('ANALYZE;');
  }
}
