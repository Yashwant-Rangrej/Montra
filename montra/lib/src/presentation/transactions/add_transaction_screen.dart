import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/transaction_entity.dart';
import '../../../providers/repository_providers.dart';

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
  DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                            setState(() => _type = val);
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
                        decoration: const InputDecoration(labelText: 'Notes (Optional)'),
                        onChanged: (val) => _notes = val,
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
        id: 0, // Auto-incremented
        amount: _amount,
        type: _type,
        merchant: _merchant,
        notes: _notes,
        accountId: 1, // Default account for now
        transactionDate: _date,
      );
      
      await repo.insertTransaction(transaction);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
