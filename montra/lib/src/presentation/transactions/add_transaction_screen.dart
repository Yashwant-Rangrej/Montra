import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../providers/repository_providers.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/categories_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

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
  String? _paymentMethod;
  File? _receiptAttachment;
  final DateTime _date = DateTime.now();

  final ImagePicker _picker = ImagePicker();

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
    final accountsAsync = ref.watch(accountsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
        backgroundColor: _type == 'Expense' ? AppTheme.expense : AppTheme.income,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: _type == 'Expense' ? AppTheme.expense : AppTheme.income,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('How much?', style: TextStyle(color: Colors.white70, fontSize: 18)),
                  TextFormField(
                    initialValue: '',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      border: InputBorder.none,
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
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: ['Expense', 'Income', 'Transfer']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _type = val;
                              _categoryId = null; // reset category on type change
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Merchant / Description'),
                        onChanged: (val) => _merchant = val,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      accountsAsync.when(
                        data: (accounts) {
                          if (accounts.isEmpty) return const Text('No accounts found. Please create one.');
                          // Auto select first if null
                          if (_accountId == null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(() => _accountId = accounts.first.id);
                            });
                          }
                          return DropdownButtonFormField<int>(
                            value: _accountId,
                            decoration: const InputDecoration(labelText: 'Account'),
                            items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                            onChanged: (val) => setState(() => _accountId = val),
                            validator: (val) => val == null ? 'Select an account' : null,
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading accounts'),
                      ),
                      const SizedBox(height: 16),
                      categoriesAsync.when(
                        data: (categories) {
                          final filtered = categories.where((c) => c.type == _type).toList();
                          return DropdownButtonFormField<int>(
                            value: _categoryId,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) => setState(() => _categoryId = val),
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (_, __) => const Text('Error loading categories'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(labelText: 'Payment Method'),
                        items: ['Cash', 'Credit Card', 'Debit Card', 'UPI', 'Bank Transfer']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _paymentMethod = val),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
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
      if (_accountId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an account')));
        return;
      }

      final repo = ref.read(transactionRepositoryProvider);
      
      final transaction = TransactionEntity(
        id: 0, 
        amount: _amount,
        type: _type,
        merchant: _merchant,
        notes: _notes,
        accountId: _accountId!,
        categoryId: _categoryId,
        paymentMethod: _paymentMethod,
        transactionDate: _date,
        receiptAttachment: _receiptAttachment?.path,
      );
      
      await repo.insertTransaction(transaction);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
