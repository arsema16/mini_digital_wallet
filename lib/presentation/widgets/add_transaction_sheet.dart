// lib/presentation/widgets/add_transaction_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/transaction_model.dart';
import '../bloc/transaction/transaction_bloc.dart';

class AddTransactionSheet extends StatefulWidget {
  final String initialType;
  const AddTransactionSheet({super.key, this.initialType = 'expense'});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _refIdController = TextEditingController();

  late String _selectedType;
  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'Telebirr';

  static const _expenseCategories = [
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  static const _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other',
  ];

  static const _paymentMethods = [
    'Telebirr',
    'CBE Birr',
    'Amole',
    'HelloCash',
    'Cash',
    'Bank Transfer',
  ];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _selectedCategory = _selectedType == 'income' ? 'Salary' : 'Food';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _refIdController.dispose();
    super.dispose();
  }

  List<String> get _categories =>
      _selectedType == 'income' ? _incomeCategories : _expenseCategories;

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final tx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        category: _selectedCategory,
        paymentMethod: _selectedPaymentMethod,
        refId: _refIdController.text.trim().isNotEmpty
            ? _refIdController.text.trim()
            : 'REF${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      context.read<TransactionBloc>().add(AddTransaction(tx));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
          left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
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
              const SizedBox(height: 20),
              const Text(
                'Add Transaction',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2A3E)),
              ),
              const SizedBox(height: 20),
              // Type selector
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: 'Expense',
                      icon: Icons.trending_down,
                      color: Colors.red,
                      isSelected: _selectedType == 'expense',
                      onTap: () => setState(() {
                        _selectedType = 'expense';
                        _selectedCategory = 'Food';
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: 'Income',
                      icon: Icons.trending_up,
                      color: Colors.green,
                      isSelected: _selectedType == 'income',
                      onTap: () => setState(() {
                        _selectedType = 'income';
                        _selectedCategory = 'Salary';
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Title
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration(
                    label: 'Title', icon: Icons.title_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: 'Amount (birr)',
                  icon: Icons.attach_money,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Amount is required';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null) return 'Enter a valid number';
                  if (parsed <= 0) return 'Amount must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: _inputDecoration(
                    label: 'Category', icon: Icons.category_outlined),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              // Payment method
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: _inputDecoration(
                    label: 'Payment method', icon: Icons.payment_outlined),
                items: _paymentMethods
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPaymentMethod = v!),
              ),
              const SizedBox(height: 12),
              // Reference ID (optional)
              TextFormField(
                controller: _refIdController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: _inputDecoration(
                  label: 'Reference ID (optional)',
                  icon: Icons.receipt_long_outlined,
                ),
              ),
              const SizedBox(height: 24),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedType == 'income'
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add ${_selectedType == 'income' ? 'Income' : 'Expense'}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDE1E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF54B998), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade100,
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? color : Colors.grey.shade500, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
