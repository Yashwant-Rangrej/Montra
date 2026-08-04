import 'package:montra/src/data/database/database.dart';

class DuplicateDetectionService {
  final AppDatabase _db;

  DuplicateDetectionService(this._db);

  /// Checks if a similar transaction already exists within a 5-minute window
  Future<bool> isDuplicate({
    required double amount,
    required String merchant,
    required DateTime date,
    String? bankTransactionId,
  }) async {
    // If we have an exact reference number, check that first
    if (bankTransactionId != null && bankTransactionId.isNotEmpty) {
      final exactMatch = await _db.customSelect(
        'SELECT COUNT(*) as c FROM transactions WHERE bank_transaction_id = ?',
        variables: [Variable.withString(bankTransactionId)],
      ).getSingle();
      
      if (exactMatch.read<int>('c') > 0) return true;
    }

    // Heuristic duplicate detection:
    // Same amount, same merchant (roughly), and timestamp within 5 minutes.
    
    // SQLite dates are unix timestamps in seconds, Drift stores DateTime as unix epoch seconds
    final startTime = (date.millisecondsSinceEpoch / 1000).floor() - 300; // 5 mins before
    final endTime = (date.millisecondsSinceEpoch / 1000).floor() + 300; // 5 mins after
    
    // We do a loose match on the merchant using LIKE
    final query = '''
      SELECT COUNT(*) as c FROM transactions 
      WHERE amount = ? 
      AND (merchant LIKE ? OR ? LIKE '%' || merchant || '%')
      AND transaction_date BETWEEN ? AND ?
    ''';
    
    final result = await _db.customSelect(
      query,
      variables: [
        Variable.withReal(amount),
        Variable.withString('%$merchant%'),
        Variable.withString(merchant),
        Variable.withInt(startTime),
        Variable.withInt(endTime)
      ],
    ).getSingle();

    return result.read<int>('c') > 0;
  }
}
