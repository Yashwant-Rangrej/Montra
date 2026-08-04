import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/transaction_entity.dart';
import 'repository_providers.dart';

final transactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getAllTransactions();
});

final dashboardStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final transactions = await ref.watch(transactionsProvider.future);
  
  double totalIncome = 0;
  double totalExpense = 0;
  
  for (var tx in transactions) {
    if (tx.type == 'Income') {
      totalIncome += tx.amount;
    } else if (tx.type == 'Expense') {
      totalExpense += tx.amount;
    }
  }
  
  return {
    'income': totalIncome,
    'expense': totalExpense,
    'balance': totalIncome - totalExpense,
  };
});
