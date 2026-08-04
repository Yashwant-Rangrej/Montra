import 'sms_parser.dart';

class SbiParser extends BaseSmsParser {
  @override
  int get priority => 10;

  @override
  bool canParse(String sender, String body) {
    return sender.toUpperCase().contains('SBI');
  }

  @override
  ParsedTransaction? parse(String sender, String body, DateTime receivedAt) {
    // Example format: Dear Customer, Your a/c no. XXXXXXXX is debited by Rs.500.00 on 04-08-26. Info: UPI-XXXXXXXXX-SWIGGY.
    final amountMatch = RegExp(r'(?:debited by|withdrawn) Rs\.?\s?([0-9,]+(?:\.[0-9]+)?)', caseSensitive: false).firstMatch(body);
    final merchantMatch = RegExp(r'Info:\s?UPI-[A-Za-z0-9]+-([A-Za-z0-9\s]+)').firstMatch(body);
    final refMatch = RegExp(r'UPI-([A-Za-z0-9]+)-').firstMatch(body);

    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)?.replaceAll(',', '');
      final amount = double.tryParse(amountStr ?? '');
      if (amount != null) {
        return ParsedTransaction(
          amount: amount,
          merchant: merchantMatch?.group(1)?.trim() ?? 'Unknown',
          type: 'Expense',
          date: receivedAt,
          bankName: 'SBI',
          referenceNumber: refMatch?.group(1),
          paymentMethod: 'UPI',
        );
      }
    }
    return null;
  }
}

class HdfcParser extends BaseSmsParser {
  @override
  int get priority => 10;

  @override
  bool canParse(String sender, String body) {
    return sender.toUpperCase().contains('HDFC');
  }

  @override
  ParsedTransaction? parse(String sender, String body, DateTime receivedAt) {
    // Example: HDFC Bank: Rs 150.00 debited from a/c **1234 at ZOMATO on 04-08-26
    final amountMatch = RegExp(r'Rs\.?\s?([0-9,]+(?:\.[0-9]+)?)\s+debited', caseSensitive: false).firstMatch(body);
    final merchantMatch = RegExp(r'at\s+([A-Za-z0-9\s]+)\s+on').firstMatch(body);

    if (amountMatch != null) {
      final amountStr = amountMatch.group(1)?.replaceAll(',', '');
      final amount = double.tryParse(amountStr ?? '');
      if (amount != null) {
        return ParsedTransaction(
          amount: amount,
          merchant: merchantMatch?.group(1)?.trim() ?? 'Unknown',
          type: 'Expense',
          date: receivedAt,
          bankName: 'HDFC',
        );
      }
    }
    return null;
  }
}

class FallbackParser extends BaseSmsParser {
  @override
  int get priority => 1;

  @override
  bool canParse(String sender, String body) {
    return true;
  }

  @override
  ParsedTransaction? parse(String sender, String body, DateTime receivedAt) {
    // Generic heuristic parser
    final expenseKeywords = ['debited', 'spent', 'paid', 'withdrawn', 'sent'];
    final incomeKeywords = ['credited', 'received', 'added'];
    
    final lowerBody = body.toLowerCase();
    
    String? type;
    if (expenseKeywords.any((k) => lowerBody.contains(k))) {
      type = 'Expense';
    } else if (incomeKeywords.any((k) => lowerBody.contains(k))) {
      type = 'Income';
    } else {
      return null;
    }

    // Try to find an amount
    final amountMatch = RegExp(r'(?:rs\.?|inr)\s?([0-9,]+(?:\.[0-9]+)?)').firstMatch(lowerBody);
    if (amountMatch == null) return null;

    final amountStr = amountMatch.group(1)?.replaceAll(',', '');
    final amount = double.tryParse(amountStr ?? '');
    if (amount == null) return null;

    // Try to find a merchant (at XXX, to XXX, info: XXX)
    String merchant = 'Unknown';
    final toMatch = RegExp(r'to\s+([a-z0-9\s]+)(?:\s+on|\.)').firstMatch(lowerBody);
    final atMatch = RegExp(r'at\s+([a-z0-9\s]+)(?:\s+on|\.)').firstMatch(lowerBody);
    final upiMatch = RegExp(r'upi-[a-z0-9]+-([a-z0-9\s]+)').firstMatch(lowerBody);

    if (upiMatch != null) {
      merchant = upiMatch.group(1)?.trim() ?? 'Unknown';
    } else if (atMatch != null) {
      merchant = atMatch.group(1)?.trim() ?? 'Unknown';
    } else if (toMatch != null) {
      merchant = toMatch.group(1)?.trim() ?? 'Unknown';
    }

    return ParsedTransaction(
      amount: amount,
      merchant: _capitalizeFirst(merchant),
      type: type,
      date: receivedAt,
    );
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s.split(' ').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' ');
  }
}
