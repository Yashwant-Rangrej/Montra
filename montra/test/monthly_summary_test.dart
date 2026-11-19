import 'package:flutter_test/flutter_test.dart';
import 'package:montra/src/data/database/database.dart';
import 'package:montra/src/services/monthly_summary_service.dart';
import 'package:montra/src/services/notifications/notification_manager.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

class MockNotificationManager implements NotificationManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late MockNotificationManager notifManager;
  late MonthlySummaryService service;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    notifManager = MockNotificationManager();
    service = MonthlySummaryService(db, notifManager);

    // Insert dummy account
    await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        bankName: 'Primary Bank',
      ),
      mode: drift.InsertMode.insertOrIgnore,
    );

    // Insert categories
    await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        id: const drift.Value(1),
        name: 'Food & Dining',
        type: 'Expense',
        icon: const drift.Value('restaurant'),
        color: const drift.Value('#E53935'),
      ),
      mode: drift.InsertMode.insertOrIgnore,
    );
    await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        id: const drift.Value(2),
        name: 'Shopping',
        type: 'Expense',
        icon: const drift.Value('shopping_bag'),
        color: const drift.Value('#1E88E5'),
      ),
      mode: drift.InsertMode.insertOrIgnore,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('Monthly Summary Isolation & Precision Tests', () {
    test('Calculates statistics strictly for the specified month only', () async {
      // 1. Transaction in November 2026 (Expense ₹500)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          amount: 500.0,
          type: 'Expense',
          merchant: const drift.Value('Swiggy'),
          categoryId: const drift.Value(1),
          accountId: 1,
          transactionDate: DateTime(2026, 11, 15, 14, 30),
          paymentMethod: const drift.Value('UPI'),
        ),
      );

      // 2. Another transaction in November 2026 (Expense ₹1500)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          amount: 1500.0,
          type: 'Expense',
          merchant: const drift.Value('Amazon'),
          categoryId: const drift.Value(2),
          accountId: 1,
          transactionDate: DateTime(2026, 11, 20, 18, 0),
          paymentMethod: const drift.Value('Card'),
        ),
      );

      // 3. Income in November 2026 (Income ₹5000)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          amount: 5000.0,
          type: 'Income',
          merchant: const drift.Value('Freelance'),
          accountId: 1,
          transactionDate: DateTime(2026, 11, 1, 10, 0),
          paymentMethod: const drift.Value('Bank'),
        ),
      );

      // 4. Transaction in October 2026 (Should NOT be in November stats)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          amount: 9999.0,
          type: 'Expense',
          merchant: const drift.Value('October Phone'),
          categoryId: const drift.Value(2),
          accountId: 1,
          transactionDate: DateTime(2026, 10, 31, 23, 59),
        ),
      );

      // 5. Transaction in December 2026 (Should NOT be in November stats)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          amount: 7777.0,
          type: 'Expense',
          merchant: const drift.Value('December Holiday'),
          categoryId: const drift.Value(2),
          accountId: 1,
          transactionDate: DateTime(2026, 12, 1, 0, 1),
        ),
      );

      // 6. Ignored transaction in November 2026 (Should NOT count in totals)
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          amount: 8888.0,
          type: 'Ignored',
          merchant: const drift.Value('Spam Loan'),
          accountId: 1,
          transactionDate: DateTime(2026, 11, 10, 12, 0),
        ),
      );

      // Compute stats for November 2026
      final novStats = await service.computeStatsForMonth(11, 2026);
      expect(novStats, isNotNull);
      expect(novStats!['month'], equals(11));
      expect(novStats['year'], equals(2026));

      // Strictly November totals:
      // Total Expense: 500 + 1500 = 2000.0
      expect(novStats['totalExpense'], equals(2000.0));
      // Total Income: 5000.0
      expect(novStats['totalIncome'], equals(5000.0));
      // Net Savings: 5000 - 2000 = 3000.0
      expect(novStats['netSavings'], equals(3000.0));
      // Transaction counts
      expect(novStats['txCount'], equals(2));
      expect(novStats['incomeCount'], equals(1));
      // Days in November: 30
      expect(novStats['daysInMonth'], equals(30));
      // Daily average: 2000 / 30 = 66.666...
      expect(novStats['dailyAverage'], closeTo(66.67, 0.1));

      // Category breakdown
      final categories = novStats['categoryBreakdown'] as List<dynamic>;
      expect(categories.length, equals(2));
      expect(categories[0]['name'], equals('Shopping'));
      expect(categories[0]['amount'], equals(1500.0));
      expect(categories[1]['name'], equals('Food & Dining'));
      expect(categories[1]['amount'], equals(500.0));

      // Top Merchant
      expect(novStats['topMerchant'], equals('Amazon'));
      expect(novStats['topMerchantAmount'], equals(1500.0));

      // All Transactions count for November (2 expenses + 1 income = 3 total)
      final allMonthTx = novStats['allTransactions'] as List<dynamic>;
      expect(allMonthTx.length, equals(3));
      for (final tx in allMonthTx) {
        final date = tx['date'] as DateTime;
        expect(date.month, equals(11));
        expect(date.year, equals(2026));
      }
    });

    test('Returns zeroed structured stats for months with no transactions without crashing', () async {
      final emptyStats = await service.computeStatsForMonth(5, 2025);
      expect(emptyStats, isNotNull);
      expect(emptyStats!['month'], equals(5));
      expect(emptyStats['year'], equals(2025));
      expect(emptyStats['totalExpense'], equals(0.0));
      expect(emptyStats['totalIncome'], equals(0.0));
      expect(emptyStats['netSavings'], equals(0.0));
      expect(emptyStats['txCount'], equals(0));
      expect(emptyStats['incomeCount'], equals(0));
      expect(emptyStats['allTransactions'], isEmpty);
      expect(emptyStats['categoryBreakdown'], isEmpty);
    });
  });
}
