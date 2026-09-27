import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../providers/repository_providers.dart';
import '../../providers/categories_provider.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/transactions_provider.dart';
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
  String? _paymentMethod;
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
      _paymentMethod = t.paymentMethod;
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final accountsAsync = ref.watch(accountsProvider);

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
                      accountsAsync.when(
                        data: (accounts) {
                          final visibleAccounts = accounts.where((a) => !a.isHidden).toList();
                          if (visibleAccounts.isEmpty) return const Text('No accounts found. They will appear automatically from SMS.');
                          return DropdownButtonFormField<int>(
                            initialValue: _accountId,
                            decoration: const InputDecoration(labelText: 'Bank Account'),
                            items: visibleAccounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.bankName))).toList(),
                            onChanged: (val) => setState(() => _accountId = val),
                            validator: (val) => val == null ? 'Select an account' : null,
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, _) => const Text('Error loading accounts'),
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
                        items: ['Cash', 'Credit Card', 'Debit Card', 'UPI', 'Bank Transfer']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _paymentMethod = val),
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
                      )
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
      if (_accountId == null) return;

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
        accountId: _accountId!,
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
        
        // 1. Large Expense Alert (Trigger if amount >= 10,000)
        if (_type == 'expense' && _amount >= 10000) {
          manager.showLargeExpenseAlert(
            merchant: _merchant.isEmpty ? 'Unknown Merchant' : _merchant,
            amount: _amount,
            method: _paymentMethod ?? 'Unknown Method',
          );
        }

        // 2. Budget Alert (Basic Check)
        if (_type == 'expense' && finalCategoryId != null) {
          final budgetRepo = ref.read(budgetRepositoryProvider);
          final budgets = await budgetRepo.getAllBudgets();
          for (var budget in budgets) {
            if (budget.categoryId == finalCategoryId) {
              manager.showBudgetAlert(
                budgetName: 'Category Budget',
                used: _amount, // In a real app, this would sum up all category expenses
                remaining: budget.amount - _amount,
              );
            }
          }
        }
      } else {
        await repo.updateTransaction(transaction);
        // Also invalidate to refresh list
        ref.invalidate(transactionsProvider);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
