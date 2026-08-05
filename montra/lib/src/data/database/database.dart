import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Categories, Transactions, Budgets, Goals, Notifications, Settings, Tags, TransactionTags, UnrecognizedSms])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

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
          await m.createTable(goals);
        }
        if (from < 4) {
          // Note: In SQLite dropping a table is easy, but dropping a column requires table recreation or Drift's TableMigration.
          // Since this is local and we are fine with it, we use Drift's alterTable
          await m.alterTable(TableMigration(transactions, columnRemovals: [
            // Drift automatically handles column removals specified via schema diffs if we don't mention it,
            // but we can just add the new columns here and let drift handle the rest, or recreate.
          ]));
          await m.addColumn(transactions, transactions.bankName);
          await m.addColumn(transactions, transactions.availableBalance);
          // Drop accounts table raw query to avoid drift knowing about it
          await customStatement('DROP TABLE IF EXISTS accounts;');
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
