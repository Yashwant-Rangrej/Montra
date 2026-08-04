import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entities/account_entity.dart';
import '../../providers/accounts_provider.dart';
import '../../providers/repository_providers.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  const AddAccountScreen({super.key});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _name = '';
  String _type = 'Bank';
  double _initialBalance = 0.0;

  final List<String> _accountTypes = ['Bank', 'Cash', 'Credit Card', 'Wallet', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Account Name'),
                onChanged: (val) => _name = val,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Account Type'),
                items: _accountTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) => setState(() => _type = val ?? 'Bank'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Initial Balance'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (val) => _initialBalance = double.tryParse(val) ?? 0.0,
                validator: (val) => (double.tryParse(val ?? '') == null) ? 'Enter valid number' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAccount,
                child: const Text('Save Account'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveAccount() async {
    if (_formKey.currentState!.validate()) {
      final repo = ref.read(accountRepositoryProvider);
      final account = AccountEntity(
        id: 0,
        name: _name,
        type: _type,
        initialBalance: _initialBalance,
        createdAt: DateTime.now(),
      );
      
      await repo.insertAccount(account);
      ref.invalidate(accountsProvider);

      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
