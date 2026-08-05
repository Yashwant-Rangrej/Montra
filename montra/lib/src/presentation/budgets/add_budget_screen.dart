import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? budgetToEdit;

  const AddBudgetScreen({super.key, this.budgetToEdit});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  int? _selectedCategoryId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    if (widget.budgetToEdit != null) {
      _amount = widget.budgetToEdit!.amount;
      _selectedCategoryId = widget.budgetToEdit!.categoryId;
      _selectedMonth = widget.budgetToEdit!.month;
      _selectedYear = widget.budgetToEdit!.year;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.budgetToEdit == null ? 'Add Budget' : 'Edit Budget')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _amount > 0 ? _amount.toStringAsFixed(2) : '',
                decoration: const InputDecoration(labelText: 'Budget Amount (₹)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<int?>(
                    decoration: const InputDecoration(labelText: 'Category (Optional)'),
                    initialValue: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Overall (All Categories)')),
                      ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                    ],
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (e, st) => Text('Error loading categories: $e'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      
                      final budget = BudgetEntity(
                        id: widget.budgetToEdit?.id ?? 0,
                        amount: _amount,
                        month: _selectedMonth,
                        year: _selectedYear,
                        categoryId: _selectedCategoryId,
                      );
                      
                      if (widget.budgetToEdit == null) {
                        await ref.read(budgetRepositoryProvider).insertBudget(budget);
                      } else {
                        await ref.read(budgetRepositoryProvider).updateBudget(budget);
                        // Also invalidate to refresh list
                        ref.invalidate(budgetsProvider); // budgetsProgressProvider watches budgetsProvider
                      }
                      
                      if (context.mounted) context.pop();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Save Budget'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
