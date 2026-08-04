import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:montra/src/services/sms/sms_interceptor.dart';

final smsInterceptorProvider = Provider<SmsInterceptor>((ref) {
  return NativeSmsInterceptor();
});
