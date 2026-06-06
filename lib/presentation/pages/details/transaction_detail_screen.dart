// lib/presentation/pages/details/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../data/models/transaction_model.dart';
import '../../bloc/transaction/transaction_bloc.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionDetailScreen({super.key, required this.transaction});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction'),
        content: const Text(
            'This transaction will be permanently deleted. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TransactionBloc>()
                  .add(DeleteTransaction(transaction.id));
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.expense)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final typeColor = isIncome ? AppColors.income : AppColors.expense;
    final typeBg = isIncome ? AppColors.incomeBg : AppColors.expenseBg;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Transaction Details',
            style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Amount card ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 36,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isIncome ? '+' : '-'}${FormatUtils.formatAmount(transaction.amount)} ETB',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction.title,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                          color: typeColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Details card ─────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  _Row(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: transaction.category,
                    isFirst: true,
                  ),
                  _Row(
                    icon: Icons.payment_outlined,
                    label: 'Payment Method',
                    value:
                        transaction.paymentMethod ?? 'Not specified',
                  ),
                  _Row(
                    icon: Icons.receipt_long_outlined,
                    label: 'Reference ID',
                    value: transaction.refId ?? 'N/A',
                  ),
                  _Row(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: FormatUtils.formatDate(transaction.createdAt),
                  ),
                  _Row(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: FormatUtils.formatTime(transaction.createdAt),
                  ),
                  _Row(
                    icon: transaction.isSynced
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    label: 'Sync Status',
                    value: transaction.isSynced
                        ? 'Synced with cloud'
                        : 'Pending sync',
                    valueColor: transaction.isSynced
                        ? AppColors.income
                        : Colors.orange,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Delete button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline,
                    color: AppColors.expense),
                label: const Text('Delete Transaction',
                    style: TextStyle(color: AppColors.expense)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.expense),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isFirst;
  final bool isLast;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!isFirst)
          const Divider(height: 1, indent: 60, endIndent: 0,
              color: AppColors.divider),
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon,
                    size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
