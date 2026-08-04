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
  double todayIncome = 0;
  double todayExpense = 0;
  double monthlyIncome = 0;
  double monthlyExpense = 0;

  final now = DateTime.now();

  for (var tx in transactions) {
    if (tx.type == 'Income') {
      totalIncome += tx.amount;
      if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
        monthlyIncome += tx.amount;
        if (tx.transactionDate.day == now.day) {
          todayIncome += tx.amount;
        }
      }
    } else if (tx.type == 'Expense') {
      totalExpense += tx.amount;
      if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
        monthlyExpense += tx.amount;
        if (tx.transactionDate.day == now.day) {
          todayExpense += tx.amount;
        }
      }
    }
  }
  
  return {
    'income': totalIncome,
    'expense': totalExpense,
    'balance': totalIncome - totalExpense,
    'todayIncome': todayIncome,
    'todayExpense': todayExpense,
    'monthlyIncome': monthlyIncome,
    'monthlyExpense': monthlyExpense,
  };
});
