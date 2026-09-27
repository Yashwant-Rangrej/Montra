import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/transaction_entity.dart';
import 'repository_providers.dart';
import 'accounts_provider.dart';

final transactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getAllTransactions();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = FutureProvider<List<TransactionEntity>>((ref) async {
  final transactions = await ref.watch(transactionsProvider.future);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return transactions;
  }

  return transactions.where((tx) {
    final merchant = tx.merchant?.toLowerCase() ?? '';
    final notes = tx.notes?.toLowerCase() ?? '';
    final type = tx.type.toLowerCase();
    
    return merchant.contains(query) || notes.contains(query) || type.contains(query);
  }).toList();
});

final dashboardStatsProvider = FutureProvider<Map<String, double>>((ref) async {
  final transactions = await ref.watch(transactionsProvider.future);
  
  double todayExpense = 0;
  double monthlyExpense = 0;
  double totalExpense = 0;

  final now = DateTime.now();

  for (var tx in transactions) {
    if (tx.type.toLowerCase() == 'expense') {
      if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
        monthlyExpense += tx.amount;
        if (tx.transactionDate.day == now.day) {
          todayExpense += tx.amount;
        }
      }
      totalExpense += tx.amount;
    }
  }
  
  return {
    'balance': totalExpense, // Total spend
    'todayExpense': todayExpense,
    'monthlyExpense': monthlyExpense,
  };
});

final merchantIntelligenceProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final transactions = await ref.watch(transactionsProvider.future);
  
  final Map<String, int> visitFrequency = {};
  final Map<String, double> totalSpent = {};

  for (var tx in transactions) {
    if (tx.type == 'Expense' && tx.merchant != null && tx.merchant!.isNotEmpty) {
      final merchant = tx.merchant!;
      visitFrequency[merchant] = (visitFrequency[merchant] ?? 0) + 1;
      totalSpent[merchant] = (totalSpent[merchant] ?? 0) + tx.amount;
    }
  }

  String mostFrequentMerchant = 'None';
  int maxVisits = 0;
  visitFrequency.forEach((merchant, visits) {
    if (visits > maxVisits) {
      maxVisits = visits;
      mostFrequentMerchant = merchant;
    }
  });

  String topSpendingMerchant = 'None';
  double maxSpent = 0;
  totalSpent.forEach((merchant, spent) {
    if (spent > maxSpent) {
      maxSpent = spent;
      topSpendingMerchant = merchant;
    }
  });

  return {
    'mostFrequentMerchant': mostFrequentMerchant,
    'maxVisits': maxVisits,
    'topSpendingMerchant': topSpendingMerchant,
    'maxSpent': maxSpent,
  };
});
