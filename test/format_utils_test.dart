// test/format_utils_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_digital_wallet/core/utils/format_utils.dart';

void main() {
  group('FormatUtils', () {
    test('formatAmount formats with 2 decimal places and commas', () {
      expect(FormatUtils.formatAmount(1500.0), '1,500.00');
      expect(FormatUtils.formatAmount(0.5), '0.50');
      expect(FormatUtils.formatAmount(1234567.89), '1,234,567.89');
    });

    test('formatDate formats as dd MMM yyyy', () {
      final date = DateTime(2025, 6, 1);
      expect(FormatUtils.formatDate(date), '01 Jun 2025');
    });

    test('formatTime formats as HH:mm', () {
      final date = DateTime(2025, 6, 1, 9, 5);
      expect(FormatUtils.formatTime(date), '09:05');
    });

    test('formatShortDate formats as dd/MM/yyyy', () {
      final date = DateTime(2025, 6, 1);
      expect(FormatUtils.formatShortDate(date), '01/06/2025');
    });

    test('timeAgo returns "Just now" for recent times', () {
      final now = DateTime.now().subtract(const Duration(seconds: 10));
      expect(FormatUtils.timeAgo(now), 'Just now');
    });

    test('timeAgo returns minutes ago', () {
      final past = DateTime.now().subtract(const Duration(minutes: 5));
      expect(FormatUtils.timeAgo(past), '5m ago');
    });

    test('timeAgo returns hours ago', () {
      final past = DateTime.now().subtract(const Duration(hours: 3));
      expect(FormatUtils.timeAgo(past), '3h ago');
    });

    test('timeAgo returns Yesterday', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(FormatUtils.timeAgo(past), 'Yesterday');
    });
  });
}
