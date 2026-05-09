import 'base_repository.dart';

class SubscriptionRepository extends BaseRepository {
  // ✅ الاشتراك الحالي
  Future<Map<String, dynamic>?> getActiveSubscription() async {
    return execute(() async {
      final database = await db;
      final result = await database.query(
        'subscriptions',
        where: 'is_active = 1',
        orderBy: 'id DESC',
        limit: 1,
      );
      if (result.isEmpty) return null;
      return result.first;
    });
  }

  // ✅ تفعيل اشتراك جديد
  Future<int> activateSubscription({
    required String code,
    required String plan,
    required String endDate,
  }) async {
    return execute(() async {
      final database = await db;
      final now = DateTime.now().toIso8601String().substring(0, 10);
      return await database.insert('subscriptions', {
        'activation_code': code,
        'start_date': now,
        'end_date': endDate,
        'plan': plan,
        'is_active': 1,
        'activated_at': DateTime.now().toIso8601String(),
      });
    });
  }

  // ✅ التحقق من صلاحية الاشتراك
  Future<bool> isSubscriptionValid() async {
    return execute(() async {
      final subscription = await getActiveSubscription();
      if (subscription == null) return false;
      final endDate = DateTime.parse(subscription['end_date']);
      return DateTime.now().isBefore(endDate);
    });
  }

  // ✅ أيام متبقية
  Future<int> getRemainingDays() async {
    return execute(() async {
      final subscription = await getActiveSubscription();
      if (subscription == null) return 0;
      final endDate = DateTime.parse(subscription['end_date']);
      final remaining = endDate.difference(DateTime.now()).inDays;
      return remaining > 0 ? remaining : 0;
    });
  }
}
