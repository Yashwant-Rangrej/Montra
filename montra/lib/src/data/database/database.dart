import 'package:drift/drift.dart';
import 'connection/connection.dart' as impl;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Accounts, Categories, Transactions, Budgets, Notifications, Settings, Tags, TransactionTags, UnrecognizedSms, SavedSummaries, NotificationSettingsDb])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? impl.openConnection());

  @override
  int get schemaVersion => 10;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // 1. Create performance indexes on frequently filtered/sorted columns
        try {
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_bank_tx_id ON transactions(bank_transaction_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets(month, year);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_unrecognized_sms_date ON unrecognized_sms(received_at DESC);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_notifications_date ON notifications(notification_date DESC);');
        } catch (_) {}

        // 2. Default payment method trigger: SMS detected defaults to UPI, manual to Cash
        try {
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS trg_transactions_default_payment_method
            AFTER INSERT ON transactions
            FOR EACH ROW
            WHEN NEW.payment_method IS NULL OR NEW.payment_method = ''
            BEGIN
              UPDATE transactions
              SET payment_method = CASE
                WHEN NEW.original_sms IS NOT NULL THEN 'UPI'
                ELSE 'Cash'
              END
              WHERE id = NEW.id;
            END;
          ''');
        } catch (_) {}
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
        if (from < 8) {
          try {
            await m.createTable(notificationSettingsDb);
            await into(notificationSettingsDb).insert(
              NotificationSettingsDbCompanion.insert(),
            );
          } catch (_) {}
        }
        if (from < 9) {
          try {
            await customStatement(
              "UPDATE transactions SET payment_method = 'UPI' WHERE original_sms IS NOT NULL AND (payment_method IS NULL OR payment_method = '' OR (payment_method = 'Cash' AND original_sms NOT LIKE '%atm%' AND original_sms NOT LIKE '%cash withdrawal%' AND original_sms NOT LIKE '%withdrawn%'));",
            );
            await customStatement(
              "UPDATE transactions SET payment_method = 'Cash' WHERE original_sms IS NULL AND (payment_method IS NULL OR payment_method = '');",
            );
            await customStatement('''
              CREATE TRIGGER IF NOT EXISTS trg_transactions_default_payment_method
              AFTER INSERT ON transactions
              FOR EACH ROW
              WHEN NEW.payment_method IS NULL OR NEW.payment_method = ''
              BEGIN
                UPDATE transactions
                SET payment_method = CASE
                  WHEN NEW.original_sms IS NOT NULL THEN 'UPI'
                  ELSE 'Cash'
                END
                WHERE id = NEW.id;
              END;
            ''');
          } catch (_) {}
        }
        if (from < 10) {
          try {
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_bank_tx_id ON transactions(bank_transaction_id);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets(month, year);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_unrecognized_sms_date ON unrecognized_sms(received_at DESC);');
            await customStatement('CREATE INDEX IF NOT EXISTS idx_notifications_date ON notifications(notification_date DESC);');
          } catch (_) {}
        }
      },
      beforeOpen: (details) async {
        // WAL mode: better crash-safety and concurrent read performance
        await customStatement('PRAGMA journal_mode=WAL;');
        // Enforce foreign key constraints
        await customStatement('PRAGMA foreign_keys=ON;');

        // Ensure performance indexes exist
        try {
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions(transaction_date DESC);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions(category_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions(account_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_transactions_bank_tx_id ON transactions(bank_transaction_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets(month, year);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_unrecognized_sms_date ON unrecognized_sms(received_at DESC);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_notifications_date ON notifications(notification_date DESC);');
        } catch (_) {}

        // Ensure database satisfies payment method requirements
        try {
          await customStatement(
            "UPDATE transactions SET payment_method = 'UPI' WHERE original_sms IS NOT NULL AND (payment_method IS NULL OR payment_method = '' OR (payment_method = 'Cash' AND original_sms NOT LIKE '%atm%' AND original_sms NOT LIKE '%cash withdrawal%' AND original_sms NOT LIKE '%withdrawn%'));",
          );
          await customStatement(
            "UPDATE transactions SET payment_method = 'Cash' WHERE original_sms IS NULL AND (payment_method IS NULL OR payment_method = '');",
          );
          await customStatement('''
            CREATE TRIGGER IF NOT EXISTS trg_transactions_default_payment_method
            AFTER INSERT ON transactions
            FOR EACH ROW
            WHEN NEW.payment_method IS NULL OR NEW.payment_method = ''
            BEGIN
              UPDATE transactions
              SET payment_method = CASE
                WHEN NEW.original_sms IS NOT NULL THEN 'UPI'
                ELSE 'Cash'
              END
              WHERE id = NEW.id;
            END;
          ''');
        } catch (_) {}
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
