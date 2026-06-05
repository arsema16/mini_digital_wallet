// lib/presentation/pages/transactions/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../details/transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedType;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Food',
    'Shopping',
    'Transport',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  void _applyFilters() {
    context.read<TransactionBloc>().add(FilterTransactions(
          type: _selectedType,
          category: _selectedCategory,
          dateRange: _selectedDateRange,
          searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
        ));
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _selectedDateRange = null;
      _searchQuery = '';
    });
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedCategory != null ||
      _selectedDateRange != null ||
      _searchQuery.isNotEmpty;

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        String? tempType = _selectedType;
        String? tempCategory = _selectedCategory;
        DateTimeRange? tempDateRange = _selectedDateRange;

        return StatefulBuilder(builder: (ctx, setBottomState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              left: 24,
              right: 24,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                const Text('Filter Transactions',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                // Type
                const Text('Type',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF1E2A3E))),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'All', label: Text('All')),
                    ButtonSegment(value: 'income', label: Text('Income')),
                    ButtonSegment(value: 'expense', label: Text('Expense')),
                  ],
                  selected: {tempType ?? 'All'},
                  onSelectionChanged: (s) => setBottomState(
                      () => tempType = s.first == 'All' ? null : s.first),
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return const Color(0xFF54B998);
                      }
                      return null;
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // Category
                const Text('Category',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF1E2A3E))),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: tempCategory ?? 'All',
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setBottomState(
                      () => tempCategory = v == 'All' ? null : v),
                ),
                const SizedBox(height: 16),
                // Date range
                const Text('Date Range',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF1E2A3E))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.date_range, size: 16),
                        onPressed: () async {
                          final range = await showDateRangePicker(
                            context: ctx,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                    primary: Color(0xFF54B998)),
                              ),
                              child: child!,
                            ),
                          );
                          if (range != null) {
                            setBottomState(() => tempDateRange = range);
                          }
                        },
                        label: Text(
                          tempDateRange == null
                              ? 'Select range'
                              : '${_formatDate(tempDateRange!.start)} – ${_formatDate(tempDateRange!.end)}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    if (tempDateRange != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () =>
                            setBottomState(() => tempDateRange = null),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setBottomState(() {
                            tempType = null;
                            tempCategory = null;
                            tempDateRange = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
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
                          setState(() {
                            _selectedType = tempType;
                            _selectedCategory = tempCategory;
                            _selectedDateRange = tempDateRange;
                          });
                          _applyFilters();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF54B998),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E2A3E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: _TransactionSearchDelegate(
                onSearch: (q) => setState(() {
                  _searchQuery = q;
                  _applyFilters();
                }),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterSheet,
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF54B998),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: context.read<TransactionBloc>(),
            child: const AddTransactionSheet(),
          ),
        ),
        backgroundColor: const Color(0xFF54B998),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Active filter chips
          if (_hasActiveFilters)
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedType != null)
                            _FilterChip(
                              label: _selectedType!,
                              onRemove: () {
                                setState(() => _selectedType = null);
                                _applyFilters();
                              },
                            ),
                          if (_selectedCategory != null)
                            _FilterChip(
                              label: _selectedCategory!,
                              onRemove: () {
                                setState(() => _selectedCategory = null);
                                _applyFilters();
                              },
                            ),
                          if (_selectedDateRange != null)
                            _FilterChip(
                              label:
                                  '${_formatDate(_selectedDateRange!.start)} – ${_formatDate(_selectedDateRange!.end)}',
                              onRemove: () {
                                setState(() => _selectedDateRange = null);
                                _applyFilters();
                              },
                            ),
                          if (_searchQuery.isNotEmpty)
                            _FilterChip(
                              label: '"$_searchQuery"',
                              onRemove: () {
                                setState(() => _searchQuery = '');
                                _applyFilters();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearFilters,
                    child: const Text('Clear all',
                        style: TextStyle(
                            color: Colors.red, fontSize: 12)),
                  ),
                ],
              ),
            ),
          // List
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                if (state is TransactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(state.message),
                        behavior: SnackBarBehavior.floating),
                  );
                }
              },
              builder: (context, state) {
                if (state is TransactionInitial ||
                    state is TransactionLoading) {
                  return const TransactionListShimmer();
                } else if (state is TransactionLoaded) {
                  final txns = state.filteredTransactions;
                  if (txns.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions match your filters',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15),
                          ),
                          if (_hasActiveFilters) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters'),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<TransactionBloc>().add(LoadTransactions()),
                    color: const Color(0xFF54B998),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: txns.length,
                      itemBuilder: (ctx, i) =>
                          _buildTile(context, txns[i]),
                    ),
                  );
                } else if (state is TransactionError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const TransactionListShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, TransactionModel tx) {
    final isIncome = tx.type == 'income';
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(transaction: tx))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isIncome ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isIncome ? Icons.trending_up : Icons.trending_down,
                color:
                    isIncome ? Colors.green.shade600 : Colors.red.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E2A3E)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('${tx.category} • ${_formatDate(tx.createdAt)}',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${tx.amount.toStringAsFixed(2)} birr',
              style: TextStyle(
                  color:
                      isIncome ? Colors.green.shade600 : Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF54B998).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF54B998).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF3DA882),
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close,
                size: 14, color: Color(0xFF3DA882)),
          ),
        ],
      ),
    );
  }
}

class _TransactionSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;
  _TransactionSearchDelegate({required this.onSearch});

  @override
  String get searchFieldLabel => 'Search transactions...';

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
