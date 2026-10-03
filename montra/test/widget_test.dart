import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:montra/src/services/sms/sms_parser.dart';
import 'package:montra/src/core/utils/category_icon_helper.dart';

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
}
