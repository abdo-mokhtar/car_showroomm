import '../core/utils/subscription_helper.dart';

void main() {
  // ✅ توليد كود سنوي
  print('=== أكواد سنوية ===');
  final yearlyCodes = SubscriptionHelper.generateBatch(
    count: 5,
    plan: 'yearly',
    year: 2026,
  );
  for (final code in yearlyCodes) {
    print(code);
  }

  print('');
  print('=== أكواد شهرية ===');
  final monthlyCodes = SubscriptionHelper.generateBatch(
    count: 5,
    plan: 'monthly',
    year: 2026,
  );
  for (final code in monthlyCodes) {
    print(code);
  }
}
