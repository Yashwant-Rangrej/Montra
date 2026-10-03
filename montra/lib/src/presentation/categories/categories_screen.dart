import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/categories_provider.dart';
import '../../providers/repository_providers.dart';
import '../../core/utils/category_icon_helper.dart';
import '../widgets/empty_state_widget.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.category_outlined,
              title: 'No Categories',
              message: 'Add custom categories to organize your expenses.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final color = category.color != null 
                  ? Color(int.parse(category.color!.replaceFirst('#', '0xFF'))) 
                  : Theme.of(context).colorScheme.primary;
              
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Icon(
                      CategoryIconHelper.getIcon(category.name),
                      color: color,
                    ),
                  ),
                  title: Text(category.name),
                  subtitle: Text(category.type),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          context.push('/add-category', extra: category);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Category'),
                              content: Text('Are you sure you want to delete ${category.name}?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true), 
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Delete')
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true) {
                            await ref.read(categoryRepositoryProvider).deleteCategory(category.id);
                            ref.invalidate(categoriesProvider);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-category'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
