import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/format_utils.dart';

class CategorySpendingCard extends StatelessWidget {
  final Map<String, double> spending;
  final double totalExpense;

  const CategorySpendingCard({
    super.key,
    required this.spending,
    required this.totalExpense,
  });

  static const List<Color> _palette = [
    Color(0xFF1A73E8),
    Color(0xFFEA4335),
    Color(0xFF34A853),
    Color(0xFFFBBC04),
    Color(0xFFFF6D00),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFF795548),
  ];

  @override
  Widget build(BuildContext context) {
    final sorted = spending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'Total: ${FormatUtils.formatAmount(totalExpense)} ETB',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  ...sorted.asMap().entries.map((entry) {
                    final pct = totalExpense > 0
                        ? entry.value.value / totalExpense
                        : 0.0;
                    return Flexible(
                      flex: (pct * 1000).round(),
                      child: Container(
                        color: _palette[entry.key % _palette.length],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          ...sorted.asMap().entries.map((entry) {
            final color = _palette[entry.key % _palette.length];
            final pct = totalExpense > 0
                ? (entry.value.value / totalExpense * 100)
                : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      entry.value.key,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '${FormatUtils.formatAmount(entry.value.value)} ETB',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
