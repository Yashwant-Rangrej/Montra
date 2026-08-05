import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/transaction_entity.dart';
import 'repository_providers.dart';

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
  
  double todayIncome = 0;
  double todayExpense = 0;
  double monthlyIncome = 0;
  double monthlyExpense = 0;

  final now = DateTime.now();
  
  // Track the most recent availableBalance per bank, and subsequent income/expense for that bank
  Map<String, double> bankLatestBalance = {};
  Map<String, DateTime> bankLatestBalanceDate = {};
  
  // Track total income/expense per bank as a fallback if no availableBalance is found
  Map<String, double> bankTotalIncome = {};
  Map<String, double> bankTotalExpense = {};

  for (var tx in transactions) {
    if (tx.type == 'Income') {
      if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
        monthlyIncome += tx.amount;
        if (tx.transactionDate.day == now.day) {
          todayIncome += tx.amount;
        }
      }
      bankTotalIncome[tx.bankName] = (bankTotalIncome[tx.bankName] ?? 0) + tx.amount;
    } else if (tx.type == 'Expense') {
      if (tx.transactionDate.year == now.year && tx.transactionDate.month == now.month) {
        monthlyExpense += tx.amount;
        if (tx.transactionDate.day == now.day) {
          todayExpense += tx.amount;
        }
      }
      bankTotalExpense[tx.bankName] = (bankTotalExpense[tx.bankName] ?? 0) + tx.amount;
    }
    
    // Check if this transaction has an available balance and is newer than our recorded one
    if (tx.availableBalance != null) {
      final recordedDate = bankLatestBalanceDate[tx.bankName];
      if (recordedDate == null || tx.transactionDate.isAfter(recordedDate)) {
        bankLatestBalance[tx.bankName] = tx.availableBalance!;
        bankLatestBalanceDate[tx.bankName] = tx.transactionDate;
      }
    }
  }
  
  // Now, calculate the current balance for each bank.
  // For each bank, we either take its most recently reported availableBalance 
  // and add/subtract any transactions that happened AFTER that date,
  // OR we just take its total income - total expense.
  double totalBalance = 0;
  
  final allBanks = {...bankTotalIncome.keys, ...bankTotalExpense.keys, ...bankLatestBalance.keys};
  
  for (final bank in allBanks) {
    if (bankLatestBalance.containsKey(bank)) {
      final baseBalance = bankLatestBalance[bank]!;
      final baseDate = bankLatestBalanceDate[bank]!;
      
      double subsequentIncome = 0;
      double subsequentExpense = 0;
      
      for (var tx in transactions.where((t) => t.bankName == bank && t.transactionDate.isAfter(baseDate))) {
         if (tx.type == 'Income') subsequentIncome += tx.amount;
         if (tx.type == 'Expense') subsequentExpense += tx.amount;
      }
      
      totalBalance += (baseBalance + subsequentIncome - subsequentExpense);
    } else {
      // Fallback: just Income - Expense for this bank
      final inc = bankTotalIncome[bank] ?? 0;
      final exp = bankTotalExpense[bank] ?? 0;
      totalBalance += (inc - exp);
    }
  }
  
  // The overall total income and expense across all time
  double totalAllTimeIncome = bankTotalIncome.values.fold(0, (a, b) => a + b);
  double totalAllTimeExpense = bankTotalExpense.values.fold(0, (a, b) => a + b);
  
  return {
    'income': totalAllTimeIncome,
    'expense': totalAllTimeExpense,
    'balance': totalBalance,
    'todayIncome': todayIncome,
    'todayExpense': todayExpense,
    'monthlyIncome': monthlyIncome,
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
