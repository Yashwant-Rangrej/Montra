import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../providers/repository_providers.dart';
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
  String _bankName = 'Cash';
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
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Transaction'),
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
                    initialValue: '',
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
                      TextFormField(
                        initialValue: _bankName,
                        decoration: const InputDecoration(labelText: 'Bank / Source'),
                        onChanged: (val) => _bankName = val,
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      categoriesAsync.when(
                        data: (categories) {
                          final filtered = categories.where((c) => c.type == _type).toList();
                          return DropdownButtonFormField<int>(
                            initialValue: _categoryId,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: filtered.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) => setState(() => _categoryId = val),
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

      final repo = ref.read(transactionRepositoryProvider);
      
      final transaction = TransactionEntity(
        id: 0, 
        amount: _amount,
        type: _type,
        merchant: _merchant,
        notes: _notes,
        bankName: _bankName,
        availableBalance: null, // manual transactions don't set available balance
        categoryId: _categoryId,
        paymentMethod: _paymentMethod,
        transactionDate: _date,
        receiptAttachment: _receiptAttachment?.path,
      );
      
      await repo.insertTransaction(transaction);
      
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
