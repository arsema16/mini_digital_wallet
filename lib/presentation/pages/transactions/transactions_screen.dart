import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../widgets/add_transaction_sheet.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/transaction_filter_sheet.dart';
import '../../widgets/transaction_tile.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  bool get _hasFilters =>
      _selectedType != null ||
      _selectedCategory != null ||
      _selectedDateRange != null ||
      _searchQuery.isNotEmpty;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Transactions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => showSearch(
              context: context,
              delegate: TransactionSearchDelegate(
                onSearch: (q) {
                  setState(() => _searchQuery = q);
                  _applyFilters();
                },
              ),
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => showFilterSheet(
                  context: context,
                  selectedType: _selectedType,
                  selectedCategory: _selectedCategory,
                  selectedDateRange: _selectedDateRange,
                  onApply: (type, category, dateRange) {
                    setState(() {
                      _selectedType = type;
                      _selectedCategory = category;
                      _selectedDateRange = dateRange;
                    });
                    _applyFilters();
                  },
                ),
              ),
              if (_hasFilters)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
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
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          if (_hasFilters)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (_selectedType != null)
                            ActiveFilterChip(
                              label: _selectedType!,
                              onRemove: () {
                                setState(() => _selectedType = null);
                                _applyFilters();
                              },
                            ),
                          if (_selectedCategory != null)
                            ActiveFilterChip(
                              label: _selectedCategory!,
                              onRemove: () {
                                setState(() => _selectedCategory = null);
                                _applyFilters();
                              },
                            ),
                          if (_selectedDateRange != null)
                            ActiveFilterChip(
                              label:
                                  '${FormatUtils.formatShortDate(_selectedDateRange!.start)} – ${FormatUtils.formatShortDate(_selectedDateRange!.end)}',
                              onRemove: () {
                                setState(() => _selectedDateRange = null);
                                _applyFilters();
                              },
                            ),
                          if (_searchQuery.isNotEmpty)
                            ActiveFilterChip(
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
                        style: TextStyle(color: AppColors.expense, fontSize: 12)),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocConsumer<TransactionBloc, TransactionState>(
              listener: (context, state) {
                if (state is TransactionError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.message),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              },
              builder: (context, state) {
                if (state is TransactionInitial || state is TransactionLoading) {
                  return const TransactionListShimmer();
                }
                if (state is TransactionLoaded) {
                  final txns = state.filteredTransactions;
                  if (txns.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 60, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('No transactions found',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 15)),
                          if (_hasFilters) ...[
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear filters',
                                  style: TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async =>
                        context.read<TransactionBloc>().add(LoadTransactions()),
                    color: AppColors.primary,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                      itemCount: txns.length,
                      itemBuilder: (_, i) => TransactionTile(
                        transaction: txns[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TransactionDetailScreen(transaction: txns[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                if (state is TransactionError) {
                  return Center(child: Text(state.message));
                }
                return const TransactionListShimmer();
              },
            ),
          ),
        ],
      ),
    );
  }
}
