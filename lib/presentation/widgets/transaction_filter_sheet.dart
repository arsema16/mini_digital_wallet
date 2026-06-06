import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/format_utils.dart';

class ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const ActiveFilterChip({super.key, required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryDark,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

class TransactionSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  TransactionSearchDelegate({required this.onSearch});

  @override
  String get searchFieldLabel => 'Search by title, category, ref…';

  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            onSearch('');
          },
        ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () {
          onSearch('');
          close(context, null);
        },
      );

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }
}

void showFilterSheet({
  required BuildContext context,
  required String? selectedType,
  required String? selectedCategory,
  required DateTimeRange? selectedDateRange,
  required void Function(String?, String?, DateTimeRange?) onApply,
}) {
  String? tempType = selectedType;
  String? tempCategory = selectedCategory;
  DateTimeRange? tempDateRange = selectedDateRange;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheet) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Filter Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const Text('Type',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'All', label: Text('All')),
                ButtonSegment(value: 'income', label: Text('Income')),
                ButtonSegment(value: 'expense', label: Text('Expense')),
              ],
              selected: {tempType ?? 'All'},
              onSelectionChanged: (s) =>
                  setSheet(() => tempType = s.first == 'All' ? null : s.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.primary;
                  return null;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return null;
                }),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Category',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: tempCategory ?? 'All',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: AppConstants.allCategories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) =>
                  setSheet(() => tempCategory = v == 'All' ? null : v),
            ),
            const SizedBox(height: 16),
            const Text('Date Range',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.date_range_outlined, size: 16),
                    label: Text(
                      tempDateRange == null
                          ? 'Select range'
                          : '${FormatUtils.formatShortDate(tempDateRange!.start)} – ${FormatUtils.formatShortDate(tempDateRange!.end)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: ctx,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        builder: (c, child) => Theme(
                          data: Theme.of(c).copyWith(
                            colorScheme: const ColorScheme.light(
                                primary: AppColors.primary),
                          ),
                          child: child!,
                        ),
                      );
                      if (range != null) setSheet(() => tempDateRange = range);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (tempDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () => setSheet(() => tempDateRange = null),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setSheet(() {
                      tempType = null;
                      tempCategory = null;
                      tempDateRange = null;
                    }),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onApply(tempType, tempCategory, tempDateRange);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
