import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/transaction_entity.dart';
import 'repository_providers.dart';

final allTransactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions();
});

final transactionsProvider = StreamProvider<List<TransactionEntity>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.watchTransactions().map((transactions) {
    final now = DateTime.now();
    return transactions.where((tx) => 
      tx.transactionDate.year == now.year && tx.transactionDate.month == now.month
    ).toList();
  });
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredTransactionsProvider = Provider<AsyncValue<List<TransactionEntity>>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase();

  return transactionsAsync.whenData((transactions) {
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
});

final dashboardStatsProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);
  
  return transactionsAsync.whenData((transactions) {
    double todayExpense = 0;
    double monthlyExpense = 0;
    double lastMonthExpense = 0;
    double totalExpense = 0;

    final now = DateTime.now();
    int lastMonth = now.month - 1;
    int lastMonthYear = now.year;
    if (lastMonth == 0) {
      lastMonth = 12;
      lastMonthYear -= 1;
    }

    for (var tx in transactions) {
      if (tx.type.toLowerCase() == 'expense') {
        if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
          monthlyExpense += tx.amount;
          if (tx.transactionDate.day == now.day) {
            todayExpense += tx.amount;
          }
        }
        if (tx.transactionDate.year == lastMonthYear && tx.transactionDate.month == lastMonth) {
          lastMonthExpense += tx.amount;
        }
        totalExpense += tx.amount;
      }
    }
    
    return {
      'balance': totalExpense, // Total spend
      'todayExpense': todayExpense,
      'monthlyExpense': monthlyExpense,
      'lastMonthExpense': lastMonthExpense,
    };
  });
});

final merchantIntelligenceProvider = Provider<AsyncValue<Map<String, dynamic>>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  
  return transactionsAsync.whenData((transactions) {
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
});

final monthlyExpensesProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final transactionsAsync = ref.watch(allTransactionsProvider);
  
  return transactionsAsync.whenData((transactions) {
    final Map<String, double> expensesByMonth = {};

    for (var tx in transactions) {
      if (tx.type.toLowerCase() == 'expense') {
        final monthKey = '${tx.transactionDate.year}-${tx.transactionDate.month.toString().padLeft(2, '0')}';
        expensesByMonth[monthKey] = (expensesByMonth[monthKey] ?? 0) + tx.amount;
      }
    }
    
    final sortedKeys = expensesByMonth.keys.toList()..sort((a, b) => b.compareTo(a));
    final Map<String, double> sortedMap = {};
    for (var key in sortedKeys) {
      sortedMap[key] = expensesByMonth[key]!;
    }
    return sortedMap;
  });
});
