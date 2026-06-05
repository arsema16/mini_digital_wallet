// lib/presentation/pages/details/transaction_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../bloc/transaction/transaction_bloc.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction'),
        content:
            const Text('This transaction will be permanently deleted. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<TransactionBloc>()
                  .add(DeleteTransaction(transaction.id));
              Navigator.pop(context); // go back to list
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final typeColor = isIncome ? Colors.green.shade600 : Colors.red.shade600;
    final typeBg = isIncome ? Colors.green.shade50 : Colors.red.shade50;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E2A3E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      isIncome ? Icons.trending_up : Icons.trending_down,
                      size: 36,
                      color: typeColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} birr',
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
                        color: Color(0xFF1E2A3E)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isIncome ? 'Income' : 'Expense',
                      style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Details card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Category',
                    value: transaction.category,
                    isFirst: true,
                  ),
                  _DetailRow(
                    icon: Icons.payment_outlined,
                    label: 'Payment Method',
                    value: transaction.paymentMethod ?? 'Not specified',
                  ),
                  _DetailRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'Reference ID',
                    value: transaction.refId ?? 'N/A',
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: _formatDate(transaction.createdAt),
                  ),
                  _DetailRow(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: _formatTime(transaction.createdAt),
                  ),
                  _DetailRow(
                    icon: transaction.isSynced
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    label: 'Sync Status',
                    value: transaction.isSynced ? 'Synced' : 'Pending sync',
                    valueColor:
                        transaction.isSynced ? Colors.green : Colors.orange,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Delete button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete Transaction',
                    style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
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

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isFirst;
  final bool isLast;

  const _DetailRow({
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
          const Divider(height: 1, indent: 56, endIndent: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF54B998).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF54B998)),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: TextStyle(
                      color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1E2A3E),
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
