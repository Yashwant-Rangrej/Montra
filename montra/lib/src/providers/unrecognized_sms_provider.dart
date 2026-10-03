import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database.dart';
import 'repository_providers.dart';

/// Watches all unrecognized/ignored SMS records from the database.
final unrecognizedSmsProvider = StreamProvider<List<UnrecognizedSm>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.unrecognizedSms)
        ..orderBy([(t) => OrderingTerm.desc(t.receivedAt)]))
      .watch();
});

/// Notifier for managing unrecognized SMS: delete single or delete all.
class UnrecognizedSmsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> deleteById(int id) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.unrecognizedSms)..where((t) => t.id.equals(id))).go();
    ref.invalidate(unrecognizedSmsProvider);
  }

  Future<void> deleteByOriginalBody(String body) async {
    final db = ref.read(databaseProvider);
    await (db.delete(db.unrecognizedSms)..where((t) => t.body.equals(body))).go();
    ref.invalidate(unrecognizedSmsProvider);
  }

  Future<void> deleteAll() async {
    final db = ref.read(databaseProvider);
    await db.delete(db.unrecognizedSms).go();
    ref.invalidate(unrecognizedSmsProvider);
  }
}

final unrecognizedSmsNotifierProvider =
    AsyncNotifierProvider<UnrecognizedSmsNotifier, void>(
        UnrecognizedSmsNotifier.new);
