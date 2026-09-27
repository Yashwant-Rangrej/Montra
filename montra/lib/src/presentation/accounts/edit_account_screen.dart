import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account_entity.dart';
import '../../providers/repository_providers.dart';
import '../../providers/accounts_provider.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  final AccountEntity account;

  const EditAccountScreen({super.key, required this.account});

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.bankName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    final updated = widget.account.copyWith(bankName: newName);
    await ref.read(accountRepositoryProvider).updateAccount(updated);
    ref.invalidate(accountsProvider);
    if (mounted) Navigator.pop(context);
  }

  void _hide() async {
    final updated = widget.account.copyWith(isHidden: true);
    await ref.read(accountRepositoryProvider).updateAccount(updated);
    ref.invalidate(accountsProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Account')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Account Name'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Changes'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _hide,
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              child: const Text('Hide Account'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await ref.read(accountRepositoryProvider).deleteAccount(widget.account.id);
                ref.invalidate(accountsProvider);
                if (mounted) Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}
