import 'dart:math';

class SubscriptionHelper {
  // ✅ توليد كود تفعيل
  static String generateCode({
    String plan = 'yearly', // yearly / monthly
    int year = 2026,
  }) {
    final random = Random();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final part1 =
        List.generate(4, (i) => chars[random.nextInt(chars.length)]).join();
    final part2 =
        List.generate(4, (i) => chars[random.nextInt(chars.length)]).join();
    final planCode = plan == 'yearly' ? 'Y' : 'M';
    return 'SHW-$planCode$year-$part1-$part2';
  }

  // ✅ فك تشفير الكود
  static Map<String, dynamic>? decodeCode(String code) {
    try {
      final parts = code.split('-');
      if (parts.length != 4) return null;
      if (parts[0] != 'SHW') return null;

      final planYear = parts[1];
      final plan = planYear[0] == 'Y' ? 'yearly' : 'monthly';
      final year = int.tryParse(planYear.substring(1));
      if (year == null) return null;

      return {
        'plan': plan,
        'year': year,
        'valid': true,
      };
    } catch (e) {
      return null;
    }
  }

  // ✅ حساب تاريخ الانتهاء
  static String calculateEndDate(String plan) {
    final now = DateTime.now();
    final end = plan == 'yearly'
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(now.year, now.month + 1, now.day);
    return end.toIso8601String().substring(0, 10);
  }

  // ✅ توليد أكواد متعددة
  static List<String> generateBatch({
    int count = 10,
    String plan = 'yearly',
    int year = 2026,
  }) {
    return List.generate(count, (_) => generateCode(plan: plan, year: year));
  }
}
