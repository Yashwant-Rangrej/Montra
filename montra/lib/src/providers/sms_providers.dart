import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:montra/src/services/sms/sms_service.dart';
import 'package:montra/src/services/sms/sms_processor.dart';
import 'repository_providers.dart';
import 'notification_providers.dart';

final smsProcessorProvider = Provider<SmsProcessor>((ref) {
  final db = ref.watch(databaseProvider);
  final notificationManager = ref.watch(notificationManagerProvider);
  return SmsProcessor(db, notificationManager);
});

final smsServiceProvider = Provider<SmsService>((ref) {
  final processor = ref.watch(smsProcessorProvider);
  return SmsService(processor);
});
