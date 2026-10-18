import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:montra/src/services/sms/sms_parser.dart';
import 'package:montra/src/core/utils/category_icon_helper.dart';
import 'package:montra/src/data/database/database.dart';
import 'package:montra/src/data/repositories/transaction_repository_impl.dart';
import 'package:montra/src/domain/entities/transaction_entity.dart';

void main() {
  group('SmsParser Unit Tests', () {
    test('Parses debit SMS with amount and merchant correctly', () {
      const sms = 'Rs 450.00 debited from a/c **1234 on 02-Oct-26 at Starbucks via UPI ref 123456';
      final result = SmsParser.parseSms('HDFC-Bank', sms);

      expect(result, isNotNull);
      expect(result!.amount, 450.0);
      expect(result.type, 'Expense');
      expect(result.paymentMethod, 'UPI');
      expect(result.category, 'Food');
    });

    test('Parses HDFC Sent Rs UPI SMS with recipient and UPI paymentMethod', () {
      const sms = 'Sent Rs.1.00 From HDFC Bank A/C *4921 to Rohan Sharma on 13-10-26 via UPI Ref 628721381273.';
      final result = SmsParser.parseSms('JD-HDFCBN-S', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1.0);
      expect(result.type, 'Expense');
      expect(result.paymentMethod, 'UPI');
      expect(result.merchant, 'Rohan Sharma');
    });

    test('Ignores credit/deposit messages', () {
      const sms = 'INR 5,000.00 credited to your account on 01-Oct-26 by Employer';
      final result = SmsParser.parseSms('SBI-Bank', sms);

      expect(result, isNull);
    });

    test('Identifies card payments correctly', () {
      const sms = 'Paid Rs. 1,299 at Amazon using Credit Card on 03-Oct-26';
      final result = SmsParser.parseSms('ICICI', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1299.0);
      expect(result.paymentMethod, 'Card');
      expect(result.category, 'Shopping');
    });

    test('Categorizes transport and utilities properly', () {
      expect(SmsParser.categorizeMerchant('Uber Rides'), 'Transportation');
      expect(SmsParser.categorizeMerchant('Jio Recharge'), 'Utilities');
      expect(SmsParser.categorizeMerchant('Apollo Pharmacy'), 'Health');
      expect(SmsParser.categorizeMerchant('Netflix India'), 'Entertainment');
    });

    test('Parses IndusInd towards VPA SMS with Rs amount, balance, and RRN', () {
      const sms = 'A/C *XX1234 debited by Rs 1250.00 towards store-pay@upi. RRN:6227103. Avl Bal:254.77. Not you? Call 18602677777 - IndusInd bank';
      final result = SmsParser.parseSms('AD-INDUSB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1250.0);
      expect(result.merchant, 'store-pay@upi');
      expect(result.type, 'Expense');
      expect(result.paymentMethod, 'UPI');
      expect(result.availableBalance, 254.77);
      expect(result.referenceNumber, '6227103');
    });

    test('Parses IndusInd SMS even if sender is unknown because body has bank and financial structure', () {
      const sms = 'A/C *XX1234 debited by Rs 1250.00 towards store-pay@upi. RRN:6227103. Avl Bal:254.77. Not you? Call 18602677777 - IndusInd bank';
      final result = SmsParser.parseSms('UNKNOWN', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1250.0);
      expect(result.merchant, 'store-pay@upi');
      expect(result.paymentMethod, 'UPI');
    });

    test('Parses SBI transfer to UPI SMS with amount without currency symbol', () {
      const sms = 'Dear SBI UPI User, your A/C X3456 debited by 250.0 on 05Oct26 by transfer to SWIGGY (UPI Ref no 327819287319).';
      final result = SmsParser.parseSms('VK-SBIINB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 250.0);
      expect(result.merchant, 'Swiggy');
      expect(result.paymentMethod, 'UPI');
      expect(result.category, 'Food');
      expect(result.referenceNumber, '327819287319');
    });

    test('Parses Axis Bank towards VPA with Avl Bal', () {
      const sms = 'Your A/C no. XX3456 is debited for Rs.890.00 on 08-10-26 towards swiggy@icici. UPI Ref: 328472918. Avl Bal: INR 12,340.50.';
      final result = SmsParser.parseSms('AXISBK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 890.0);
      expect(result.merchant, 'swiggy@icici');
      expect(result.paymentMethod, 'UPI');
      expect(result.availableBalance, 12340.50);
      expect(result.referenceNumber, '328472918');
    });

    test('Parses Canara Bank in favour of merchant', () {
      const sms = 'Canara Bank: Rs 620.00 debited from A/c ...3214 on 12-10-26. In favour of Uber India via UPI ref 1234. Avl Bal: 3120.00';
      final result = SmsParser.parseSms('CANBNK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 620.0);
      expect(result.merchant, 'Uber India');
      expect(result.paymentMethod, 'UPI');
      expect(result.category, 'Transportation');
      expect(result.availableBalance, 3120.0);
    });

    test('Parses ICICI Bank Info BIL format for subscriptions', () {
      const sms = 'Acct XX123 debited with INR 500.00 on 09-Oct-26. Info: BIL*123456*Netflix. Available Balance is INR 23,450.00.';
      final result = SmsParser.parseSms('ICICIB', sms);

      expect(result, isNotNull);
      expect(result!.amount, 500.0);
      expect(result.merchant, 'Netflix');
      expect(result.category, 'Entertainment');
      expect(result.availableBalance, 23450.0);
    });

    test('Parses ATM cash withdrawal correctly', () {
      const sms = 'Rs 2,000.00 withdrawn from ATM using Debit Card XX1234 on 10-Oct-26. Avl Bal: Rs 15,000.00';
      final result = SmsParser.parseSms('HDFCBK', sms);

      expect(result, isNotNull);
      expect(result!.amount, 2000.0);
      expect(result.merchant, 'ATM Cash');
      expect(result.paymentMethod, 'Cash');
      expect(result.availableBalance, 15000.0);
    });
  });

  group('CategoryIconHelper Unit Tests', () {
    test('Returns corresponding IconData for standard categories', () {
      expect(CategoryIconHelper.getIcon('Food & Dining'), Icons.restaurant);
      expect(CategoryIconHelper.getIcon('Transportation'), Icons.directions_car);
      expect(CategoryIconHelper.getIcon('Shopping'), Icons.shopping_cart);
      expect(CategoryIconHelper.getIcon('Bills & Utilities'), Icons.receipt_long);
      expect(CategoryIconHelper.getIcon('Health & Medical'), Icons.local_hospital);
      expect(CategoryIconHelper.getIcon('Unknown'), Icons.category);
      expect(CategoryIconHelper.getIcon(null), Icons.shopping_bag);
    });
  });

  group('Database & Repository PaymentMethod Tests', () {
    late AppDatabase db;
    late TransactionRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = TransactionRepositoryImpl(db);
      // Insert default account (or ignore if automatically seeded)
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              bankName: 'Primary Account',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('SMS transaction with UPI stores and retrieves as UPI', () async {
      final tx = TransactionEntity(
        id: 0,
        amount: 250.0,
        type: 'Expense',
        merchant: 'Swiggy',
        paymentMethod: 'UPI',
        accountId: 1,
        transactionDate: DateTime.now(),
        originalSms: 'Sent Rs 250.00 to Swiggy via UPI Ref 12345678',
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.paymentMethod, 'UPI');
    });

    test('Manual transaction entered as Cash stores and retrieves as Cash', () async {
      final tx = TransactionEntity(
        id: 0,
        amount: 100.0,
        type: 'Expense',
        merchant: 'Local Vendor',
        paymentMethod: 'Cash',
        accountId: 1,
        transactionDate: DateTime.now(),
        originalSms: null,
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.paymentMethod, 'Cash');
    });

    test('Manual transaction without paymentMethod defaults to Cash', () async {
      final tx = TransactionEntity(
        id: 0,
        amount: 50.0,
        type: 'Expense',
        merchant: 'Snacks',
        paymentMethod: null,
        accountId: 1,
        transactionDate: DateTime.now(),
        originalSms: null,
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.paymentMethod, 'Cash');
    });

    test('SMS transaction without paymentMethod resolves to UPI', () async {
      final tx = TransactionEntity(
        id: 0,
        amount: 75.0,
        type: 'Expense',
        merchant: 'Tea Stall',
        paymentMethod: null,
        accountId: 1,
        transactionDate: DateTime.now(),
        originalSms: 'Paid Rs 75 at Tea Stall via UPI ref 999888',
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.paymentMethod, 'UPI');
    });

    test('SMS ATM cash withdrawal retains Cash', () async {
      final tx = TransactionEntity(
        id: 0,
        amount: 1000.0,
        type: 'Expense',
        merchant: 'ATM',
        paymentMethod: 'Cash',
        accountId: 1,
        transactionDate: DateTime.now(),
        originalSms: 'ATM cash withdrawal of Rs 1000 from ATM **1234',
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.paymentMethod, 'Cash');
    });
  });

  group('Transaction Date Customization Tests', () {
    late AppDatabase db;
    late TransactionRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = TransactionRepositoryImpl(db);
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              bankName: 'Primary Account',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('Transaction can be created with a customized past date and time', () async {
      final customDate = DateTime(2025, 5, 20, 14, 30);
      final tx = TransactionEntity(
        id: 0,
        amount: 350.0,
        type: 'Expense',
        merchant: 'Bookstore',
        paymentMethod: 'Card',
        accountId: 1,
        transactionDate: customDate,
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.transactionDate.year, 2025);
      expect(retrieved.transactionDate.month, 5);
      expect(retrieved.transactionDate.day, 20);
      expect(retrieved.transactionDate.hour, 14);
      expect(retrieved.transactionDate.minute, 30);
    });

    test('Existing transaction date and time can be customized after added', () async {
      final initialDate = DateTime(2026, 1, 10, 10, 0);
      final tx = TransactionEntity(
        id: 0,
        amount: 800.0,
        type: 'Expense',
        merchant: 'Grocery Mart',
        paymentMethod: 'UPI',
        accountId: 1,
        transactionDate: initialDate,
      );

      final id = await repository.insertTransaction(tx);
      final initialRetrieved = await repository.getTransactionById(id);
      expect(initialRetrieved!.transactionDate.day, 10);

      // Customize date after added
      final updatedDate = DateTime(2026, 2, 14, 18, 45);
      final updatedTx = initialRetrieved.copyWith(transactionDate: updatedDate);
      await repository.updateTransaction(updatedTx);

      final updatedRetrieved = await repository.getTransactionById(id);
      expect(updatedRetrieved, isNotNull);
      expect(updatedRetrieved!.transactionDate.year, 2026);
      expect(updatedRetrieved.transactionDate.month, 2);
      expect(updatedRetrieved.transactionDate.day, 14);
      expect(updatedRetrieved.transactionDate.hour, 18);
      expect(updatedRetrieved.transactionDate.minute, 45);
    });
  });

  group('Database Structure & Performance Index Tests', () {
    late AppDatabase db;
    late TransactionRepositoryImpl repository;

    setUp(() async {
      db = AppDatabase(NativeDatabase.memory());
      repository = TransactionRepositoryImpl(db);
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              bankName: 'Primary Account',
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('Database schema version is 10 and performance indices are active', () async {
      expect(db.schemaVersion, 10);

      // Verify indexes in sqlite_master
      final indexes = await db.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index' AND name LIKE 'idx_%'",
      ).get();

      final indexNames = indexes.map((row) => row.data['name'] as String).toSet();

      expect(indexNames.contains('idx_transactions_date'), isTrue);
      expect(indexNames.contains('idx_transactions_category'), isTrue);
      expect(indexNames.contains('idx_transactions_account'), isTrue);
      expect(indexNames.contains('idx_transactions_type'), isTrue);
      expect(indexNames.contains('idx_transactions_bank_tx_id'), isTrue);
      expect(indexNames.contains('idx_budgets_month_year'), isTrue);
      expect(indexNames.contains('idx_unrecognized_sms_date'), isTrue);
      expect(indexNames.contains('idx_notifications_date'), isTrue);
    });

    test('Receipt attachment path persists correctly on insert and update', () async {
      final tx = TransactionEntity(
        id: 0,
        amount: 499.0,
        type: 'Expense',
        merchant: 'Cafe Coffee Day',
        paymentMethod: 'UPI',
        accountId: 1,
        transactionDate: DateTime(2026, 10, 15, 14, 0),
        receiptAttachment: '/storage/receipts/bill_101.jpg',
      );

      final id = await repository.insertTransaction(tx);
      final retrieved = await repository.getTransactionById(id);

      expect(retrieved, isNotNull);
      expect(retrieved!.receiptAttachment, '/storage/receipts/bill_101.jpg');

      final updatedTx = retrieved.copyWith(receiptAttachment: '/storage/receipts/bill_102_updated.jpg');
      await repository.updateTransaction(updatedTx);

      final updatedRetrieved = await repository.getTransactionById(id);
      expect(updatedRetrieved!.receiptAttachment, '/storage/receipts/bill_102_updated.jpg');
    });
  });
}


