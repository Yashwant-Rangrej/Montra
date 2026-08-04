import '../../data/database/database.dart';
import '../../domain/entities/parsed_transaction.dart';
import 'package:drift/drift.dart';

class DuplicateDetector {
  final AppDatabase _db;

  DuplicateDetector(this._db);

  /// Checks if the transaction already exists in the database.
  /// Uses a time window and amount/merchant similarity or reference number.
  Future<bool> isDuplicate(ParsedTransaction transaction) async {
    if (transaction.referenceNumber != null) {
      // Direct match on reference number if available
      final existingRef = await (_db.select(_db.transactions)
            ..where((t) => t.bankTransactionId.equals(transaction.referenceNumber!))
            ..limit(1))
          .getSingleOrNull();
      
      if (existingRef != null) return true;
    }

    // Time window matching (e.g., within 5 minutes)
    final fiveMinsBefore = transaction.transactionDate.subtract(const Duration(minutes: 5));
    final fiveMinsAfter = transaction.transactionDate.add(const Duration(minutes: 5));

    final matches = await (_db.select(_db.transactions)
          ..where((t) => 
            t.amount.equals(transaction.amount) &
            t.transactionDate.isBetweenValues(fiveMinsBefore, fiveMinsAfter) &
            t.type.equals(transaction.transactionType)
          )
          ..limit(1))
        .getSingleOrNull();

    return matches != null;
  }
}
