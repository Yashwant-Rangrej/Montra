import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../providers/repository_providers.dart';
import '../../providers/categories_provider.dart';
import '../../providers/transactions_provider.dart';
import '../../providers/unrecognized_sms_provider.dart';
import '../../providers/backup_providers.dart';
import '../../data/repositories/notification_repository.dart';
import '../../services/notifications/notification_manager.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionEntity? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _type = 'Expense';
  double _amount = 0.0;
  String _merchant = '';
  String _notes = '';
  int? _accountId;
  int? _categoryId;
  bool _isCustomCategory = false;
  String _customCategoryName = '';
  String? _paymentMethod = 'Cash';
  File? _receiptAttachment;
  DateTime _date = DateTime.now();

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.transactionToEdit != null) {
      final t = widget.transactionToEdit!;
      _type = t.type;
      _amount = t.amount;
      _merchant = t.merchant ?? '';
      _notes = t.notes ?? '';
      _accountId = t.accountId;
      _categoryId = t.categoryId;
      _paymentMethod = (t.originalSms != null && (t.paymentMethod == null || t.paymentMethod == 'Cash'))
          ? 'UPI'
          : (t.paymentMethod ?? 'Cash');
      _date = t.transactionDate;
      if (t.receiptAttachment != null) {
        _receiptAttachment = File(t.receiptAttachment!);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptAttachment = File(image.path);
      });
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && mounted) {
      setState(() {
        _date = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          _date.hour,
          _date.minute,
          _date.second,
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    );
    if (pickedTime != null && mounted) {
      setState(() {
        _date = DateTime(
          _date.year,
          _date.month,
          _date.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'New Transaction' : 'Edit Transaction'),
        backgroundColor: _type == 'Expense' ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
        foregroundColor: _type == 'Expense' ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onSecondary,
      ),
      body: Container(
        color: _type == 'Expense' ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.secondary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How much?', style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _type == 'Expense' ? Theme.of(context).colorScheme.onTertiary.withValues(alpha: 0.7) : Theme.of(context).colorScheme.onSecondary.withValues(alpha: 0.7)
                  )),
                  TextFormField(
                    initialValue: _amount > 0 ? _amount.toStringAsFixed(2) : '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: _type == 'Expense' ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onSecondary
                    ),
                    decoration: InputDecoration(
                      prefixText: '₹ ',
                      prefixStyle: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: _type == 'Expense' ? Theme.of(context).colorScheme.onTertiary : Theme.of(context).colorScheme.onSecondary
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      fillColor: Colors.transparent,
                    ),
                    onChanged: (val) => _amount = double.tryParse(val) ?? 0.0,
                    validator: (val) => (double.tryParse(val ?? '') ?? 0.0) <= 0 ? 'Enter valid amount' : null,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: ['Expense', 'Transfer']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _type = val;
                              _categoryId = null; // reset category on type change
                              _isCustomCategory = false;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _merchant,
                        decoration: const InputDecoration(labelText: 'Merchant / Description'),
                        onChanged: (val) => _merchant = val,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      categoriesAsync.when(
                        data: (categories) {
                          final filtered = categories.where((c) => c.type == _type).toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<int>(
                                initialValue: _categoryId,
                                decoration: const InputDecoration(labelText: 'Category'),
                                items: [
                                  ...filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                                  const DropdownMenuItem(value: -1, child: Text('Other')),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _categoryId = val;
                                    _isCustomCategory = val == -1;
                                  });
                                },
                              ),
                              if (_isCustomCategory) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Custom Category Name'),
                                  onChanged: (val) => _customCategoryName = val,
                                  validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                                ),
                              ],
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, _) => const Text('Error loading categories'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentMethod,
                        decoration: const InputDecoration(labelText: 'Payment Method'),
                        items: {'Cash', 'UPI', 'Card', 'Bank Transfer', ?_paymentMethod}
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _paymentMethod = val),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_outlined,
                                  size: 18,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Transaction Date & Time',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Spacer(),
                                if (DateTime.now().difference(_date).abs() > const Duration(minutes: 5))
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _date = DateTime.now();
                                      });
                                    },
                                    child: Text(
                                      'Reset to Now',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: InkWell(
                                    onTap: _pickDate,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_outlined,
                                            size: 16,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              DateFormat('EEE, dd MMM yyyy').format(_date),
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: InkWell(
                                    onTap: _pickTime,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.25),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            size: 16,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              DateFormat('hh:mm a').format(_date),
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _notes,
                        decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                        onChanged: (val) => _notes = val,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.receipt),
                        title: Text(_receiptAttachment != null ? 'Receipt attached' : 'Add receipt attachment'),
                        trailing: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickImage,
                        ),
                        onTap: _pickImage,
                      ),
                      if (_receiptAttachment != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Image.file(_receiptAttachment!, height: 100),
                        ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveTransaction,
                        child: const Text('Continue'),
                      ),
                      if (widget.transactionToEdit != null) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _deleteTransaction,
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('Delete Transaction'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      int? finalCategoryId = _categoryId;
      final categoryRepo = ref.read(categoryRepositoryProvider);

      if (_isCustomCategory && _customCategoryName.trim().isNotEmpty) {
        final newCategory = CategoryEntity(
          id: 0,
          name: _customCategoryName.trim(),
          type: _type,
          color: '#9E9E9E',
          icon: 'category',
        );
        finalCategoryId = await categoryRepo.insertCategory(newCategory);
        ref.invalidate(categoriesProvider);
      } else if (_categoryId == -1) {
        finalCategoryId = null;
      }

      final repo = ref.read(transactionRepositoryProvider);
      
      final transaction = TransactionEntity(
        id: widget.transactionToEdit?.id ?? 0, 
        amount: _amount,
        type: _type,
        merchant: _merchant,
        notes: _notes,
        accountId: _accountId ?? 1,
        availableBalance: widget.transactionToEdit?.availableBalance, // preserve existing or null
        categoryId: finalCategoryId,
        paymentMethod: _paymentMethod,
        transactionDate: _date,
        receiptAttachment: _receiptAttachment?.path,
        originalSms: widget.transactionToEdit?.originalSms,
        bankTransactionId: widget.transactionToEdit?.bankTransactionId,
      );
      
      if (widget.transactionToEdit == null) {
        await repo.insertTransaction(transaction);
        
        // --- Notification Triggers for Real Testing ---
        final manager = ref.read(notificationManagerProvider);
        
        // 1. Large Expense Alert (Trigger based on custom threshold)
        final threshold = ref.read(notificationRepositoryProvider).getSettings().largeExpenseThreshold;
        if (_type == 'Expense' && _amount >= threshold) {
          manager.showLargeExpenseAlert(
            merchant: _merchant.isEmpty ? 'Unknown Merchant' : _merchant,
            amount: _amount,
            method: _paymentMethod ?? 'Unknown Method',
          );
        }

        // 2. Budget Alert (Trigger based on spending milestones)
        if (_type == 'Expense' && finalCategoryId != null) {
          final budgetRepo = ref.read(budgetRepositoryProvider);
          final transactionRepo = ref.read(transactionRepositoryProvider);
          final now = DateTime.now();
          // Only check budgets for the CURRENT month
          final budgets = await budgetRepo.getBudgetsByMonthAndYear(now.month, now.year);
          final allTransactions = await transactionRepo.getAllTransactions();
          // Only count expenses from the CURRENT month
          final currentMonthTransactions = allTransactions.where((t) =>
              t.type == 'Expense' &&
              t.transactionDate.year == now.year &&
              t.transactionDate.month == now.month).toList();

          for (var budget in budgets) {
            if (budget.categoryId == finalCategoryId || budget.categoryId == null) {
              // Sum expenses for this category (or overall if budget.categoryId is null)
              final spent = currentMonthTransactions
                  .where((t) => budget.categoryId == null || t.categoryId == finalCategoryId)
                  .fold(0.0, (sum, t) => sum + t.amount);

              final percent = spent / budget.amount;
              final prevPercent = (spent - _amount) / budget.amount;

              if (percent > 1.0 && prevPercent <= 1.0) {
                manager.showBudgetAlert(
                  budgetName: 'Budget Limit Crossed!',
                  used: spent,
                  remaining: 0,
                );
              } else if (percent >= 1.0 && prevPercent < 1.0) {
                manager.showBudgetAlert(
                  budgetName: 'Budget Reached (100%)',
                  used: spent,
                  remaining: 0,
                );
              } else if (percent >= 0.95 && prevPercent < 0.95) {
                manager.showBudgetAlert(
                  budgetName: 'Budget Critical (95%)',
                  used: spent,
                  remaining: budget.amount - spent,
                );
              } else if (percent >= 0.80 && prevPercent < 0.80) {
                manager.showBudgetAlert(
                  budgetName: 'Budget Warning (80%)',
                  used: spent,
                  remaining: budget.amount - spent,
                );
              } else if (percent >= 0.50 && prevPercent < 0.50) {
                manager.showBudgetAlert(
                  budgetName: 'Half Budget Reached (50%)',
                  used: spent,
                  remaining: budget.amount - spent,
                );
              } else if (percent > 1.0) {
                // Remind them if they keep adding expenses while already over limit
                manager.showBudgetAlert(
                  budgetName: 'Still Over Budget!',
                  used: spent,
                  remaining: 0,
                );
              }
            }
          }
        }
      } else {
        await repo.updateTransaction(transaction);
      }
      
      // If this transaction was restored from an ignored SMS, remove it from the ignored list.
      final originalSms = widget.transactionToEdit?.originalSms;
      if (originalSms != null && widget.transactionToEdit?.id == 0) {
        try {
          await ref
              .read(unrecognizedSmsNotifierProvider.notifier)
              .deleteByOriginalBody(originalSms);
        } catch (_) {}
      }
      
      // Invalidate to refresh all relevant lists and stats immediately
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.read(backupServiceProvider).triggerAutoBackupIfEnabled();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  void _deleteTransaction() async {
    if (widget.transactionToEdit != null) {
      final repo = ref.read(transactionRepositoryProvider);
      await repo.deleteTransaction(widget.transactionToEdit!.id);
      
      ref.invalidate(transactionsProvider);
      ref.invalidate(dashboardStatsProvider);
      ref.read(backupServiceProvider).triggerAutoBackupIfEnabled();
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
