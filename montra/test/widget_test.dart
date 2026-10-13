import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
      const sms = 'Sent Rs.1.00 From HDFC Bank A/C *8031 to Yashawant janardhanasa ra on 13-10-26 via UPI Ref 628721381273.';
      final result = SmsParser.parseSms('JD-HDFCBN-S', sms);

      expect(result, isNotNull);
      expect(result!.amount, 1.0);
      expect(result.type, 'Expense');
      expect(result.paymentMethod, 'UPI');
      expect(result.merchant, 'Yashawant janardhanasa ra');
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
      // Insert default account
      await db.into(db.accounts).insert(
            AccountsCompanion.insert(
              bankName: 'Primary Account',
            ),
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
}
