import 'package:flutter/material.dart';
import '../../../data/models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: const Color.fromARGB(255, 230, 229, 228),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header icon
            CircleAvatar(
              radius: 40,
              backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                size: 40,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            // Amount
            Text(
              '${isIncome ? '+' : '-'} ${transaction.amount.toStringAsFixed(2)} birr',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transaction.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            // Details card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _detailRow(Icons.category, 'Category', transaction.category),
                    const Divider(),
                    _detailRow(Icons.payment, 'Payment Method', transaction.paymentMethod ?? 'Not specified'),
                    const Divider(),
                    _detailRow(Icons.receipt, 'Reference ID', transaction.refId ?? 'N/A'),
                    const Divider(),
                    _detailRow(Icons.calendar_today, 'Date', _formatDate(transaction.createdAt)),
                    const Divider(),
                    _detailRow(Icons.access_time, 'Time', _formatTime(transaction.createdAt)),
                    const Divider(),
                    _detailRow(Icons.cloud_sync, 'Sync Status', transaction.isSynced ? 'Synced' : 'Pending sync'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Optional edit/delete buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Future edit
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Future delete
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
  String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}