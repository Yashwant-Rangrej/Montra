import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  double _amount = 0.0;
  CategoryEntity? _selectedCategory;
  final int _selectedMonth = DateTime.now().month;
  final int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Budget')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Budget Amount (\$)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                onSaved: (value) => _amount = double.parse(value!),
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<CategoryEntity>(
                    decoration: const InputDecoration(labelText: 'Category (Optional)', border: OutlineInputBorder()),
                    initialValue: _selectedCategory,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Overall (All Categories)')),
                      ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    ],
                    onChanged: (val) => setState(() => _selectedCategory = val),
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
                        id: 0,
                        amount: _amount,
                        month: _selectedMonth,
                        year: _selectedYear,
                        categoryId: _selectedCategory?.id,
                      );
                      
                      await ref.read(budgetRepositoryProvider).insertBudget(budget);
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
